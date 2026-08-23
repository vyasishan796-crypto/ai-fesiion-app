import os
import time
import requests
import logging
from typing import Optional, Dict, Any

logger = logging.getLogger(__name__)


class NVIDIAFluxService:
    """Service for NVIDIA Flux.2-Klein-4B image generation."""

    def __init__(self):
        self.api_key = os.getenv('NVIDIA_API_KEY')
        self.base_url = os.getenv(
            'NVIDIA_API_URL',
            'https://ai.api.nvidia.com/v1/genai/black-forest-labs/flux.2-klein-4b'
        )
        self.model = os.getenv('NVIDIA_IMAGE_MODEL', 'black-forest-labs/flux.2-klein-4b')
        self.enabled = bool(self.api_key)

    def generate(
        self,
        prompt: str,
        seed: Optional[int] = None,
        width: int = 768,
        height: int = 1024,
        steps: int = 28,
        guidance_scale: float = 3.5
    ) -> Dict[str, Any]:
        """
        Generate image using NVIDIA Flux API.

        Returns:
            Dict with 'image_url' and optionally 'seed'
        """
        if not self.enabled:
            raise RuntimeError("NVIDIA API key not configured")

        payload = {
            "prompt": prompt,
            "width": width,
            "height": height,
            "steps": steps,
            "guidance_scale": guidance_scale,
            "seed": seed if seed is not None else -1
        }

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "Accept": "application/json"
        }

        try:
            # Submit generation request
            submit_response = requests.post(
                self.base_url,
                json=payload,
                headers=headers,
                timeout=30
            )
            submit_response.raise_for_status()
            submit_data = submit_response.json()

            # Handle async response (event_id polling)
            event_id = submit_data.get('event_id') or submit_data.get('id')
            if event_id:
                return self._poll_result(event_id)

            # Sync response - extract URL
            image_url = self._extract_url(submit_data)
            if image_url:
                return {"image_url": image_url, "seed": seed}

            raise ValueError(f"No image URL in response: {submit_data}")

        except requests.exceptions.Timeout:
            logger.error("NVIDIA Flux request timed out")
            raise
        except requests.exceptions.RequestException as e:
            logger.error(f"NVIDIA Flux request failed: {e}")
            raise

    def _poll_result(self, event_id: str, max_attempts: int = 30) -> Dict[str, Any]:
        """Poll for async generation result."""
        poll_url = f"{self.base_url}/{event_id}"
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Accept": "application/json"
        }

        for attempt in range(max_attempts):
            time.sleep(2)
            try:
                resp = requests.get(poll_url, headers=headers, timeout=15)
                if resp.status_code == 200:
                    data = resp.json()
                    image_url = self._extract_url(data)
                    if image_url:
                        return {"image_url": image_url}
            except Exception as e:
                logger.warning(f"Poll attempt {attempt + 1} failed: {e}")

        raise TimeoutError(f"Generation timed out after {max_attempts * 2} seconds")

    def _extract_url(self, data) -> Optional[str]:
        """Extract image URL from various response formats."""
        if isinstance(data, dict):
            # Common keys for image URL
            for key in ['url', 'image_url', 'output', 'result', 'image']:
                if key in data and data[key]:
                    val = data[key]
                    if isinstance(val, list) and val:
                        return str(val[0])
                    if isinstance(val, str):
                        return val
                    if isinstance(val, dict) and 'url' in val:
                        return str(val['url'])
        return None