import os
import json
import requests
import logging
from typing import List, Dict, Any, Optional

logger = logging.getLogger(__name__)


class QwenVLService:
    """Service for Qwen2.5-VL prompt enhancement using DashScope API."""

    def __init__(self):
        self.api_key = os.getenv('QWEN_VL_API_KEY') or os.getenv('DASHSCOPE_API_KEY')
        self.base_url = os.getenv(
            'QWEN_VL_API_URL',
            'https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation'
        )
        self.model = os.getenv('QWEN_VL_MODEL', 'qwen2.5-vl-7b-instruct')
        self.enabled = bool(self.api_key)

    def enhance_prompt(
        self,
        user_image_base64: str,
        product_images: List[str],
        product_details: List[Dict],
        user_prompt: str
    ) -> Dict[str, Any]:
        """
        Enhance the user prompt with Qwen2.5-VL analysis of user photo + product images.

        Returns:
            Dict with 'enhanced_prompt' and 'raw_response'
        """
        if not self.enabled:
            logger.warning("Qwen-VL not configured (no API key), using fallback prompt")
            return {"enhanced_prompt": self._build_fallback_prompt(user_prompt, product_details)}

        try:
            messages = self._build_analysis_messages(
                user_image_base64, product_images, product_details, user_prompt
            )

            payload = {
                "model": self.model,
                "input": {"messages": messages},
                "parameters": {
                    "result_format": "message",
                    "temperature": 0.3,
                    "top_p": 0.8,
                    "max_tokens": 2048
                }
            }

            headers = {
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json"
            }

            response = requests.post(
                self.base_url,
                json=payload,
                headers=headers,
                timeout=60
            )
            response.raise_for_status()
            result = response.json()

            if result.get('output', {}).get('choices'):
                enhanced_prompt = result['output']['choices'][0]['message']['content']
                return {
                    "enhanced_prompt": enhanced_prompt.strip(),
                    "raw_response": result
                }
            else:
                logger.warning(f"Unexpected Qwen-VL response format: {result}")
                return {"enhanced_prompt": self._build_fallback_prompt(user_prompt, product_details)}

        except requests.exceptions.Timeout:
            logger.error("Qwen-VL request timed out")
            return {"enhanced_prompt": self._build_fallback_prompt(user_prompt, product_details)}
        except requests.exceptions.RequestException as e:
            logger.error(f"Qwen-VL request failed: {e}")
            return {"enhanced_prompt": self._build_fallback_prompt(user_prompt, product_details)}
        except Exception as e:
            logger.error(f"Qwen-VL unexpected error: {e}")
            return {"enhanced_prompt": self._build_fallback_prompt(user_prompt, product_details)}

    def _build_analysis_messages(
        self,
        user_image_b64: str,
        product_images: List[str],
        product_details: List[Dict],
        user_prompt: str
    ) -> List[Dict]:
        """Build the multi-modal conversation for Qwen-VL."""

        system_content = """You are an expert fashion virtual try-on prompt engineer.
Your task: Analyze the user's photo and product images, then write a precise, detailed generation prompt for a text-to-image model (Flux/SDXL) that will create a photorealistic virtual try-on result.

OUTPUT FORMAT: Return ONLY the enhanced generation prompt - no explanations, no markdown, no extra text.

ANALYSIS REQUIREMENTS:
1. USER PHOTO: Identify - pose (standing/sitting/walking), body type, skin tone, lighting direction, background, camera angle, facial features, hairstyle, existing clothing
2. PRODUCT IMAGES: For each product, extract - exact color (hex/description), material/fabric appearance, silhouette/fit type, pattern/graphics, logo placement, collar/neckline, sleeves, pockets, buttons/zippers, seams/stitching, overall construction details
3. USER PROMPT: Extract intent - fit preference (fitted/oversized/relaxed), style context (streetwear/formal/casual/ethnic), background preference, specific modifications

GENERATION PROMPT MUST INCLUDE:
- Identity preservation: "Same person, identical facial features, hairstyle, skin tone, body proportions"
- Product fidelity: Each product described with exact visual details (color, material, silhouette, pattern, logo, construction)
- Natural fit: "Garment adapts naturally to body pose and shape, realistic fabric folds at [specific areas], proper contact points"
- Lighting consistency: Match user photo lighting direction, intensity, color temperature
- Camera perspective: Maintain same camera angle, focal length, depth of field
- Quality markers: "Photorealistic, 8k, professional fashion photography, sharp focus, natural skin texture, fabric micro-detail"
- NO: collage, floating garments, changed identity, invented designs, distorted anatomy"""

        content = [{"type": "text", "text": f"USER PROMPT: {user_prompt}"}]

        # Add user photo
        content.append({
            "type": "image_url",
            "image_url": {"url": f"data:image/jpeg;base64,{user_image_b64}"}
        })

        # Add each product image with metadata
        for i, (img_url, details) in enumerate(zip(product_images, product_details)):
            content.append({
                "type": "text",
                "text": (
                    f"PRODUCT {i+1}: {details.get('name', 'Unknown')} "
                    f"(SKU: {details.get('sku', 'N/A')}) - "
                    f"Color: {details.get('color', 'Unknown')}, "
                    f"Category: {details.get('category', 'Unknown')}, "
                    f"Material: {details.get('material', 'Unknown')}, "
                    f"Brand: {details.get('brand', 'Unknown')}"
                )
            })
            content.append({"type": "image_url", "image_url": {"url": img_url}})

        content.append({"type": "text", "text": "Generate the enhanced prompt now."})

        return [
            {"role": "system", "content": system_content},
            {"role": "user", "content": content}
        ]

    def _build_fallback_prompt(self, user_prompt: str, product_details: List[Dict]) -> str:
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