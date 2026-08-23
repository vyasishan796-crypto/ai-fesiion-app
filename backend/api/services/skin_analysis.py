import logging
from PIL import Image
import numpy as np

logger = logging.getLogger(__name__)


def rgb_to_lab(r, g, b):
    """Convert RGB to CIELAB using standard formulas."""
    # Normalize to 0-1
    r, g, b = r / 255.0, g / 255.0, b / 255.0
    # sRGB to XYZ
    r_lin = ((r + 0.055) / 1.055) ** 2.4 if r > 0.04045 else r / 12.92
    g_lin = ((g + 0.055) / 1.055) ** 2.4 if g > 0.04045 else g / 12.92
    b_lin = ((b + 0.055) / 1.055) ** 2.4 if b > 0.04045 else b / 12.92
    X = r_lin * 0.4124 + g_lin * 0.3576 + b_lin * 0.1805
    Y = r_lin * 0.2126 + g_lin * 0.7152 + b_lin * 0.0722
    Z = r_lin * 0.0193 + g_lin * 0.1192 + b_lin * 0.9505
    # XYZ to Lab (reference white D65)
    xr, yr, zr = X / 0.95047, Y / 1.0, Z / 1.08883
    def f(t):
        return t ** (1/3) if t > (6/29) ** 3 else (t / (3 * (6/29) ** 2)) + 4/29
    L = 116 * f(yr) - 16
    a = 500 * (f(xr) - f(yr))
    b_lab = 200 * (f(yr) - f(zr))
    return L, a, b_lab


