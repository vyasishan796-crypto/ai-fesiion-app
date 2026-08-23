from django.urls import path
from . import views
from .views import virtual_tryon, shoes_outfit, style_analyze
from .views.appearance_analyze import appearance_analyze, appearance_detail
from .views.outfit_recommend import outfit_recommend, user_interaction

urlpatterns = [
    # Auth
    path('auth/register/', views.register_view, name='register'),
    path('auth/login/', views.login_view, name='login'),
    path('auth/google/', views.google_login_view, name='google_login'),
    path('auth/logout/', views.logout_view, name='logout'),
    path('auth/profile/', views.profile_view, name='profile'),
    path('auth/profile/update/', views.update_profile_view, name='update_profile'),
    path('auth/token/refresh/', views.token_refresh_view, name='token_refresh'),

    # Products
    path('products/', views.ProductListView.as_view(), name='product_list'),
    path('products/search/', views.ProductSearchView.as_view(), name='product_search'),
    path('products/categories/', views.product_categories_view, name='product_categories'),
    path('products/<int:pk>/', views.ProductDetailView.as_view(), name='product_detail'),
    path('products/<int:pk>/prices/', views.product_prices_view, name='product_prices'),

    # Virtual Try-On
    path('virtual-tryon/', virtual_tryon.virtual_tryon_generate, name='virtual_tryon_generate'),
    path('virtual-tryon/history/', virtual_tryon.virtual_tryon_history, name='virtual_tryon_history'),
    path('virtual-tryon/<int:pk>/', virtual_tryon.virtual_tryon_detail, name='virtual_tryon_detail'),

    # Shoes → Outfit AI
    path('shoes-outfit/', shoes_outfit.shoes_outfit_generate, name='shoes_outfit_generate'),

    # Style Analyzer (100% Real via NVIDIA Queen Qwen)
    path('style-analyze/', style_analyze.style_analyze, name='style_analyze'),
    path('style-analyze/ask/', style_analyze.style_ask, name='style_ask'),

    # Orders
    path('orders/', views.OrderListView.as_view(), name='order_list'),
    path('orders/create/', views.order_create_view, name='order_create'),
    path('orders/<int:pk>/', views.OrderDetailView.as_view(), name='order_detail'),
    path('orders/<int:pk>/status/', views.order_update_view, name='order_update'),

    # Wishlist
    path('wishlist/', views.WishlistListView.as_view(), name='wishlist_list'),
    path('wishlist/add/', views.wishlist_add_view, name='wishlist_add'),
    path('wishlist/<int:pk>/', views.wishlist_remove_view, name='wishlist_remove'),
    path('wishlist/check/<int:product_id>/', views.wishlist_check_view, name='wishlist_check'),

    # Body Measurements
    path('measurements/', views.measurement_get_view, name='measurement_get'),
    path('measurements/save/', views.measurement_save_view, name='measurement_save'),

    # Appearance Intelligence
    path('appearance/analyze/', appearance_analyze, name='appearance_analyze'),
    path('appearance/<int:pk>/', appearance_detail, name='appearance_detail'),

    # Outfit Recommendations
    path('outfits/recommend/', outfit_recommend, name='outfit_recommend'),
    path('outfits/interaction/', user_interaction, name='user_interaction'),

    # Saved Outfits
    path('saved-outfits/', views.SavedOutfitListView.as_view(), name='saved_outfit_list'),
    path('saved-outfits/create/', views.saved_outfit_create_view, name='saved_outfit_create'),
    path('saved-outfits/<int:pk>/', views.saved_outfit_delete_view, name='saved_outfit_delete'),

    # Tailor Bookings
    path('bookings/', views.TailorBookingListView.as_view(), name='booking_list'),
    path('bookings/create/', views.tailor_booking_create_view, name='booking_create'),
    path('bookings/<int:pk>/', views.TailorBookingDetailView.as_view(), name='booking_detail'),

    # Seed
    path('seed/', views.seed_data_view, name='seed_data'),

    # Admin
    path('admin/stats/', views.admin_stats_view, name='admin_stats'),
    path('admin/products/', views.admin_product_list_create, name='admin_product_list'),
    path('admin/products/<int:pk>/', views.admin_product_detail_update_delete, name='admin_product_detail'),
    path('admin/orders/', views.admin_order_list, name='admin_order_list'),
    path('admin/orders/<int:pk>/status/', views.admin_order_status_update, name='admin_order_status'),
    path('admin/users/', views.admin_user_list, name='admin_user_list'),
]
