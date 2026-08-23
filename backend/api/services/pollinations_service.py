import urllib.parse
import time
import logging
from typing import Optional

logger = logging.getLogger(__name__)


class PollinationsService:
    """Free fallback image generation via Pollinations.ai"""

    BASE_URL = "https://image.pollinations.ai/prompt"

    @staticmethod
    def generate(
        prompt: str,
        width: int = 768,
        height: int = 1024,
        seed: Optional[int] = None,
        model: str = "flux",
        nologo: bool = True,
        enhance: bool = True
    ) -> str:
        """
        Generate a Pollinations image URL.

        Returns:
            Direct image URL (no API key needed)
        """
        encoded_prompt = urllib.parse.quote(prompt)
        seed_param = f"&seed={seed}" if seed is not None else f"&seed={int(time.time() * 1000) % 10000}"

        params = [
            f"width={width}",
            f"height={height}",
            f"model={model}",
            f"nologo={'true' if nologo else 'false'}",
            f"enhance={'true' if enhance else 'false'}",
            seed_param
        ]

        url = f"{PollinationsService.BASE_URL}/{encoded_prompt}?{'&'.join(params)}"
        logger.info(f"Pollinations fallback URL generated (length: {len(url)})")
        return url

    @staticmethod
    def generate_with_retry(
        prompt: str,
        width: int = 768,
        height: int = 1024,
        max_retries: int = 3
    ) -> Optional[str]:
        """Generate with automatic retry on failure."""
        for attempt in range(max_retries):
            try:
                url = PollinationsService.generate(
                    prompt, width, height,
                    seed=int(time.time() * 1000) % 10000 + attempt
                )
                # Quick HEAD request to verify URL works
                import requests
                resp = requests.head(url, timeout=10)
                if resp.status_code == 200:
                    return url
            except Exception as e:
                logger.warning(f"Pollinations attempt {attempt + 1} failed: {e}")
                time.sleep(1)

        logger.error("Pollinations all retries failed")
        return None