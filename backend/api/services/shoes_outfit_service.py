import os, base64, json, logging, requests
logger = logging.getLogger(__name__)

SHOES_ANALYZE_PROMPT = """Analyze these shoes in detail. Return ONLY JSON:
{
  "color": "white",
  "secondary_color": "black",
  "style": "sneakers|running|casual|formal|chunky",
  "material": "leather|mesh|canvas|suede",
  "pattern": "solid|colorblock",
  "occasion": ["casual","streetwear"],
  "season": ["all"]
}
No markdown, only JSON."""

def _analyze_shoes_qwen(image_b64: str, mime: str = "image/jpeg") -> dict:
    api_key = os.getenv("QWEN_VL_API_KEY") or os.getenv("DASHSCOPE_API_KEY") or os.getenv("NVIDIA_API_KEY", "")
    if not api_key:
        return {"color": "white", "style": "sneakers", "material": "mesh", "occasion": ["casual"]}
    base_url = os.getenv("QWEN_VL_API_URL", "https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation")
    model = os.getenv("QWEN_VL_MODEL", "qwen2.5-vl-7b-instruct")
    is_dashscope = "dashscope" in base_url
    try:
        if is_dashscope:
            payload = {"model": model, "input": {"messages": [{"role": "user", "content": [{"text": SHOES_ANALYZE_PROMPT}, {"image": f"data:{mime};base64,{image_b64}"}]}]}, "parameters": {"result_format": "message", "temperature": 0.2, "max_tokens": 500}}
            headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
            resp = requests.post(base_url, json=payload, headers=headers, timeout=30)
            resp.raise_for_status()
            j = resp.json()
            text = j["output"]["choices"][0]["message"]["content"] if "output" in j else json.dumps(j)
        else:
            url = os.getenv("NVIDIA_QWEN_URL", "https://ai.api.nvidia.com/v1/chat/completions")
            payload = {"model": model, "messages": [{"role": "user", "content": [{"type": "text", "text": SHOES_ANALYZE_PROMPT}, {"type": "image_url", "image_url": {"url": f"data:{mime};base64,{image_b64}"}}]}], "temperature": 0.2, "max_tokens": 500}
            headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
            resp = requests.post(url, json=payload, headers=headers, timeout=30)
            resp.raise_for_status()
            text = resp.json()["choices"][0]["message"]["content"]
        if "```" in text:
            text = text.split("```")[1]
            if text.strip().startswith("json"): text = text.strip()[4:]
        data = json.loads(text.strip())
        logger.info(f"Shoes analyze: {data}")
        return data
    except Exception as e:
        logger.warning(f"Shoes Qwen analyze failed: {e}")
        return {"color": "white", "style": "sneakers", "material": "mesh", "occasion": ["casual"]}

def _build_outfit_prompt(shoes_data: dict, user_prompt: str = "", shoes_name: str = "") -> str:
    color = shoes_data.get("color", "white")
    style = shoes_data.get("style", "sneakers")
    material = shoes_data.get("material", "mesh")
    occasion_list = shoes_data.get("occasion", ["casual"])
    occasion = occasion_list[0] if occasion_list else "casual"
    base = (
        f"Professional fashion outfit photography, full body model wearing complete outfit that perfectly matches {color} {style} shoes ({material} material, {shoes_name}), "
        f"shoes must be exact {color} {style} - do not change shoes design, color, or style, "
        f"outfit includes top (t-shirt/jacket) + bottom (jeans/trousers) + accessories that complement {color} shoes, "
        f"{occasion} style, color harmony with shoes, natural fit, realistic fabric folds, studio lighting, white background, "
        f"photorealistic 8k, sharp focus, fashion editorial"
    )
    if user_prompt:
        base += f" USER REQUEST: {user_prompt}"
    return base

def generate_outfit_for_shoes(shoes_image_b64: str, shoes_name: str = "", user_prompt: str = "", mime: str = "image/jpeg") -> dict:
    """Returns {shoes_analysis, outfit_prompt, outfit_image_url}"""
    shoes_data = _analyze_shoes_qwen(shoes_image_b64, mime)
    outfit_prompt = _build_outfit_prompt(shoes_data, user_prompt, shoes_name)
    # Generate outfit image via NVIDIA Flux or Pollinations fallback
    outfit_url = None
    try:
        from .nvidia_flux_service import NVIDIAFluxService
        flux = NVIDIAFluxService()
        if flux.enabled:
            res = flux.generate(outfit_prompt, width=768, height=1024)
            outfit_url = res.get("image_url")
    except Exception as e:
        logger.warning(f"Flux shoes outfit failed: {e}")
    if not outfit_url:
        try:
            from .pollinations_service import PollinationsService
            outfit_url = PollinationsService.generate(outfit_prompt, width=768, height=1024)
        except Exception as e:
            logger.error(f"Pollinations shoes outfit failed: {e}")
            outfit_url = ""
    return {"shoes_analysis": shoes_data, "outfit_prompt": outfit_prompt, "outfit_image_url": outfit_url}