def analyze_skin_color(img: Image.Image, face_box: dict) -> dict:
    """
    Analyze skin tone and undertone from the face region.
    Returns dict with tone, undertone, confidence, CIELAB values, color palette.
    """
    try:
        # Convert to RGB if needed
        if img.mode != 'RGB':
            img_rgb = img.convert('RGB')
        else:
            img_rgb = img

        width, height = img_rgb.size

        # Extract face region (simplified - use the box provided)
        center = face_box.get('center', (width // 2, height // 2))
        size = face_box.get('size', min(width, height) // 3)

        # Define face region - generous rectangle around center face
        x1 = max(0, center[0] - size)
        y1 = max(0, center[1] - size)
        x2 = min(width, center[0] + size)
        y2 = min(height, center[1] + size)

        face_region = img_rgb.crop((x1, y1, x2, y2))
        face_array = np.array(face_region)

        # Create skin mask using simple color heuristics (CbCr approximate via Lab)
        # Convert entire face region to Lab
        face_rgb = face_array[:, :, :3]
        # Vectorized RGB-to-Lab conversion (approximate per-pixel)
        # Build lookup for efficiency
        face_pixels = face_rgb.reshape(-1, 3)
        valid_mask = (face_pixels[:, 0] > 20) & (face_pixels[:, 1] > 20) & (face_pixels[:, 2] > 20) & \
                     (face_pixels[:, 0] < 235) & (face_pixels[:, 1] < 235) & (face_pixels[:, 2] < 235)

        if not np.any(valid_mask):
            return {
                'tone': '',
                'undertone': '',
                'tone_confidence': 0.0,
                'undertone_confidence': 0.0,
                'L_median': None,
                'a_median': None,
                'b_median': None,
                'valid_pixel_count': 0,
                'std_dev': None,
                'primary_color': '',
                'secondary_color': '',
                'contrast_level': 'medium',
                'seasonal_palette': '',
            }

        # Convert valid pixels to Lab
        valid_pixels = face_pixels[valid_mask]
        # Vectorized approximate Lab conversion
        # Using numpy for speed - simplified formula
        normalized = valid_pixels / 255.0
        # sRGB to XYX (rec.709)
        xyz_matrix = np.array([
            [0.4124, 0.3576, 0.1805],
            [0.2126, 0.7152, 0.0722],
            [0.0193, 0.1192, 0.9505]
        ])
        xyz = normalized @ xyz_matrix.T
        # Avoid log(0)
        xyz = np.where(xyz > 0, xyz, 1e-8)
        # Reference white D65
        xyz_norm = xyz / np.array([0.95047, 1.0, 1.08883])
        # Power 1/3
        mask = xyz_norm > (6/29) ** 3
        fxyz = np.where(mask, xyz_norm ** (1/3), (xyz_norm / (3 * (6/29) ** 2)) + 4/29)
        L = 116 * fxyz[:, 1] - 16
        a = 500 * (fxyz[:, 0] - fxyz[:, 1])
        b = 200 * (fxyz[:, 1] - fxyz[:, 2])

        # Compute median values
        L_median = float(np.median(L))
        a_median = float(np.median(a))
        b_median = float(np.median(b))
        valid_pixel_count = int(np.sum(valid_mask))

        # Standard deviation
        std_dev = float(np.std(a)) if valid_pixel_count > 0 else 0.0

        # Tone classification based on L and a values
        # Warm: high a (positive), Cool: low/negative a
        if a_median > 15:
            tone = 'Warm'
            tone_confidence = min(abs(a_median) / 50, 1.0)
        elif a_median < -15:
            tone = 'Cool'
            tone_confidence = min(abs(a_median) / 50, 1.0)
        else:
            tone = 'Neutral'
            tone_confidence = 0.5

        # Undertone classification based on b values
        # Golden: positive b, Rosy: negative b
        if b_median > 15:
            undertone = 'Golden'
            undertone_confidence = min(abs(b_median) / 50, 1.0)
        elif b_median < -15:
            undertone = 'Rosy'
            undertone_confidence = min(abs(b_median) / 50, 1.0)
        else:
            undertone = 'Neutral'
            undertone_confidence = 0.5

        # Determine primary color (dominant hue from skin)
        # Based on the a,b coordinates quadrant
        if a_median > 0 and b_median > 0:
            primary_color = 'Peach/Golden'
        elif a_median > 0 and b_median <= 0:
            primary_color = 'Wheat'
        elif a_median <= 0 and b_median > 0:
            primary_color = 'Rosy'
        else:
            primary_color = 'Neutral/Olive'

        # Secondary color
        if abs(a_median) > 30 or abs(b_median) > 30:
            secondary_color = 'Deep/' + primary_color
        else:
            secondary_color = 'Light/' + primary_color

        # Contrast level based on L range
        l_range = float(np.max(L)) - float(np.min(L)) if valid_pixel_count > 1 else 0
        contrast_level = 'high' if l_range > 40 else ('medium' if l_range > 20 else 'low')

        # Seasonal palette suggestion
        if tone == 'Warm' and undertone == 'Golden' and l_range > 20:
            seasonal_palette = 'Spring'
        elif tone == 'Cool' and undertone == 'Rosy':
            seasonal_palette = 'Summer'
        elif tone == 'Warm' and undertone == 'Golden' and l_range <= 20:
            seasonal_palette = 'Autumn'
        elif tone == 'Cool' and undertone == 'Rosy' and l_range <= 20:
            seasonal_palette = 'Winter'
        else:
            seasonal_palette = 'Universal'

        return {
            'tone': tone,
            'undertone': undertone,
            'tone_confidence': round(tone_confidence, 4),
            'undertone_confidence': round(undertone_confidence, 4),
            'L_median': round(L_median, 2),
            'a_median': round(a_median, 2),
            'b_median': round(b_median, 2),
            'valid_pixel_count': valid_pixel_count,
            'std_dev': round(std_dev, 2),
            'primary_color': primary_color,
            'secondary_color': secondary_color,
            'contrast_level': contrast_level,
            'seasonal_palette': seasonal_palette,
        }

    except Exception as e:
        logger.error(f"Skin color analysis error: {e}", exc_info=True)
        return {
            'tone': '',
            'undertone': '',
            'tone_confidence': 0.0,
            'undertone_confidence': 0.0,
            'L_median': None,
            'a_median': None,
            'b_median': None,
            'valid_pixel_count': 0,
            'std_dev': None,
            'primary_color': '',
            'secondary_color': '',
            'contrast_level': 'medium',
            'seasonal_palette': '',
        }