import base64, logging, os
from datetime import datetime
from io import BytesIO

from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from PIL import Image, ImageFilter, ImageOps
import numpy as np

from ..models import AppearanceAnalysis, SkinAnalysis, BodyProportions, ColorProfile
from ..serializers import (
    AppearanceAnalysisSerializer,
    SkinAnalysisSerializer,
    BodyProportionsSerializer,
    ColorProfileSerializer,
)
from ..services.image_quality import validate_image_quality, detect_faces
from ..services.skin_analysis import analyze_skin_color
from ..services.body_proportions import analyze_body_proportions

logger = logging.getLogger(__name__)


def _parse_image_from_request(request):
    """Extract image data from multipart request, return PIL Image or None."""
    image_file = request.FILES.get('image')
    if not image_file:
        return None
    try:
        img = Image.open(image_file)
        img.load()  # Force load to detect corrupt images
        return img
    except Exception as e:
        logger.warning(f"Failed to open image: {e}")
        return None


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def appearance_analyze(request):
    """
    POST /api/appearance/analyze/
    Multipart form-data: { image, occasion? }
    Returns appearance analysis: skin tone, undertone, body proportions, color profile.
    """
    user = request.user
    occasion = request.data.get('occasion', '')

    # Parse and validate image
    img = _parse_image_from_request(request)
    if img is None:
        return Response(
            {'error': 'No image provided or invalid image format'},
            status=status.HTTP_400_BAD_REQUEST
        )

    # Validate image quality using Pillow + numpy
    quality_result = validate_image_quality(img)
    if not quality_result['valid']:
        return Response(
            {'error': quality_result['error']},
            status=status.HTTP_400_BAD_REQUEST
        )

    # Check for faces - require at least one face for full analysis
    faces = detect_faces(img)
    if not faces:
        return Response(
            {'error': 'No face detected in the image. Please provide a clear frontal face photo.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    # Analyze skin tone and undertone using CIELAB color space
    skin_result = analyze_skin_color(img, faces[0])

    # Analyze body proportions (silhouette, ratios)
    body_result = analyze_body_proportions(img)

    # Create or update AppearanceAnalysis record (OneToOneField per user)
    appearance, created = AppearanceAnalysis.objects.update_or_create(
        user=user,
        defaults={
            'version': 'appearance_v1',
            'quality_score': quality_result.get('quality_score', 0.0),
            'overall_confidence': (skin_result['tone_confidence'] + skin_result['undertone_confidence']) / 2.0,
        }
    )

    # Create or update SkinAnalysis
    skin_analysis_obj, _ = SkinAnalysis.objects.update_or_create(
        appearance=appearance,
        defaults={
            'tone': skin_result['tone'],
            'undertone': skin_result['undertone'],
            'tone_confidence': skin_result['tone_confidence'],
            'undertone_confidence': skin_result['undertone_confidence'],
            'L_median': skin_result.get('L_median'),
            'a_median': skin_result.get('a_median'),
            'b_median': skin_result.get('b_median'),
            'valid_pixel_count': skin_result.get('valid_pixel_count'),
            'std_dev': skin_result.get('std_dev'),
        }
    )

    # Create or update BodyProportions
    body_props_obj, _ = BodyProportions.objects.update_or_create(
        appearance=appearance,
        defaults={
            'silhouette': body_result.get('silhouette', ''),
            'confidence': body_result.get('confidence', 0.0),
            'shoulder_hip_ratio': body_result.get('shoulder_hip_ratio'),
            'torso_leg_ratio': body_result.get('torso_leg_ratio'),
            'upper_body_ratio': body_result.get('upper_body_ratio'),
        }
    )

    # Create or update ColorProfile
    color_profile_obj, _ = ColorProfile.objects.update_or_create(
        appearance=appearance,
        defaults={
            'primary_color': skin_result.get('primary_color', ''),
            'secondary_color': skin_result.get('secondary_color', ''),
            'accent_color': '#7C4DFF',
            'contrast_level': skin_result.get('contrast_level', 'medium'),
            'seasonal_palette': skin_result.get('seasonal_palette', ''),
        }
    )

    # Serialize response
    appearance_serializer = AppearanceAnalysisSerializer(appearance)
    skin_serializer = SkinAnalysisSerializer(skin_analysis_obj)
    body_serializer = BodyProportionsSerializer(body_props_obj)
    color_serializer = ColorProfileSerializer(color_profile_obj)

    response_data = {
        'analysis_id': appearance.id,
        'appearance': appearance_serializer.data,
        'skin': skin_serializer.data,
        'body': body_serializer.data,
        'color_profile': color_serializer.data,
        'overall_confidence': round(
            (skin_result['tone_confidence'] + skin_result['undertone_confidence'] + body_result.get('confidence', 0.0)) / 3, 4
        ),
        'occasion': occasion,
        'message': 'Appearance analysis completed successfully',
    }

    logger.info(f"Appearance analysis completed for user {user.username}")
    return Response(response_data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def appearance_detail(request, pk):
    """
    GET /api/appearance/{pk}/
    Retrieve a saved appearance analysis by ID with full nested data.
    """
    try:
        appearance = AppearanceAnalysis.objects.get(pk=pk, user=request.user)
    except AppearanceAnalysis.DoesNotExist:
        return Response(
            {'error': 'Appearance analysis not found'},
            status=status.HTTP_404_NOT_FOUND
        )

    skin = SkinAnalysis.objects.filter(appearance=appearance).first()
    body = BodyProportions.objects.filter(appearance=appearance).first()
    color = ColorProfile.objects.filter(appearance=appearance).first()

    response_data = {
        'analysis_id': appearance.id,
        'appearance': AppearanceAnalysisSerializer(appearance).data,
        'skin': SkinAnalysisSerializer(skin).data if skin else {},
        'body': BodyProportionsSerializer(body).data if body else {},
        'color_profile': ColorProfileSerializer(color).data if color else {},
        'overall_confidence': appearance.overall_confidence or 0.0,
        'occasion': '',
        'created_at': appearance.created_at.isoformat() if appearance.created_at else '',
    }

    return Response(response_data)