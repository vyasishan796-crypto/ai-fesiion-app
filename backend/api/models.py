import json
from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    phone = models.CharField(max_length=15, blank=True, default='')
    avatar = models.URLField(blank=True, default='')
    bio = models.TextField(blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    groups = models.ManyToManyField(
        'auth.Group',
        verbose_name='groups',
        blank=True,
        help_text='The groups this user belongs to.',
        related_name='api_user_set',
        related_query_name='api_user',
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        verbose_name='user permissions',
        blank=True,
        help_text='Specific permissions for this user.',
        related_name='api_user_set',
        related_query_name='api_user',
    )

    def __str__(self):
        return self.username


class Product(models.Model):
    name = models.CharField(max_length=255)
    brand = models.CharField(max_length=100, blank=True, default='')
    category = models.CharField(max_length=100, default='clothing')
    description = models.TextField(blank=True, default='')
    image_url = models.URLField(blank=True, default='')
    price = models.DecimalField(max_digits=10, decimal_places=2)
    rating = models.FloatField(default=0.0)
    review_count = models.IntegerField(default=0)
    platform = models.CharField(max_length=50, default='local')
    sizes = models.JSONField(default=list, blank=True)
    colors = models.JSONField(default=list, blank=True)
    in_stock = models.BooleanField(default=True)
    tags = models.JSONField(default=list, blank=True)
    delivery_info = models.CharField(max_length=200, blank=True, default='Free delivery')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.brand} {self.name}" if self.brand else self.name


class PlatformPrice(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='platform_prices')
    platform = models.CharField(max_length=50)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    original_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    url = models.URLField(blank=True, default='')
    in_stock = models.BooleanField(default=True)
    rating = models.FloatField(null=True, blank=True)
    delivery_days = models.IntegerField(null=True, blank=True)

    class Meta:
        ordering = ['price']
        unique_together = ['product', 'platform']

    def __str__(self):
        return f"{self.product.name} @ {self.platform}: {self.price}"


