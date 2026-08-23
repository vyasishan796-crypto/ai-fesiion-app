import logging

logger = logging.getLogger(__name__)


def get_seasonal_palette(seasonal_type: str = 'Universal') -> dict:
    """
    Return color palette dictionary for the given seasonal type.
    Based on CIELAB seasonal analysis (Spring/Summer/Autumn/Winter/Universal).
    """
    palettes = {
        'Spring': {
            'primary': '#FFC07F',  # Warm peach/coral
            'secondary': '#FF6B6B',  # Accent coral
            'accent': '#7C4DFF',  # Nike purple accent
            'neutrals': ['#F5F5F5', '#E0E0E0', '#212121'],
        },
        'Summer': {
            'primary': '#81A1C1',  # Soft blue-gray
            'secondary': '#B2BEB5',  # Muted rose
            'accent': '#7C4DFF',
            'neutrals': ['#F8F8F8', '#D5D8DC', '#262626'],
        },
        'Autumn': {
            'primary': '#A0522D',  # Earth brown
            'secondary': '#CD853F',  # Goldenrod
            'accent': '#7C4DFF',
            'neutrals': ['#F5F5F0', '#E8E8E8', '#1C1C1C'],
        },
        'Winter': {
            'primary': '#E7E3E8',  # Cool white-gray
            'secondary': '#F0F0F0',  # Cool gray
            'accent': '#7C4DFF',
            'neutrals': ['#252526', '#1C1C1C', '#FFFFFF'],
        },
        'Universal': {
            'primary': '#7C4DFF',
            'secondary': '#FFD700',
            'accent': '#7C4DFF',
            'neutrals': ['#FFFFFF', '#000000', '#EEEEEE'],
        },
    }
    return palettes.get(seasonal_type, palettes['Universal'])


def color_compatibility_score(hex1: str, hex2: str) -> float:
    """
    Compute a compatibility score between two hex colors (0.0-1.0).
    Based on CIELAB color distance - smaller distance = higher compatibility.
    """
    try:
        def hex_to_rgb(hex_color):
            hex_color = hex_color.lstrip('#')
            return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

        r1, g1, b1 = hex_to_rgb(hex1)
        r2, g2, b2 = hex_to_rgb(hex2)

        # Normalize
        nr1, ng1, nb1 = r1 / 255.0, g1 / 255.0, b1 / 255.0
        nr2, ng2, nb2 = r2 / 255.0, g2 / 255.0, b2 / 255.0

        # Approximate sRGB -> XYZ (rec.709)
        x1 = nr1 * 0.4124 + ng1 * 0.3576 + nb1 * 0.1805
        y1 = nr1 * 0.2126 + ng1 * 0.7152 + nb1 * 0.0722
        z1 = nr1 * 0.0193 + ng1 * 0.1192 + nb1 * 0.9505

        x2 = nr2 * 0.4124 + ng2 * 0.3576 + nb2 * 0.1805
        y2 = nr2 * 0.2126 + ng2 * 0.7152 + nb2 * 0.0722
        z2 = nr2 * 0.0193 + ng2 * 0.1192 + nb2 * 0.9505

        # Reference white D65 normalization
        x1, y1, z1 = x1 / 0.95047, y1 / 1.0, z1 / 1.08883
        x2, y2, z2 = x2 / 0.95047, y2 / 1.0, z2 / 1.08883

        # Avoid zero
        eps = 1e-8
        x1, y1, z1 = max(x1, eps), max(y1, eps), max(z1, eps)
        x2, y2, z2 = max(x2, eps), max(y2, eps), max(z2, eps)

        # Approximate L*a*b*
        def f_t(t):
            return t ** (1/3) if t > (6/29) ** 3 else t / (3 * (6/29) ** 2) + 4/29

        fx1, fy1, fz1 = f_t(x1), f_t(y1), f_t(z1)
        fx2, fy2, fz2 = f_t(x2), f_t(y2), f_t(z2)

        L1, a1, b1 = 116 * fy1 - 16, 500 * (fx1 - fy1), 200 * (fy1 - fz1)
        L2, a2, b2 = 116 * fy2 - 16, 500 * (fx2 - fy2), 200 * (fy2 - fz2)

        # Euclidean distance in Lab space
        lab_dist = ((L1 - L2) ** 2 + (a1 - a2) ** 2 + (b1 - b2) ** 2) ** 0.5

        # Convert to compatibility score (higher = more compatible)
        score = max(0.0, 1.0 - (lab_dist / 255.0))
        return round(min(score, 1.0), 4)
    except Exception:
        return 0.5