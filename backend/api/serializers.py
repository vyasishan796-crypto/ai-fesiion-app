from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import (
    Product, PlatformPrice, Order, WishlistItem,
    BodyMeasurement, SavedOutfit, TailorBooking,
    VirtualTryOnGeneration,
    AppearanceAnalysis, SkinAnalysis, BodyProportions,
    ColorProfile, OutfitRecommendation, UserInteraction,
)

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'phone', 'avatar', 'bio']
        read_only_fields = ['id']


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    password_confirm = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password_confirm', 'first_name', 'last_name', 'phone']

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError({'password_confirm': 'Passwords do not match'})
        return data

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        return user


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField()


class PlatformPriceSerializer(serializers.ModelSerializer):
    savings = serializers.SerializerMethodField()
    has_discount = serializers.SerializerMethodField()

    class Meta:
        model = PlatformPrice
        fields = [
            'id', 'platform', 'price', 'original_price', 'url',
            'in_stock', 'rating', 'delivery_days', 'savings', 'has_discount',
        ]

    def get_savings(self, obj):
        if obj.original_price and obj.original_price > obj.price:
            return float(obj.original_price - obj.price)
        return 0

    def get_has_discount(self, obj):
        return bool(obj.original_price and obj.original_price > obj.price)


class ProductSerializer(serializers.ModelSerializer):
    platform_prices = PlatformPriceSerializer(many=True, read_only=True)
    best_price = serializers.SerializerMethodField()
    cheapest_platform = serializers.SerializerMethodField()
    has_multi_platform = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'brand', 'category', 'description', 'image_url',
            'price', 'rating', 'review_count', 'platform', 'sizes', 'colors',
            'in_stock', 'tags', 'delivery_info', 'platform_prices',
            'best_price', 'cheapest_platform', 'has_multi_platform',
            'created_at', 'updated_at',
        ]

    def get_best_price(self, obj):
        prices = obj.platform_prices.all()
        if prices:
            return float(prices.first().price)
        return float(obj.price)

    def get_cheapest_platform(self, obj):
        prices = obj.platform_prices.all()
        if prices:
            return prices.first().platform
        return obj.platform

    def get_has_multi_platform(self, obj):
        return obj.platform_prices.count() > 1


class ProductListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = [
            'id', 'name', 'brand', 'category', 'image_url',
            'price', 'rating', 'review_count', 'platform', 'in_stock',
            'delivery_info', 'created_at',
        ]


class OrderItemSerializer(serializers.Serializer):
    product_id = serializers.IntegerField()
    name = serializers.CharField()
    brand = serializers.CharField(required=False, default='')
    image_url = serializers.CharField(required=False, default='')
    size = serializers.CharField(required=False, default='')
    color = serializers.CharField(required=False, default='')
    quantity = serializers.IntegerField(min_value=1)
    price = serializers.DecimalField(max_digits=10, decimal_places=2)


class OrderSerializer(serializers.ModelSerializer):
    items_detail = OrderItemSerializer(source='items', many=True, read_only=True)
    item_count = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = [
            'id', 'items', 'items_detail', 'item_count', 'subtotal', 'tax',
            'shipping', 'total', 'status', 'shipping_address', 'payment_method',
            'notes', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_item_count(self, obj):
        return sum(item.get('quantity', 1) for item in obj.items)


class OrderCreateSerializer(serializers.Serializer):
    items = OrderItemSerializer(many=True)
    shipping_address = serializers.JSONField(required=False, default=dict)
    payment_method = serializers.CharField(required=False, default='cod')
    notes = serializers.CharField(required=False, default='')

    def validate_items(self, value):
        if not value:
            raise serializers.ValidationError('Order must have at least one item')
        return value


class WishlistItemSerializer(serializers.ModelSerializer):
    product = ProductListSerializer(read_only=True)
    product_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = WishlistItem
        fields = ['id', 'product', 'product_id', 'created_at']
        read_only_fields = ['id', 'created_at']


class BodyMeasurementSerializer(serializers.ModelSerializer):
    class Meta:
        model = BodyMeasurement
        fields = [
            'id', 'height', 'weight', 'chest', 'waist', 'hips', 'shoulder',
            'arm_length', 'inseam', 'body_type', 'skin_tone', 'top_size',
            'bottom_size', 'shoe_size', 'image_url', 'confidence',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class SavedOutfitSerializer(serializers.ModelSerializer):
    class Meta:
        model = SavedOutfit
        fields = [
            'id', 'name', 'image_url', 'outfit_data', 'style', 'occasion',
            'prompt', 'is_ai_generated', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class TailorBookingSerializer(serializers.ModelSerializer):
    class Meta:
        model = TailorBooking
        fields = [
            'id', 'tailor_name', 'tailor_address', 'tailor_phone',
            'service_type', 'description', 'estimated_price', 'booking_date',
            'booking_time', 'status', 'notes', 'measurements_used',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class VirtualTryOnGenerationSerializer(serializers.ModelSerializer):
    class Meta:
        model = VirtualTryOnGeneration
        fields = [
            'id', 'outfit_id', 'product_ids', 'user_prompt', 'user_image_url',
            'result_image_url', 'enhanced_prompt', 'model_used', 'qwen_model_used',
            'generation_time_ms', 'status', 'error_message', 'metadata', 'created_at',
        ]
        read_only_fields = [
            'id', 'enhanced_prompt', 'result_image_url', 'model_used',
            'qwen_model_used', 'generation_time_ms', 'status',
            'error_message', 'metadata', 'created_at',
        ]


class VirtualTryOnRequestSerializer(serializers.Serializer):
    user_image_base64 = serializers.CharField()
    product_ids = serializers.ListField(child=serializers.CharField(), min_length=1)
    user_prompt = serializers.CharField(max_length=1000)
    outfit_id = serializers.CharField(max_length=100, required=False, allow_blank=True)
    seed = serializers.IntegerField(required=False, min_value=0, max_value=999999)


# ─── Appearance Intelligence Serializers ───

class AppearanceAnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = AppearanceAnalysis
        fields = [
            'id', 'user', 'version', 'quality_score', 'overall_confidence',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']


class SkinAnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = SkinAnalysis
        fields = [
            'id', 'appearance', 'tone', 'undertone', 'tone_confidence',
            'undertone_confidence', 'L_median', 'a_median', 'b_median',
            'valid_pixel_count', 'std_dev', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'appearance', 'created_at', 'updated_at']


class BodyProportionsSerializer(serializers.ModelSerializer):
    class Meta:
        model = BodyProportions
        fields = [
            'id', 'appearance', 'silhouette', 'confidence',
            'shoulder_hip_ratio', 'torso_leg_ratio', 'upper_body_ratio',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'appearance', 'created_at', 'updated_at']


class ColorProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = ColorProfile
        fields = [
            'id', 'appearance', 'primary_color', 'secondary_color',
            'accent_color', 'contrast_level', 'seasonal_palette',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'appearance', 'created_at', 'updated_at']


class OutfitRecommendationSerializer(serializers.ModelSerializer):
    class Meta:
        model = OutfitRecommendation
        fields = [
            'id', 'user', 'appearance', 'outfit_data', 'score', 'scores',
            'explanation', 'wardrobe_used', 'occasion', 'created_at',
        ]
        read_only_fields = ['id', 'user', 'created_at']


class UserInteractionSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserInteraction
        fields = [
            'id', 'user', 'outfit_recommendation', 'interaction_type', 'created_at',
        ]
        read_only_fields = ['id', 'user', 'created_at']