class Order(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('shipped', 'Shipped'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='orders')
    items = models.JSONField(default=list)
    subtotal = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    tax = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    shipping = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    total = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    shipping_address = models.JSONField(default=dict, blank=True)
    payment_method = models.CharField(max_length=50, default='cod')
    notes = models.TextField(blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Order #{self.id} by {self.user.username}"


class WishlistItem(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='wishlist_items')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='wishlist_entries')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        unique_together = ['user', 'product']

    def __str__(self):
        return f"{self.user.username} -> {self.product.name}"


class BodyMeasurement(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='body_measurement')
    height = models.FloatField(null=True, blank=True, help_text='Height in cm')
    weight = models.FloatField(null=True, blank=True, help_text='Weight in kg')
    chest = models.FloatField(null=True, blank=True, help_text='Chest in cm')
    waist = models.FloatField(null=True, blank=True, help_text='Waist in cm')
    hips = models.FloatField(null=True, blank=True, help_text='Hips in cm')
    shoulder = models.FloatField(null=True, blank=True, help_text='Shoulder width in cm')
    arm_length = models.FloatField(null=True, blank=True, help_text='Arm length in cm')
    inseam = models.FloatField(null=True, blank=True, help_text='Inseam in cm')
    body_type = models.CharField(max_length=50, blank=True, default='')
    skin_tone = models.CharField(max_length=50, blank=True, default='')
    top_size = models.CharField(max_length=10, blank=True, default='')
    bottom_size = models.CharField(max_length=10, blank=True, default='')
    shoe_size = models.CharField(max_length=10, blank=True, default='')
    image_url = models.URLField(blank=True, default='')
    confidence = models.FloatField(default=0.0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Measurements for {self.user.username}"


class SavedOutfit(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='saved_outfits')
    name = models.CharField(max_length=200, blank=True, default='My Outfit')
    image_url = models.URLField(blank=True, default='')
    outfit_data = models.JSONField(default=dict)
    style = models.CharField(max_length=100, blank=True, default='')
    occasion = models.CharField(max_length=100, blank=True, default='')
    prompt = models.TextField(blank=True, default='')
    is_ai_generated = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} by {self.user.username}"


class TailorBooking(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]

    SERVICE_CHOICES = [
        ('alteration', 'Alteration'),
        ('custom_stitch', 'Custom Stitching'),
        ('repair', 'Repair'),
        ('embroidery', 'Embroidery'),
        ('other', 'Other'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tailor_bookings')
    tailor_name = models.CharField(max_length=200)
    tailor_address = models.CharField(max_length=500, blank=True, default='')
    tailor_phone = models.CharField(max_length=15, blank=True, default='')
    service_type = models.CharField(max_length=20, choices=SERVICE_CHOICES, default='alteration')
    description = models.TextField(blank=True, default='')
    estimated_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    booking_date = models.DateField()
    booking_time = models.TimeField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    notes = models.TextField(blank=True, default='')
    measurements_used = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Booking with {self.tailor_name} for {self.user.username}"


class VirtualTryOnGeneration(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('enhancing', 'Enhancing Prompt'),
        ('generating', 'Generating Image'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tryon_generations')
    outfit_id = models.CharField(max_length=100, blank=True, default='')
    product_ids = models.JSONField(default=list)
    user_prompt = models.TextField()
    user_image_url = models.URLField(blank=True, default='')
    result_image_url = models.URLField(blank=True, default='')
    enhanced_prompt = models.TextField(blank=True, default='')
    model_used = models.CharField(max_length=100, default='flux.2-klein-4b')
    qwen_model_used = models.CharField(max_length=100, default='qwen2.5-vl-7b-instruct')
    generation_time_ms = models.IntegerField(default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    error_message = models.TextField(blank=True, default='')
    metadata = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"TryOn #{self.id} by {self.user.username} - {self.status}"


# ─── Appearance Intelligence Models ───

class AppearanceAnalysis(models.Model):
    """Results from AI appearance analysis (skin tone, undertone, body proportions, color profile)."""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='appearance_analysis')
    version = models.CharField(max_length=20, default='appearance_v1')
    quality_score = models.FloatField(default=0.0, help_text='Image quality score 0-1')
    overall_confidence = models.FloatField(default=0.0, help_text='Overall analysis confidence 0-1')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Appearance Analysis'
        verbose_name_plural = 'Appearance Analyses'

    def __str__(self):
        return f"Appearance analysis for {self.user.username} (v{self.version})"


class SkinAnalysis(models.Model):
    """Detailed skin tone and undertone analysis."""
    appearance = models.OneToOneField(AppearanceAnalysis, on_delete=models.CASCADE, related_name='skin')
    tone = models.CharField(max_length=50, blank=True, default='')  # e.g., 'Warm', 'Cool', 'Neutral'
    undertone = models.CharField(max_length=50, blank=True, default='')  # e.g., 'Golden', 'Rosy', 'Neutral'
    tone_confidence = models.FloatField(default=0.0)
    undertone_confidence = models.FloatField(default=0.0)
    # CIELAB color space median values for valid skin pixels
    L_median = models.FloatField(null=True, blank=True)
    a_median = models.FloatField(null=True, blank=True)
    b_median = models.FloatField(null=True, blank=True)
    valid_pixel_count = models.IntegerField(null=True, blank=True)
    std_dev = models.FloatField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Skin Analysis'

    def __str__(self):
        return f"Skin: {self.tone}/{self.undertone} for {self.appearance.user.username}"


class BodyProportions(models.Model):
    """Body silhouette and proportion analysis."""
    appearance = models.OneToOneField(AppearanceAnalysis, on_delete=models.CASCADE, related_name='body_props')
    silhouette = models.CharField(max_length=50, blank=True, default='')  # e.g., 'pear', 'apple', 'hourglass'
    confidence = models.FloatField(default=0.0)
    # Key ratios
    shoulder_hip_ratio = models.FloatField(null=True, blank=True, help_text='Shoulder width / Hip width')
    torso_leg_ratio = models.FloatField(null=True, blank=True, help_text='Torso length / Leg length')
    upper_body_ratio = models.FloatField(null=True, blank=True, help_text='Upper body / Lower body')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Body Proportions'

    def __str__(self):
        return f"Body proportions for {self.appearance.user.username}"


class ColorProfile(models.Model):
    """Personal color profile derived from skin analysis."""
    appearance = models.OneToOneField(AppearanceAnalysis, on_delete=models.CASCADE, related_name='color_profile')
    primary_color = models.CharField(max_length=50, blank=True, default='')  # Hex e.g., '#FFB400'
    secondary_color = models.CharField(max_length=50, blank=True, default='')
    accent_color = models.CharField(max_length=50, blank=True, default='')  # Often the purple accent #7C4DFF
    contrast_level = models.CharField(max_length=20, blank=True, default='medium')  # low/medium/high
    seasonal_palette = models.CharField(max_length=50, blank=True, default='')  # e.g., 'Spring', 'Summer', 'Autumn', 'Winter'
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Color Profile'

    def __str__(self):
        return f"Color profile for {self.appearance.user.username}"


# ─── Outfit Recommendation Models ───

class OutfitRecommendation(models.Model):
    """Generated outfit recommendations based on appearance profile."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='outfit_recommendations')
    appearance = models.ForeignKey(AppearanceAnalysis, on_delete=models.CASCADE, related_name='outfit_recs')
    # Outfit data as JSON (compatible with existing SavedOutfit format)
    outfit_data = models.JSONField(default=dict, help_text='Outfit details JSON compatible with SavedOutfit')
    score = models.FloatField(default=0.0, help_text='Overall outfit score 0-1')
    # Scoring breakdown: fit, color_harmony, appropriateness, style_match
    scores = models.JSONField(default=dict, help_text={'fit': float, 'color_harmony': float, 'appropriateness': float, 'style_match': float})
    explanation = models.TextField(blank=True, default='')
    # Which wardrobe items were used (if any)
    wardrobe_used = models.BooleanField(default=False, help_text='Whether outfit uses user\'s digital wardrobe')
    occasion = models.CharField(max_length=100, blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-score']

    def __str__(self):
        return f"Outfit rec #{self.id} for {self.user.username} (score: {self.score:.2f})"


class UserInteraction(models.Model):
    """Track user interactions with outfits for preference learning."""
    INTERACTION_TYPES = [
        ('view', 'Viewed'),
        ('like', 'Liked'),
        ('dislike', 'Disliked'),
        ('save', 'Saved'),
        ('purchase', 'Purchase'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='interactions')
    outfit_recommendation = models.ForeignKey(OutfitRecommendation, on_delete=models.CASCADE, related_name='interactions')
    interaction_type = models.CharField(max_length=20, choices=INTERACTION_TYPES)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ['user', 'outfit_recommendation', 'interaction_type']

    def __str__(self):
        return f"{self.user.username} {self.interaction_type} outfit {self.outfit_recommendation.id}"



