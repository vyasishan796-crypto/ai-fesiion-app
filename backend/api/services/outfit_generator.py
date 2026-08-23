import logging
from random import sample, randint, uniform, choice
from django.conf import settings

logger = logging.getLogger(__name__)


# Predefined color palette by seasonal type (CIELAB reference points)
SEASONAL_PALETTES = {
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


def get_seasonal_palette(seasonal_type: str) -> dict:
    """Return color palette dict for the given seasonal type."""
    return SEASONAL_PALETTES.get(seasonal_type, SEASONAL_PALETTES['Universal'])


def color_compatibility_score(hex1: str, hex2: str) -> float:
    """
    Compute a compatibility score between two hex colors (0.0-1.0).
    Based on CIELAB distance - smaller distance = higher compatibility.
    """
    try:
        # Simple hex to RGB
        def hex_to_rgb(hex_color):
            hex_color = hex_color.lstrip('#')
            return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

        r1, g1, b1 = hex_to_rgb(hex1)
        r2, g2, b2 = hex_to_rgb(hex2)

        # Convert to normalized
        nr1, ng1, nb1 = r1 / 255.0, g1 / 255.0, b1 / 255.0
        nr2, ng2, nb2 = r2 / 255.0, g2 / 255.0, b2 / 255.0

        # Approximate Lab conversion
        def rgb_to_lab_approx(r, g, b):
            r, g, b = r / 255.0, g / 255.0, b / 255.0
            x = r * 0.4124 + g * 0.3576 + b * 0.1805
            y = r * 0.2126 + g * 0.7152 + b * 0.0722
            z = r * 0.0193 + g * 0.1192 + b * 0.9505
            return x, y, z

        x1, y1, z1 = rgb_to_lab_approx(r1, g1, b1)
        x2, y2, z2 = rgb_to_lab_approx(r2, g2, b2)

        # Normalize for D65
        x1, y1, z1 = x1 / 0.95047, y1 / 1.0, z1 / 1.08883
        x2, y2, z2 = x2 / 0.95047, y2 / 1.0, z2 / 1.08883

        # Avoid zero
        eps = 1e-8
        x1, y1, z1 = max(x1, eps), max(y1, eps), max(z1, eps)
        x2, y2, z2 = max(x2, eps), max(y2, eps), max(z2, eps)

        # Catlinary transform
        x1, y1, z1 = x1 * 1.0, y1 * 1.0, z1 * 1.0
        x2, y2, z2 = x2 * 1.0, y2 * 1.0, z2 * 1.0

        # Compute L*a*b* approximately
        def f_t(t):
            return t ** (1/3) if t > (6/29) ** 3 else t / (3 * (6/29) ** 2) + 4/29

        fx1 = f_t(x1); fy1 = f_t(y1); fz1 = f_t(z1)
        fx2 = f_t(x2); fy2 = f_t(y2); fz2 = f_t(z2)

        L1, a1, b1 = 116 * fy1 - 16, 500 * (fx1 - fy1), 200 * (fy1 - fz1)
        L2, a2, b2 = 116 * fy2 - 16, 500 * (fx2 - fy2), 200 * (fy2 - fz2)

        # Euclidean distance in Lab
        lab_dist = ((L1 - L2) ** 2 + (a1 - a2) ** 2 + (b1 - b2) ** 2) ** 0.5

        # Convert distance to compatibility score (cap at 255 typical distance)
        score = max(0.0, 1.0 - (lab_dist / 255.0))
        return round(min(score, 1.0), 4)
    except Exception:
        return 0.5  # Default neutral score


def generate_outfits_from_profile(appearance, color_profile, body_props, occasion: str = '') -> list:
    """
    Generate 3-5 outfit recommendations based on appearance profile.
    Returns list of dicts with: data (outfit details), score, scores breakdown, explanation.
    """
    try:
        # Determine seasonal palette
        seasonal_type = color_profile.seasonal_palette if color_profile.seasonal_palette else 'Universal'
        palette = get_seasonal_palette(seasonal_type)

        # Get body silhouette info
        silhouette = body_props.silhouette if body_props else ''
        shoulder_hip_ratio = body_props.shoulder_hip_ratio if body_props and body_props.shoulder_hip_ratio else 1.0

        # Base outfit templates compatible with SavedOutfit format
        outfit_templates = _get_outfit_templates(silhouette, shoulder_hip_ratio, palette, occasion)

        # Generate 3-5 recommendations
        n_recs = min(5, max(3, randint(3, 5)))
        recommendations = []

        # Sample templates, adding variety
        selected = sample(outfit_templates, min(n_recs, len(outfit_templates)))

        for i, template in enumerate(selected):
            # Add some randomization to scores for variety
            base_score = uniform(0.65, 0.95)
            scores = {
                'fit': round(uniform(0.7, 1.0), 3),
                'color_harmony': round(uniform(0.6, 1.0), 3),
                'appropriateness': round(uniform(0.65, 0.98), 3),
                'style_match': round(uniform(0.65, 0.95), 3),
            }
            overall = round(
                (scores['fit'] * 0.3 + scores['color_harmony'] * 0.25 + scores['appropriateness'] * 0.25 + scores['style_match'] * 0.2), 4
            )

            # Build explanation
            explanation = _build_explanation(template, silhouette, color_profile, body_props, occasion)

            # Format outfit data compatible with SavedOutfit
            outfit_data = {
                'name': template['name'],
                'style': template['style'],
                'occasion': template['occasion'],
                'items': template['items'],
                'colors': template['colors'],
                'notes': template['notes'],
            }

            recommendations.append({
                'data': outfit_data,
                'score': overall,
                'scores': scores,
                'explanation': explanation,
                'wardrobe_used': template.get('wardrobe_used', False),
            })

        return recommendations

    except Exception as e:
        logger.error(f"Outfit generation error: {e}", exc_info=True)
        # Return fallback outfits
        return [_fallback_outfit(silhouette, color_profile, occasion)]


def _get_outfit_templates(silhouette, shoulder_hip_ratio, palette, occasion):
    """Get base outfit templates adapted to body shape and color palette."""
    base_outfits = []

    # Template 1: Classic monochromatic look
    base_outfits.append({
        'name': 'Monochrome Sophistication',
        'style': 'Classic',
        'occasion': occasion or 'Casual',
        'items': ['White crew-neck tee', 'Dark indigo straight-leg jeans', 'White leather sneakers'],
        'colors': ['#FFFFFF', '#212121', palette['primary']],
        'notes': 'Monochrome styling elongates the figure; purple accent adds modern touch',
        'wardrobe_used': False,
    })

    # Template 2: Color-blocked casual
    base_outfits.append({
        'name': 'Color-Blocked Casual',
        'style': 'Casual',
        'occasion': occasion or 'Weekend',
        'items': ['Light wash denim jacket', 'Neutral t-shirt', palette['primary'] + ' accent socks, white high-tops'],
        'colors': [palette['primary'], '#FFD700', '#FFFFFF'],
        'notes': 'Color blocking draws attention; balance proportions based on silhouette',
        'wardrobe_used': False,
    })

    # Template 3: Smart casual with accent
    base_outfits.append({
        'name': 'Accent-Pop Smart Casual',
        'style': 'Smart Casual',
        'occasion': occasion or 'Business Casual',
        'items': ['Navy blazer', 'White button-down', 'Dark trousers', palette['accent'] + ' pocket square'],
        'colors': ['#000080', '#FFFFFF', palette['accent'], '#F0F0F0'],
        'notes': 'Navy + purple accent creates sophisticated contrast; fits most silhouettes',
        'wardrobe_used': False,
    })

    # Template 4: Seasonal palette outfit
    if seasonal_type := getattr(__import__('django.conf').settings, 'CURRENT_SEASONAL_TYPE', 'Universal'):
        base_outfits.append({
            'name': f'{seasonal_type} Seasonal Edit',
            'style': 'Seasonal',
            'occasion': occasion or 'Casual',
            'items': [f'{palette["primary"]} knit sweater', 'White shirt', 'Dark denim', 'Comfortable loafers'],
            'colors': [palette['primary'], palette['secondary'], '#FFFFFF', '#212121'],
            'notes': f'{seasonal_type} palette colors harmonize with your skin tone',
            'wardrobe_used': False,
        })

    # Template 5: Ratio-aware outfit (based on body proportions)
    if shoulder_hip_ratio and shoulder_hip_ratio > 1.1:
        # Inverted triangle - broad shoulders, narrow hips
        base_outfits.append({
            'name': 'Balanced Sport',
            'style': 'Sporty',
            'occasion': occasion or 'Casual',
            'items': ['V-neck tee (draws eye downward)', 'A-line jacket', 'Dark jeans', 'Boots'],
            'colors': ['#FFFFFF', palette['primary'], '#212121', '#E0E0E0'],
            'notes': 'V-neck and darker lower half balance broader shoulders',
            'wardrobe_used': False,
        })
    elif shoulder_hip_ratio and shoulder_hip_ratio < 0.9:
        # Triangle - narrow shoulders, wide hips
        base_outfits.append({
            'name': 'Shoulder-Empower',
            'style': 'Style',
            'occasion': occasion or 'Casual',
            'items': ['Off-shoulder or boat neck top', 'Light-colored jeans', 'Heels or sneakers'],
            'colors': [palette['primary'], '#FFFFFF', palette['secondary']],
            'notes': 'Adds visual width to shoulders; light lower half balances hips',
            'wardrobe_used': False,
        })

    return base_outfits


def _build_explanation(template, silhouette, color_profile, body_props, occasion):
    """Build human-readable explanation for the outfit recommendation."""
    parts = []

    # Occasion
    if occasion:
        parts.append(f'Perfect for {occasion.lower()}.')
    else:
        parts.append('Great for everyday wear.')

    # Color harmony
    primary = template['colors'][0] if template['colors'] else ''
    if color_profile and color_profile.seasonal_palette:
        parts.append(f'The {primary} color harmonizes with your {color_profile.seasonal_palette} seasonal palette.')
    else:
        parts.append(f'The {primary} color complements your features.')

    # Body proportion note
    if body_props and body_props.silhouette:
        sil = body_props.silhouette
        if sil == 'inverted_triangle' and 'V-neck' in str(template.get('items', [])):
            parts.append('The V-neck draws visual attention downward, balancing broader shoulders.')
        elif sil == 'triangle' and 'boat neck' in str(template.get('items', [])):
            parts.append('The boat neck adds visual width to your shoulders for balanced proportions.')

    # General style note
    parts.append(f'This {template["style"].lower()} style enhances your personal features.')

    return ' '.join(parts)


def _fallback_outfit(silhouette, color_profile, occasion):
    """Fallback outfit when generation fails."""
    palette = color_profile.primary_color if color_profile and color_profile.primary_color else '#7C4DFF'

    return {
        'data': {
            'name': 'Classic Neutral',
            'style': 'Classic',
            'occasion': occasion or 'Casual',
            'items': ['White t-shirt', 'Dark denim jeans', 'White sneakers', 'Navy blazer (optional)'],
            'colors': [palette, '#212121', '#FFFFFF'],
            'notes': 'Timeless combination that works for any occasion',
        },
        'score': 0.75,
        'scores': {
            'fit': 0.8,
            'color_harmony': 0.7,
            'appropriateness': 0.75,
            'style_match': 0.7,
        },
        'explanation': 'A timeless, versatile outfit in neutral colors that suits most body types and skin tones.',
        'wardrobe_used': False,
    }