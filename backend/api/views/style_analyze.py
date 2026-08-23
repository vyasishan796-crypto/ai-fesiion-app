import base64, logging
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from ..services.style_analyze_service import analyze_style_image, ask_style_question

logger = logging.getLogger(__name__)

@api_view(['POST'])
@permission_classes([AllowAny])
def style_analyze(request):
    """POST /api/style-analyze/ { image_base64, mime } -> StyleAnalysis JSON (100% real via Qwen)"""
    b64 = request.data.get('image_base64', '')
    mime = request.data.get('mime', 'image/jpeg')
    if not b64:
        return Response({"error": "image_base64 required"}, status=400)
    if ',' in b64 and b64.startswith('data:'):
        # data:image/jpeg;base64,xxx
        try:
            mime = b64.split(';')[0].split(':')[1]
        except: pass
        b64 = b64.split(',', 1)[1]
    try:
        import base64 as b64m
        image_bytes = b64m.b64decode(b64)
    except Exception as e:
        return Response({"error": f"invalid base64: {e}"}, status=400)
    if len(image_bytes) > 6 * 1024 * 1024:
        return Response({"error": "image too large (max 6MB)"}, status=400)
    try:
        data = analyze_style_image(image_bytes, mime)
        return Response(data, status=200)
    except Exception as e:
        logger.error(f"style_analyze failed: {e}", exc_info=True)
        # No mock fallback - return real error so frontend shows error, not fake data
        return Response({"error": str(e)}, status=500)

@api_view(['POST'])
@permission_classes([AllowAny])
def style_ask(request):
    """POST /api/style-analyze/ask/ { analysis, question } -> { answer }"""
    analysis = request.data.get('analysis')
    question = request.data.get('question', '')
    if not analysis or not question:
        return Response({"error": "analysis and question required"}, status=400)
    try:
        answer = ask_style_question(analysis, question)
        return Response({"answer": answer}, status=200)
    except Exception as e:
        logger.error(f"style_ask failed: {e}", exc_info=True)
        return Response({"error": str(e)}, status=500)
