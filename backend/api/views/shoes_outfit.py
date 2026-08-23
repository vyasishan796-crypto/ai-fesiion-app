import base64, logging
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from ..services.shoes_outfit_service import generate_outfit_for_shoes
from ..models import Product

logger = logging.getLogger(__name__)

@api_view(['POST'])
@permission_classes([AllowAny])
def shoes_outfit_generate(request):
    """
    POST /api/shoes-outfit/
    Body: { shoes_image_base64 (or shoes_product_id), user_prompt, occasion }
    Returns: { shoes_analysis, outfit_prompt, outfit_image_url }
    """
    b64 = request.data.get('shoes_image_base64', '')
    product_id = request.data.get('shoes_product_id', '')
    user_prompt = request.data.get('user_prompt', '')
    mime = request.data.get('mime', 'image/jpeg')
    shoes_name = ""

    # If product_id given, fetch product image and convert to base64 via URL fetch
    if not b64 and product_id:
        try:
            p = Product.objects.get(pk=product_id)
            shoes_name = p.name
            # Use product image URL - frontend will send b64, but if only id given, we use URL directly for analysis
            # For now, require b64 - if missing, use product image URL as fallback analysis
            import requests
            resp = requests.get(p.image_url, timeout=10)
            if resp.status_code == 200:
                b64 = base64.b64encode(resp.content).decode()
                mime = resp.headers.get('Content-Type', 'image/jpeg')
        except Exception as e:
            return Response({"error": f"Product not found: {e}"}, status=404)

    if not b64:
        return Response({"error": "shoes_image_base64 or shoes_product_id required"}, status=400)

    # Strip data URL prefix
    if ',' in b64 and b64.startswith('data:'):
        b64 = b64.split(',', 1)[1]

    try:
        result = generate_outfit_for_shoes(b64, shoes_name=shoes_name, user_prompt=user_prompt, mime=mime)
        return Response(result, status=200)
    except Exception as e:
        logger.error(f"shoes outfit generate failed: {e}", exc_info=True)
        return Response({"error": str(e)}, status=500)
