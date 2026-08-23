import logging
from PIL import Image
import numpy as np

logger = logging.getLogger(__name__)


def analyze_body_proportions(img: Image.Image) -> dict:
    try:
        gray_img = img.convert('L')
        width, height = gray_img.size
        gray_array = np.array(gray_img)

        top_y = height // 3
        mid_y = 2 * height // 3

        top_section = gray_array[0:top_y, :]
        middle_section = gray_array[top_y:mid_y, :]
        bottom_section = gray_array[mid_y:height, :]

        def section_width(arr, threshold=200):
            non_bg = arr[arr < threshold]
            if len(non_bg) == 0:
                return 0
            cols = np.any(arr < threshold, axis=0)
            return int(np.sum(cols))

        top_width = section_width(top_section)
        middle_width = section_width(middle_section)
        bottom_width = section_width(bottom_section)

        top_ratio = top_width / width if width > 0 else 0
        middle_ratio = middle_width / width if width > 0 else 0
        bottom_ratio = bottom_width / width if width > 0 else 0

        if top_ratio > middle_ratio and top_ratio > bottom_ratio:
            if middle_ratio > bottom_ratio:
                silhouette = 'inverted_triangle'
                confidence = 0.6
            else:
                silhouette = 'triangle'
                confidence = 0.5
        elif bottom_ratio > top_ratio and bottom_ratio > middle_ratio:
            if top_ratio > middle_ratio:
                silhouette = 'pear'
                confidence = 0.6
            else:
                silhouette = 'triangle'
                confidence = 0.5
        elif middle_ratio > top_ratio and middle_ratio > bottom_ratio:
            silhouette = 'rectangle'
            confidence = 0.5
        else:
            silhouette = 'hourglass' if abs(top_ratio - bottom_ratio) < 0.05 else 'rectangle'
            confidence = 0.55

        shoulder_hip_ratio = round(top_ratio / bottom_ratio, 3) if bottom_ratio > 0 else 1.0
        torso_leg_ratio = round(middle_ratio / bottom_ratio, 3) if bottom_ratio > 0 else 1.0
        upper_lower_ratio = round(top_ratio / middle_ratio, 3) if middle_ratio > 0 else 1.0

        return {
            'silhouette': silhouette,
            'confidence': round(confidence, 4),
            'shoulder_hip_ratio': shoulder_hip_ratio,
            'torso_leg_ratio': torso_leg_ratio,
            'upper_body_ratio': upper_lower_ratio,
        }

    except Exception as e:
        logger.error(f"Body proportions analysis error: {e}", exc_info=True)
        return {
            'silhouette': 'rectangle',
            'confidence': 0.3,
            'shoulder_hip_ratio': 1.0,
            'torso_leg_ratio': 1.0,
            'upper_body_ratio': 1.0,
        }
