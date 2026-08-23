import time
import os
import logging
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from ..models import VirtualTryOnGeneration, Product
from ..serializers import (
    VirtualTryOnGenerationSerializer,
    VirtualTryOnRequestSerializer
)
from ..services.qwen_vl_service import QwenVLService
from ..services.nvidia_flux_service import NVIDIAFluxService
from ..services.pollinations_service import PollinationsService

logger = logging.getLogger(__name__)


def _build_fallback_prompt(user_prompt: str, product_details: list) -> str:
    """Build structured prompt without Qwen-VL when service unavailable."""
    product_descriptions = []
    for p in product_details:
        desc = f"{p.get('color', '')} {p.get('name', 'product')} ({p.get('category', 'clothing')})"
        if p.get('material'):
            desc += f", {p['material']} material"
        if p.get('brand'):
            desc += f", by {p['brand']}"
        product_descriptions.append(desc.strip())

    products_str = ", ".join(product_descriptions)

    return (
        f"Professional fashion virtual try-on photography. "
        f"Same person wearing {products_str}. "
        f"Preserve exact facial identity, hairstyle, skin tone, body proportions. "
        f"Garments must match product exactly: color, material, silhouette, pattern, "
        f"logo placement, collar, sleeves, pockets, buttons, seams. "
        f"Natural fabric folds, realistic lighting matching user photo, "
        f"photorealistic 8k fashion photography, sharp focus. "
        f"USER REQUEST: {user_prompt}"
    )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def virtual_tryon_generate(request):
    """
    POST /api/virtual-tryon/

    Request:
    {
        "user_image_base64": "data:image/jpeg;base64,/9j/4AAQ...",
        "product_ids": ["1", "2"],
        "user_prompt": "Put this black oversized jacket on me, streetwear style",
        "outfit_id": "outfit_abc123",
        "seed": 42
    }

    Response:
    {
        "id": 123,
        "outfit_id": "outfit_abc123",
        "product_ids": ["1", "2"],
        "user_prompt": "...",
        "user_image_url": "...",
        "result_image_url": "https://...",
        "enhanced_prompt": "...",
        "model_used": "flux.2-klein-4b",
        "qwen_model_used": "qwen2.5-vl-7b-instruct",
        "generation_time_ms": 4500,
        "status": "completed",
        "error_message": "",
        "metadata": {...},
        "created_at": "2026-08-22T..."
    }
    """
    serializer = VirtualTryOnRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    data = serializer.validated_data
    start_time = time.time()

    # Create generation record
    generation = VirtualTryOnGeneration.objects.create(
        user=request.user,
        outfit_id=data.get('outfit_id', ''),
        product_ids=data['product_ids'],
        user_prompt=data['user_prompt'],
        user_image_url=data['user_image_base64'][:100] + '...',  # Truncated for storage
        status='enhancing'
    )

    try:
        # 1. Resolve product details from database
        product_ids = data['product_ids']
        products = Product.objects.filter(id__in=product_ids)

        if products.count() != len(product_ids):
            missing = set(product_ids) - set(products.values_list('id', flat=True))
            generation.status = 'failed'
            generation.error_message = f'Products not found: {missing}'
            generation.generation_time_ms = int((time.time() - start_time) * 1000)
            generation.save()
            return Response(
                {'error': f'Products not found: {missing}'},
                status=status.HTTP_404_NOT_FOUND
            )

        product_details = []
        product_images = []
        for p in products:
            product_details.append({
                'id': str(p.id),
                'sku': getattr(p, 'sku', ''),
                'name': p.name,
                'color': getattr(p, 'color', ''),
                'category': p.category,
                'material': getattr(p, 'material', ''),
                'brand': p.brand,
                'image_url': p.image_url
            })
            product_images.append(p.image_url)

        # 2. Enhance prompt with Qwen-VL
        qwen_service = QwenVLService()
        generation.status = 'enhancing'
        generation.save()

        try:
            qwen_result = qwen_service.enhance_prompt(
                data['user_image_base64'],
                product_images,
                product_details,
                data['user_prompt']
            )
            enhanced_prompt = qwen_result['enhanced_prompt']
            generation.enhanced_prompt = enhanced_prompt
            generation.qwen_model_used = os.getenv('QWEN_VL_MODEL', 'qwen2.5-vl-7b-instruct')
            logger.info("Qwen-VL prompt enhancement successful")
        except Exception as e:
            logger.warning(f"Qwen-VL failed, using fallback prompt: {e}")
            enhanced_prompt = _build_fallback_prompt(data['user_prompt'], product_details)

        # 3. Generate image
        generation.status = 'generating'
        generation.save()

        seed = data.get('seed')
        result_url = None
        model_used = 'pollinations-flux'

        # Try NVIDIA Flux first
        flux_service = NVIDIAFluxService()
        if flux_service.enabled:
            try:
                flux_result = flux_service.generate(
                    enhanced_prompt,
                    seed=seed,
                    width=768,
                    height=1024
                )
                result_url = flux_result.get('image_url')
                model_used = 'flux.2-klein-4b'
                logger.info("NVIDIA Flux generation successful")
            except Exception as e:
                logger.warning(f"NVIDIA Flux failed: {e}")

        # Fallback to Pollinations
        if not result_url:
            logger.info("Using Pollinations fallback")
            result_url = PollinationsService.generate(
                enhanced_prompt,
                width=768,
                height=1024,
                seed=seed
            )
            model_used = 'pollinations-flux'

        if not result_url:
            raise ValueError("No image URL returned from any generation service")

        # 4. Save success
        generation.result_image_url = result_url
        generation.status = 'completed'
        generation.model_used = model_used
        generation.generation_time_ms = int((time.time() - start_time) * 1000)
        generation.metadata = {
            'product_details': product_details,
            'seed': seed,
            'original_prompt': data['user_prompt']
        }
        generation.save()

        return Response(
            VirtualTryOnGenerationSerializer(generation).data,
            status=status.HTTP_201_CREATED
        )

    except Exception as e:
        generation.status = 'failed'
        generation.error_message = str(e)
        generation.generation_time_ms = int((time.time() - start_time) * 1000)
        generation.save()
        logger.error(f"Virtual try-on failed: {e}", exc_info=True)
        return Response(
            {'error': 'Generation failed. Please try again.'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def virtual_tryon_history(request):
    """GET /api/virtual-tryon/history/ - Get user's generation history"""
    generations = VirtualTryOnGeneration.objects.filter(user=request.user)[:50]
    serializer = VirtualTryOnGenerationSerializer(generations, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def virtual_tryon_detail(request, pk):
    """GET /api/virtual-tryon/{id}/ - Get specific generation"""
    try:
        generation = VirtualTryOnGeneration.objects.get(pk=pk, user=request.user)
        serializer = VirtualTryOnGenerationSerializer(generation)
        return Response(serializer.data)
    except VirtualTryOnGeneration.DoesNotExist:
        return Response(
            {'error': 'Generation not found'},
            status=status.HTTP_404_NOT_FOUND
        )