import logging
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from ..models import AppearanceAnalysis, OutfitRecommendation, UserInteraction
from ..serializers import AppearanceAnalysisSerializer, OutfitRecommendationSerializer, UserInteractionSerializer
from ..services.outfit_generator import generate_outfits_from_profile, get_seasonal_palette
from ..services.color_harmony import color_compatibility_score

logger = logging.getLogger(__name__)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def outfit_recommend(request):
    """
    POST /api/outfits/recommend/
    Generate outfit recommendations based on user's appearance analysis.
    Request: { appearance_id?, occasion? }
    Response: 3-5 outfit recommendations with scores and explanations.
    """
    user = request.user
    appearance_id = request.data.get('appearance_id')
    occasion = request.data.get('occasion', '')

    # Get the appearance analysis
    if appearance_id:
        try:
            appearance = AppearanceAnalysis.objects.get(pk=appearance_id, user=user)
        except AppearanceAnalysis.DoesNotExist:
            return Response(
                {'error': 'Appearance analysis not found'},
                status=status.HTTP_404_NOT_FOUND
            )
    else:
        # Get the user's latest appearance analysis
        appearance = AppearanceAnalysis.objects.filter(user=user).order_by('-created_at').first()
        if not appearance:
            return Response(
                {'error': 'No appearance analysis found. Run /api/appearance/analyze/ first.'},
                status=status.HTTP_400_BAD_REQUEST
            )

    # Get color profile and body proportions from the appearance
    color_profile = appearance.color_profile
    body_props = appearance.body_props

    # Generate outfit recommendations
    outfits = generate_outfits_from_profile(
        appearance,
        color_profile,
        body_props,
        occasion=occasion
    )

    # Save recommendations to database
    saved_outfits = []
    for outfit_data in outfits:
        # Serialize outfit data for storage
        outfit_serializer = OutfitRecommendationSerializer(data={
            'user': user.id,
            'appearance': appearance.id,
            'outfit_data': outfit_data['data'],
            'score': outfit_data['score'],
            'scores': outfit_data.get('scores', {}),
            'explanation': outfit_data.get('explanation', ''),
            'wardrobe_used': outfit_data.get('wardrobe_used', False),
            'occasion': outfit_data.get('occasion', occasion),
        })
        if outfit_serializer.is_valid():
            outfit_rec = outfit_serializer.save()
            saved_outfits.append(OutfitRecommendationSerializer(outfit_rec).data)

    response_data = {
        'appearance_id': appearance.id,
        'outfit_recommendations': saved_outfits,
        'total_generated': len(saved_outfits),
        'message': f'Generated {len(saved_outfits)} outfit(s) based on your appearance profile',
    }

    logger.info(f"Generated {len(saved_outfits)} outfit(s) for user {user.username}")
    return Response(response_data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def user_interaction(request):
    """
    POST /api/outfits/interaction/
    Record user interaction with an outfit recommendation.
    Request: { outfit_recommendation_id, interaction_type }
    interaction_type: view, like, dislike, save, purchase
    """
    user = request.user
    outfit_rec_id = request.data.get('outfit_recommendation_id')
    interaction_type = request.data.get('interaction_type')

    valid_types = ['view', 'like', 'dislike', 'save', 'purchase']
    if interaction_type not in valid_types:
        return Response(
            {'error': f'Invalid interaction type. Must be one of: {", ".join(valid_types)}'},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        outfit_rec = OutfitRecommendation.objects.get(pk=outfit_rec_id, user=user)
    except OutfitRecommendation.DoesNotExist:
        return Response(
            {'error': 'Outfit recommendation not found'},
            status=status.HTTP_404_NOT_FOUND
        )

    # Check if interaction already exists (unique_together constraint)
    interaction, created = UserInteraction.objects.get_or_create(
        user=user,
        outfit_recommendation=outfit_rec,
        interaction_type=interaction_type
    )

    if not created:
        # Already recorded this interaction, just return current status
        pass

    return Response({
        'outfit_rec_id': outfit_rec.id,
        'interaction_type': interaction_type,
        'created': created,
        'message': f'Recorded {interaction_type} for outfit recommendation'
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def outfit_history(request):
    """
    GET /api/outfits/history/
    Get user's outfit recommendation history.
    """
    outfits = OutfitRecommendation.objects.filter(user=request.user).order_by('-created_at')[:20]
    serializer = OutfitRecommendationSerializer(outfits, many=True)
    return Response(serializer.data)