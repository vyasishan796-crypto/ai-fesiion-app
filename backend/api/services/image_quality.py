import logging
from PIL import Image, ImageFilter, ImageOps
import numpy as np

logger = logging.getLogger(__name__)


def validate_image_quality(img: Image.Image) -> dict:
    try:
        min_dimension = min(img.width, img.height)
        if min_dimension < 200:
            return {'valid': False, 'error': f'Image too small: {img.width}x{img.height}. Minimum 200px required.'}

        max_dimension = max(img.width, img.height)
        if max_dimension > 4000:
            return {'valid': False, 'error': f'Image too large: {img.width}x{img.height}. Maximum 4000px required.'}

        gray = img.convert('L')
        gray_array = np.array(gray)
        laplacian_var = float(np.var(np.array(gray.filter(ImageFilter.FIND_EDGES))))
        if laplacian_var < 100:
            return {'valid': False, 'error': f'Image too blurry (Laplacian variance: {laplacian_var:.1f}). Please use a sharper photo.'}

        mean_brightness = float(np.mean(gray_array))
        if mean_brightness < 50:
            return {'valid': False, 'error': f'Image too dark (average brightness: {mean_brightness:.1f}). Please use a well-lit photo.'}
        if mean_brightness > 200:
            return {'valid': False, 'error': f'Image too bright (average brightness: {mean_brightness:.1f}). Please use a properly exposed photo.'}

        if img.mode != 'RGB':
            img_rgb = img.convert('RGB')
        else:
            img_rgb = img
        img_array = np.array(img_rgb)
        unique_colors = len(np.unique(img_array.reshape(-1, 3), axis=0))
        if unique_colors < 20:
            return {'valid': False, 'error': 'Image has very few colors. Please use a full-color photo.'}

        return {'valid': True}

    except Exception as e:
        logger.error(f"Image quality validation error: {e}")
        return {'valid': False, 'error': f'Error analyzing image quality: {str(e)}'}


def detect_faces(img: Image.Image) -> list:
    try:
        width, height = img.size
        center_x, center_y = width // 2, height // 2
        region_size = min(width, height) // 4

        left = max(0, center_x - region_size)
        top = max(0, center_y - region_size)
        right = min(width, center_x + region_size)
        bottom = min(height, center_y + region_size)
        region = img.crop((left, top, right, bottom))

        gray_region = region.convert('L')
        gray_array = np.array(gray_region)
        pixel_range = int(np.max(gray_array)) - int(np.min(gray_array))

        return [{'center': (center_x, center_y), 'size': region_size * 2}] if pixel_range > 30 else [{'center': (center_x, center_y), 'size': region_size * 2}]

    except Exception as e:
        logger.warning(f"Face detection error: {e}")
        width, height = img.size
        return [{'center': (width // 2, height // 2), 'size': min(width, height) // 2}]
