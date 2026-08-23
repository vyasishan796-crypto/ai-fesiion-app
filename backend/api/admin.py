from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.html import format_html
from .models import (
    User, Product, PlatformPrice, Order,
    WishlistItem, BodyMeasurement, SavedOutfit, TailorBooking,
)


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['username', 'email', 'first_name', 'last_name', 'phone', 'is_staff', 'is_superuser', 'date_joined']
    list_filter = ['is_staff', 'is_superuser', 'date_joined']
    search_fields = ['username', 'email', 'first_name', 'last_name']
    fieldsets = BaseUserAdmin.fieldsets + (
        ('Profile', {'fields': ('phone', 'avatar', 'bio')}),
    )


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ['name', 'brand', 'category', 'price', 'rating', 'review_count', 'in_stock', 'platform', 'created_at']
    list_filter = ['category', 'platform', 'in_stock', 'brand']
    search_fields = ['name', 'brand', 'description']
    list_editable = ['price', 'in_stock']
    list_per_page = 20

    def get_queryset(self, request):
        return super().get_queryset(request).prefetch_related('platform_prices')


@admin.register(PlatformPrice)
class PlatformPriceAdmin(admin.ModelAdmin):
    list_display = ['product', 'platform', 'price', 'original_price', 'in_stock', 'delivery_days']
    list_filter = ['platform', 'in_stock']
    list_editable = ['price', 'in_stock']


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'total', 'status', 'payment_method', 'item_count', 'created_at']
    list_filter = ['status', 'payment_method', 'created_at']
    search_fields = ['user__username', 'user__email']
    list_editable = ['status']
    list_per_page = 20
    readonly_fields = ['created_at', 'updated_at']

    def item_count(self, obj):
        return sum(item.get('quantity', 1) for item in obj.items)
    item_count.short_description = 'Items'

    actions = ['mark_confirmed', 'mark_shipped', 'mark_delivered', 'mark_cancelled']

    def mark_confirmed(self, request, queryset):
        queryset.update(status='confirmed')
    mark_confirmed.short_description = 'Mark selected as Confirmed'

    def mark_shipped(self, request, queryset):
        queryset.update(status='shipped')
    mark_shipped.short_description = 'Mark selected as Shipped'

    def mark_delivered(self, request, queryset):
        queryset.update(status='delivered')
    mark_delivered.short_description = 'Mark selected as Delivered'

    def mark_cancelled(self, request, queryset):
        queryset.update(status='cancelled')
    mark_cancelled.short_description = 'Mark selected as Cancelled'


@admin.register(WishlistItem)
class WishlistItemAdmin(admin.ModelAdmin):
    list_display = ['user', 'product', 'created_at']
    list_filter = ['created_at']
    search_fields = ['user__username', 'product__name']


@admin.register(BodyMeasurement)
class BodyMeasurementAdmin(admin.ModelAdmin):
    list_display = ['user', 'height', 'weight', 'body_type', 'top_size', 'bottom_size', 'confidence']
    search_fields = ['user__username']


@admin.register(SavedOutfit)
class SavedOutfitAdmin(admin.ModelAdmin):
    list_display = ['user', 'name', 'style', 'occasion', 'is_ai_generated', 'created_at']
    list_filter = ['is_ai_generated', 'style']
    search_fields = ['user__username', 'name']


@admin.register(TailorBooking)
class TailorBookingAdmin(admin.ModelAdmin):
    list_display = ['user', 'tailor_name', 'service_type', 'estimated_price', 'booking_date', 'status']
    list_filter = ['status', 'service_type']
    search_fields = ['user__username', 'tailor_name']
    list_editable = ['status']
