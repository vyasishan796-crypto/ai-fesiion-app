from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAdminUser
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate, get_user_model
from django.db.models import Q, Min, Sum, Count
from django.shortcuts import get_object_or_404
from django.utils import timezone
from datetime import timedelta

from api.serializers import (
    UserSerializer, RegisterSerializer, LoginSerializer,
    ProductSerializer, ProductListSerializer, PlatformPriceSerializer,
    OrderSerializer, OrderCreateSerializer,
    WishlistItemSerializer, BodyMeasurementSerializer,
    SavedOutfitSerializer, TailorBookingSerializer,
)
from api.models import (
    Product, PlatformPrice, Order, WishlistItem,
    BodyMeasurement, SavedOutfit, TailorBooking,
)

User = get_user_model()


# ──────────────────────────────────────────────
# AUTH VIEWS
# ──────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response({
            'user': UserSerializer(user).data,
            'tokens': {
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            }
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        user = authenticate(
            username=serializer.validated_data['username'],
            password=serializer.validated_data['password']
        )
        if user:
            refresh = RefreshToken.for_user(user)
            return Response({
                'user': UserSerializer(user).data,
                'tokens': {
                    'access': str(refresh.access_token),
                    'refresh': str(refresh),
                }
            })
        return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def google_login_view(request):
    email = request.data.get('email')
    name = request.data.get('name', '')
    photo_url = request.data.get('photo_url', '')

    if not email:
        return Response({'error': 'Email is required'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        username = email.split('@')[0]
        base_username = username
        counter = 1
        while User.objects.filter(username=username).exists():
            username = f"{base_username}{counter}"
            counter += 1

        first_name = name.split()[0] if name else ''
        last_name = ' '.join(name.split()[1:]) if name and len(name.split()) > 1 else ''

        user = User.objects.create_user(
            username=username,
            email=email,
            first_name=first_name,
            last_name=last_name,
            avatar=photo_url,
        )

    refresh = RefreshToken.for_user(user)
    return Response({
        'user': UserSerializer(user).data,
        'tokens': {
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        }
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile_view(request):
    serializer = UserSerializer(request.user)
    return Response(serializer.data)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_profile_view(request):
    serializer = UserSerializer(request.user, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    try:
        refresh_token = request.data.get('refresh')
        if refresh_token:
            token = RefreshToken(refresh_token)
            token.blacklist()
    except Exception:
        pass
    return Response({'message': 'Logged out successfully'})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def token_refresh_view(request):
    refresh_token = request.data.get('refresh')
    if not refresh_token:
        return Response({'error': 'Refresh token required'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        token = RefreshToken(refresh_token)
        return Response({
            'access': str(token.access_token),
            'refresh': str(token),
        })
    except Exception:
        return Response({'error': 'Invalid refresh token'}, status=status.HTTP_401_UNAUTHORIZED)


# ──────────────────────────────────────────────
# PRODUCT VIEWS
# ──────────────────────────────────────────────

class ProductListView(generics.ListAPIView):
    serializer_class = ProductListSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        qs = Product.objects.all()
        category = self.request.query_params.get('category')
        search = self.request.query_params.get('q')
        min_price = self.request.query_params.get('min_price')
        max_price = self.request.query_params.get('max_price')
        in_stock = self.request.query_params.get('in_stock')
        sort = self.request.query_params.get('sort')

        if category:
            qs = qs.filter(category__iexact=category)
        if search:
            qs = qs.filter(
                Q(name__icontains=search) |
                Q(brand__icontains=search) |
                Q(description__icontains=search) |
                Q(tags__icontains=search)
            )
        if min_price:
            qs = qs.filter(price__gte=min_price)
        if max_price:
            qs = qs.filter(price__lte=max_price)
        if in_stock is not None:
            qs = qs.filter(in_stock=in_stock.lower() == 'true')
        if sort == 'price_low':
            qs = qs.annotate(min_price_val=Min('platform_prices__price')).order_by('min_price_val')
        elif sort == 'price_high':
            qs = qs.annotate(min_price_val=Min('platform_prices__price')).order_by('-min_price_val')
        elif sort == 'rating':
            qs = qs.order_by('-rating')
        elif sort == 'newest':
            qs = qs.order_by('-created_at')

        return qs


class ProductDetailView(generics.RetrieveAPIView):
    serializer_class = ProductSerializer
    permission_classes = [AllowAny]
    queryset = Product.objects.all()


class ProductSearchView(generics.ListAPIView):
    serializer_class = ProductListSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        q = self.request.query_params.get('q', '')
        if not q:
            return Product.objects.none()
        return Product.objects.filter(
            Q(name__icontains=q) |
            Q(brand__icontains=q) |
            Q(description__icontains=q) |
            Q(category__icontains=q)
        )


@api_view(['GET'])
@permission_classes([AllowAny])
def product_categories_view(request):
    categories = Product.objects.values_list('category', flat=True).distinct()
    return Response(list(categories))


@api_view(['GET'])
@permission_classes([AllowAny])
def product_prices_view(request, pk):
    product = get_object_or_404(Product, pk=pk)
    prices = product.platform_prices.all()
    serializer = PlatformPriceSerializer(prices, many=True)
    return Response({
        'product': ProductSerializer(product).data,
        'prices': serializer.data,
    })


# ──────────────────────────────────────────────
# ORDER VIEWS
# ──────────────────────────────────────────────

class OrderListView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(user=self.request.user)


class OrderDetailView(generics.RetrieveAPIView):
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(user=self.request.user)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def order_create_view(request):
    serializer = OrderCreateSerializer(data=request.data)
    if serializer.is_valid():
        import json as _json
        items = serializer.validated_data['items']
        for item in items:
            for k, v in item.items():
                if hasattr(v, '__float__'):
                    item[k] = float(v)
        subtotal = sum(
            float(item['price']) * item['quantity'] for item in items
        )
        tax = round(subtotal * 0.18, 2)
        shipping = 0 if subtotal > 500 else 49
        total = subtotal + tax + shipping

        order = Order.objects.create(
            user=request.user,
            items=items,
            subtotal=subtotal,
            tax=tax,
            shipping=shipping,
            total=total,
            shipping_address=serializer.validated_data.get('shipping_address', {}),
            payment_method=serializer.validated_data.get('payment_method', 'cod'),
            notes=serializer.validated_data.get('notes', ''),
        )
        return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def order_update_view(request, pk):
    order = get_object_or_404(Order, pk=pk, user=request.user)
    new_status = request.data.get('status')
    if new_status:
        valid_statuses = [c[0] for c in Order.STATUS_CHOICES]
        if new_status not in valid_statuses:
            return Response({'error': f'Invalid status. Choose from: {valid_statuses}'},
                          status=status.HTTP_400_BAD_REQUEST)
        order.status = new_status
        order.save()
    return Response(OrderSerializer(order).data)


# ──────────────────────────────────────────────
# WISHLIST VIEWS
# ──────────────────────────────────────────────

class WishlistListView(generics.ListAPIView):
    serializer_class = WishlistItemSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return WishlistItem.objects.filter(user=self.request.user).select_related('product')


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def wishlist_add_view(request):
    product_id = request.data.get('product_id')
    if not product_id:
        return Response({'error': 'product_id required'}, status=status.HTTP_400_BAD_REQUEST)

    product = get_object_or_404(Product, pk=product_id)
    item, created = WishlistItem.objects.get_or_create(user=request.user, product=product)

    if not created:
        return Response({'message': 'Already in wishlist', 'id': item.id})

    return Response(WishlistItemSerializer(item).data, status=status.HTTP_201_CREATED)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def wishlist_remove_view(request, pk):
    item = get_object_or_404(WishlistItem, pk=pk, user=request.user)
    item.delete()
    return Response({'message': 'Removed from wishlist'})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def wishlist_check_view(request, product_id):
    exists = WishlistItem.objects.filter(user=request.user, product_id=product_id).exists()
    return Response({'wishlisted': exists})


# ──────────────────────────────────────────────
# BODY MEASUREMENT VIEWS
# ──────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def measurement_get_view(request):
    try:
        measurement = BodyMeasurement.objects.get(user=request.user)
        return Response(BodyMeasurementSerializer(measurement).data)
    except BodyMeasurement.DoesNotExist:
        return Response(None)


@api_view(['POST', 'PUT'])
@permission_classes([IsAuthenticated])
def measurement_save_view(request):
    measurement, created = BodyMeasurement.objects.get_or_create(user=request.user)
    serializer = BodyMeasurementSerializer(measurement, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ──────────────────────────────────────────────
# SAVED OUTFIT VIEWS
# ──────────────────────────────────────────────

class SavedOutfitListView(generics.ListAPIView):
    serializer_class = SavedOutfitSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return SavedOutfit.objects.filter(user=self.request.user)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def saved_outfit_create_view(request):
    serializer = SavedOutfitSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(user=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def saved_outfit_delete_view(request, pk):
    outfit = get_object_or_404(SavedOutfit, pk=pk, user=request.user)
    outfit.delete()
    return Response({'message': 'Outfit removed'})


# ──────────────────────────────────────────────
# TAILOR BOOKING VIEWS
# ──────────────────────────────────────────────

class TailorBookingListView(generics.ListAPIView):
    serializer_class = TailorBookingSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return TailorBooking.objects.filter(user=self.request.user)


class TailorBookingDetailView(generics.RetrieveUpdateAPIView):
    serializer_class = TailorBookingSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return TailorBooking.objects.filter(user=self.request.user)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def tailor_booking_create_view(request):
    serializer = TailorBookingSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(user=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ──────────────────────────────────────────────
# SEED DATA VIEW
# ──────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([AllowAny])
def seed_data_view(request):
    products_data = [
        {
            'name': 'Oversized Graphic Tee', 'brand': 'H&M', 'category': 'tops',
            'description': 'Relaxed-fit cotton t-shirt with graphic print',
            'image_url': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500',
            'price': 999, 'rating': 4.3, 'review_count': 2847,
            'platform': 'Amazon', 'sizes': ['S', 'M', 'L', 'XL'],
            'colors': ['White', 'Black', 'Grey'], 'tags': ['casual', 'streetwear', 'oversized'],
            'delivery_info': 'Free delivery',
            'platform_prices': [
                {'platform': 'Amazon', 'price': 999, 'original_price': 1299, 'url': 'https://amazon.in', 'delivery_days': 2},
                {'platform': 'Flipkart', 'price': 899, 'original_price': 1199, 'url': 'https://flipkart.com', 'delivery_days': 3},
                {'platform': 'Myntra', 'price': 949, 'original_price': 1299, 'url': 'https://myntra.com', 'delivery_days': 2},
                {'platform': 'Meesho', 'price': 699, 'original_price': 999, 'url': 'https://meesho.com', 'delivery_days': 5},
            ],
        },
        {
            'name': 'Air Force 1 Low', 'brand': 'Nike', 'category': 'footwear',
            'description': 'Classic Nike Air Force 1 sneaker in white',
            'image_url': 'https://images.unsplash.com/photo-1600269452121-4f2416e55c28?w=500',
            'price': 8195, 'rating': 4.7, 'review_count': 5621,
            'platform': 'Nike', 'sizes': ['7', '8', '9', '10', '11'],
            'colors': ['White', 'Black'], 'tags': ['sneakers', 'casual', 'classic'],
            'delivery_info': 'Free delivery',
            'platform_prices': [
                {'platform': 'Nike', 'price': 8195, 'url': 'https://nike.com', 'delivery_days': 3},
                {'platform': 'Amazon', 'price': 7999, 'original_price': 8995, 'url': 'https://amazon.in', 'delivery_days': 2},
                {'platform': 'Flipkart', 'price': 7850, 'original_price': 8995, 'url': 'https://flipkart.com', 'delivery_days': 4},
                {'platform': 'Myntra', 'price': 8195, 'url': 'https://myntra.com', 'delivery_days': 3},
            ],
        },
        {
            'name': 'Slim Fit Chinos', 'brand': 'Levis', 'category': 'bottoms',
            'description': 'Classic slim fit chinos for men',
            'image_url': 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=500',
            'price': 2499, 'rating': 4.5, 'review_count': 1893,
            'platform': 'Amazon', 'sizes': ['28', '30', '32', '34', '36'],
            'colors': ['Khaki', 'Navy', 'Olive'], 'tags': ['casual', 'formal', 'chinos'],
            'delivery_info': 'Free delivery',
            'platform_prices': [
                {'platform': 'Amazon', 'price': 2499, 'original_price': 3299, 'url': 'https://amazon.in', 'delivery_days': 2},
                {'platform': 'Flipkart', 'price': 2299, 'original_price': 3299, 'url': 'https://flipkart.com', 'delivery_days': 3},
                {'platform': 'Myntra', 'price': 2199, 'original_price': 3299, 'url': 'https://myntra.com', 'delivery_days': 2},
                {'platform': 'Meesho', 'price': 1899, 'original_price': 2999, 'url': 'https://meesho.com', 'delivery_days': 5},
            ],
        },
        {
            'name': 'Floral Print Dress', 'brand': 'Zara', 'category': 'dresses',
            'description': 'Elegant floral print midi dress',
            'image_url': 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=500',
            'price': 3990, 'rating': 4.6, 'review_count': 743,
            'platform': 'Myntra', 'sizes': ['XS', 'S', 'M', 'L'],
            'colors': ['Blue Floral', 'Red Floral'], 'tags': ['party', 'elegant', 'floral'],
            'delivery_info': 'Free delivery',
            'platform_prices': [
                {'platform': 'Myntra', 'price': 3990, 'url': 'https://myntra.com', 'delivery_days': 2},
                {'platform': 'Amazon', 'price': 3850, 'original_price': 4500, 'url': 'https://amazon.in', 'delivery_days': 3},
                {'platform': 'Flipkart', 'price': 3750, 'original_price': 4200, 'url': 'https://flipkart.com', 'delivery_days': 4},
            ],
        },
        {
            'name': 'Running Shoes Gel-Kayano', 'brand': 'ASICS', 'category': 'footwear',
            'description': 'Premium running shoes with Gel cushioning',
            'image_url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
            'price': 12999, 'rating': 4.8, 'review_count': 1234,
            'platform': 'Amazon', 'sizes': ['7', '8', '9', '10'],
            'colors': ['Blue/Black', 'Grey/Green'], 'tags': ['running', 'sports', 'premium'],
            'delivery_info': 'Free delivery',
            'platform_prices': [
                {'platform': 'Amazon', 'price': 12999, 'original_price': 15999, 'url': 'https://amazon.in', 'delivery_days': 2},
                {'platform': 'Flipkart', 'price': 12499, 'original_price': 15999, 'url': 'https://flipkart.com', 'delivery_days': 3},
                {'platform': 'Myntra', 'price': 13200, 'url': 'https://myntra.com', 'delivery_days': 2},
            ],
        },
        {
            'name': 'Denim Jacket', 'brand': 'Wrangler', 'category': 'outerwear',
            'description': 'Classic denim jacket with vintage wash',
            'image_url': 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=500',
            'price': 3499, 'rating': 4.4, 'review_count': 982,
            'platform': 'Flipkart', 'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
            'colors': ['Blue', 'Black'], 'tags': ['casual', 'denim', 'vintage'],
            'delivery_info': 'Free delivery above 500',
            'platform_prices': [
                {'platform': 'Flipkart', 'price': 3499, 'original_price': 4999, 'url': 'https://flipkart.com', 'delivery_days': 3},
                {'platform': 'Amazon', 'price': 3299, 'original_price': 4599, 'url': 'https://amazon.in', 'delivery_days': 2},
                {'platform': 'Myntra', 'price': 3199, 'original_price': 4999, 'url': 'https://myntra.com', 'delivery_days': 2},
                {'platform': 'Meesho', 'price': 2499, 'original_price': 3999, 'url': 'https://meesho.com', 'delivery_days': 5},
            ],
        },
        {
            'name': 'Cotton Kurti', 'brand': 'Biba', 'category': 'ethnic',
            'description': 'Handblock printed cotton kurti',
            'image_url': 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=500',
            'price': 1299, 'rating': 4.2, 'review_count': 3456,
            'platform': 'Myntra', 'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
            'colors': ['Yellow', 'Pink', 'Green'], 'tags': ['ethnic', 'casual', 'cotton'],
            'delivery_info': 'Free delivery',
            'platform_prices': [
                {'platform': 'Myntra', 'price': 1299, 'original_price': 1799, 'url': 'https://myntra.com', 'delivery_days': 2},
                {'platform': 'Amazon', 'price': 1199, 'original_price': 1599, 'url': 'https://amazon.in', 'delivery_days': 2},
                {'platform': 'Meesho', 'price': 899, 'original_price': 1299, 'url': 'https://meesho.com', 'delivery_days': 5},
            ],
        },
        {
            'name': 'Formal Blazer', 'brand': 'Raymond', 'category': 'formal',
            'description': 'Slim fit premium wool blend blazer',
            'image_url': 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=500',
            'price': 8995, 'rating': 4.7, 'review_count': 456,
            'platform': 'Amazon', 'sizes': ['38', '40', '42', '44'],
            'colors': ['Navy', 'Charcoal', 'Black'], 'tags': ['formal', 'premium', 'blazer'],
            'delivery_info': 'Free delivery',
            'platform_prices': [
                {'platform': 'Amazon', 'price': 8995, 'original_price': 12999, 'url': 'https://amazon.in', 'delivery_days': 3},
                {'platform': 'Flipkart', 'price': 8750, 'original_price': 11999, 'url': 'https://flipkart.com', 'delivery_days': 4},
                {'platform': 'Myntra', 'price': 8995, 'url': 'https://myntra.com', 'delivery_days': 2},
            ],
        },
        {
            'name': 'High Rise Jeans', 'brand': 'Levis', 'category': 'bottoms',
            'description': 'Premium high-rise skinny jeans for women',
            'image_url': 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=500',
            'price': 3299, 'rating': 4.5, 'review_count': 2341,
            'platform': 'Myntra', 'sizes': ['24', '26', '28', '30', '32'],
            'colors': ['Dark Wash', 'Light Wash', 'Black'], 'tags': ['jeans', 'casual', 'skinny'],
            'delivery_info': 'Free delivery',
            'platform_prices': [
                {'platform': 'Myntra', 'price': 3299, 'original_price': 4199, 'url': 'https://myntra.com', 'delivery_days': 2},
                {'platform': 'Amazon', 'price': 3199, 'original_price': 3999, 'url': 'https://amazon.in', 'delivery_days': 3},
                {'platform': 'Flipkart', 'price': 2999, 'original_price': 3999, 'url': 'https://flipkart.com', 'delivery_days': 4},
                {'platform': 'Meesho', 'price': 2499, 'original_price': 3499, 'url': 'https://meesho.com', 'delivery_days': 5},
            ],
        },
        {
            'name': 'Leather Crossbody Bag', 'brand': 'Hidesign', 'category': 'accessories',
            'description': 'Handcrafted leather crossbody bag',
            'image_url': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=500',
            'price': 4995, 'rating': 4.6, 'review_count': 678,
            'platform': 'Amazon', 'sizes': ['One Size'],
            'colors': ['Tan', 'Black', 'Brown'], 'tags': ['bag', 'leather', 'premium'],
            'delivery_info': 'Free delivery',
            'platform_prices': [
                {'platform': 'Amazon', 'price': 4995, 'original_price': 6995, 'url': 'https://amazon.in', 'delivery_days': 2},
                {'platform': 'Flipkart', 'price': 4750, 'original_price': 6500, 'url': 'https://flipkart.com', 'delivery_days': 3},
                {'platform': 'Myntra', 'price': 4995, 'url': 'https://myntra.com', 'delivery_days': 2},
            ],
        },
    ]

    created_count = 0
    for pdata in products_data:
        pp_data = pdata.pop('platform_prices', [])
        product, created = Product.objects.get_or_create(
            name=pdata['name'],
            brand=pdata['brand'],
            defaults=pdata,
        )
        if created:
            created_count += 1
            for pp in pp_data:
                PlatformPrice.objects.create(product=product, **pp)

    return Response({
        'message': f'Seeded {created_count} products with platform prices',
        'total_products': Product.objects.count(),
        'total_prices': PlatformPrice.objects.count(),
    })


# ──────────────────────────────────────────────
# ADMIN VIEWS
# ──────────────────────────────────────────────

def _admin_check(request):
    if not request.user.is_authenticated or not request.user.is_superuser:
        return False
    return True


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def admin_stats_view(request):
    if not request.user.is_superuser:
        return Response({'error': 'Admin access required'}, status=status.HTTP_403_FORBIDDEN)

    now = timezone.now()
    last_30_days = now - timedelta(days=30)
    last_7_days = now - timedelta(days=7)

    total_users = User.objects.count()
    total_orders = Order.objects.count()
    total_products = Product.objects.count()
    total_revenue = Order.objects.filter(status__in=['confirmed', 'shipped', 'delivered']).aggregate(total=Sum('total'))['total'] or 0

    orders_last_30 = Order.objects.filter(created_at__gte=last_30_days).count()
    orders_last_7 = Order.objects.filter(created_at__gte=last_7_days).count()
    revenue_last_30 = Order.objects.filter(created_at__gte=last_30_days, status__in=['confirmed', 'shipped', 'delivered']).aggregate(total=Sum('total'))['total'] or 0

    pending_orders = Order.objects.filter(status='pending').count()
    shipped_orders = Order.objects.filter(status='shipped').count()
    delivered_orders = Order.objects.filter(status='delivered').count()
    cancelled_orders = Order.objects.filter(status='cancelled').count()

    recent_orders = OrderSerializer(
        Order.objects.all()[:10], many=True
    ).data

    top_brands = Product.objects.values('brand').annotate(
        count=Count('id')
    ).order_by('-count')[:5]

    category_stats = Product.objects.values('category').annotate(
        count=Count('id')
    ).order_by('-count')

    return Response({
        'total_users': total_users,
        'total_orders': total_orders,
        'total_products': total_products,
        'total_revenue': float(total_revenue),
        'orders_last_30_days': orders_last_30,
        'orders_last_7_days': orders_last_7,
        'revenue_last_30_days': float(revenue_last_30),
        'pending_orders': pending_orders,
        'shipped_orders': shipped_orders,
        'delivered_orders': delivered_orders,
        'cancelled_orders': cancelled_orders,
        'recent_orders': recent_orders,
        'top_brands': list(top_brands),
        'category_stats': list(category_stats),
    })


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def admin_product_list_create(request):
    if not request.user.is_superuser:
        return Response({'error': 'Admin access required'}, status=status.HTTP_403_FORBIDDEN)

    if request.method == 'GET':
        search = request.query_params.get('q', '')
        category = request.query_params.get('category', '')
        qs = Product.objects.all()
        if search:
            qs = qs.filter(Q(name__icontains=search) | Q(brand__icontains=search))
        if category:
            qs = qs.filter(category__iexact=category)
        serializer = ProductSerializer(qs, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        data = request.data.copy()
        pp_data = data.pop('platform_prices', [])
        serializer = ProductSerializer(data=data)
        if serializer.is_valid():
            product = serializer.save()
            for pp in pp_data:
                PlatformPrice.objects.create(product=product, **pp)
            return Response(ProductSerializer(product).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
def admin_product_detail_update_delete(request, pk):
    if not request.user.is_superuser:
        return Response({'error': 'Admin access required'}, status=status.HTTP_403_FORBIDDEN)

    product = get_object_or_404(Product, pk=pk)

    if request.method == 'GET':
        return Response(ProductSerializer(product).data)

    elif request.method == 'PUT':
        data = request.data.copy()
        pp_data = data.pop('platform_prices', None)
        serializer = ProductSerializer(product, data=data, partial=True)
        if serializer.is_valid():
            product = serializer.save()
            if pp_data is not None:
                product.platform_prices.all().delete()
                for pp in pp_data:
                    PlatformPrice.objects.create(product=product, **pp)
            return Response(ProductSerializer(product).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        product.delete()
        return Response({'message': 'Product deleted'}, status=status.HTTP_204_NO_CONTENT)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def admin_order_list(request):
    if not request.user.is_superuser:
        return Response({'error': 'Admin access required'}, status=status.HTTP_403_FORBIDDEN)

    order_status = request.query_params.get('status', '')
    qs = Order.objects.all()
    if order_status:
        qs = qs.filter(status=order_status)
    serializer = OrderSerializer(qs[:50], many=True)
    return Response(serializer.data)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def admin_order_status_update(request, pk):
    if not request.user.is_superuser:
        return Response({'error': 'Admin access required'}, status=status.HTTP_403_FORBIDDEN)

    order = get_object_or_404(Order, pk=pk)
    new_status = request.data.get('status')
    if new_status:
        valid_statuses = [c[0] for c in Order.STATUS_CHOICES]
        if new_status not in valid_statuses:
            return Response({'error': f'Invalid status. Choose from: {valid_statuses}'},
                          status=status.HTTP_400_BAD_REQUEST)
        order.status = new_status
        order.save()
    return Response(OrderSerializer(order).data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def admin_user_list(request):
    if not request.user.is_superuser:
        return Response({'error': 'Admin access required'}, status=status.HTTP_403_FORBIDDEN)

    users = User.objects.all().order_by('-date_joined')
    data = []
    for u in users:
        data.append({
            'id': u.id,
            'username': u.username,
            'email': u.email,
            'first_name': u.first_name,
            'last_name': u.last_name,
            'phone': u.phone,
            'is_staff': u.is_staff,
            'is_superuser': u.is_superuser,
            'date_joined': u.date_joined,
            'order_count': u.orders.count(),
        })
    return Response(data)
