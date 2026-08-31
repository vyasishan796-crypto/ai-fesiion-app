import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/main_shell.dart';
import 'features/ai_studio/ai_studio_screen.dart';
import 'features/virtual_tryon/virtual_tryon_screen.dart';
import 'features/body_scan/body_scan_screen.dart';
import 'features/outfit_browser/outfit_browser_screen.dart';
import 'features/stylist_chat/stylist_chat_screen.dart';
import 'features/marketplace/marketplace_screen.dart';
import 'features/tailors/tailors_screen.dart';
import 'features/my_orders/my_orders_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/style_analyzer/style_analyzer_screen.dart';
import 'features/appearance/appearance_capture_screen.dart';
import 'features/appearance/appearance_result_screen.dart';
import 'features/body_scanner/body_scanner_landing.dart';
import 'features/body_scanner/scan_preparation.dart';
import 'features/body_scanner/body_scanner_camera.dart';
import 'features/body_scanner/scan_quality_screen.dart';
import 'features/body_scanner/scan_processing_screen.dart';
import 'features/body_scanner/fit_profile_result.dart';
import 'features/body_scanner/measurement_editor.dart';
import 'features/body_scanner/privacy_center.dart';
import 'features/body_scanner/outfit_personalization.dart';
import 'features/body_measurement/upload_screen.dart';
import 'features/body_measurement/guided_scan_mode.dart';
import 'features/body_measurement/image_quality_screen.dart';
import 'features/body_measurement/ai_processing_screen.dart';
import 'features/body_measurement/measurement_result_screen.dart';
import 'features/body_measurement/measurement_editing_screen.dart';
import 'features/body_measurement/size_recommendation_screen.dart';
import 'features/body_measurement/outfit_recommendation_screen.dart';
import 'features/body_measurement/privacy_screen.dart';
import 'features/profile/saved_looks_screen.dart';
import 'features/profile/addresses_screen.dart';
import 'features/profile/payment_methods_screen.dart';
import 'features/profile/invite_earn_screen.dart';
import 'features/profile/help_support_screen.dart';
import 'features/profile/settings_screen.dart';
import 'features/marketplace/outfit_marketplace_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/cart/checkout_screen.dart';
import 'features/my_orders/order_confirmation_screen.dart';
import 'features/my_orders/order_detail_screen.dart';
import 'features/tailors/my_bookings_screen.dart';
import 'features/tailors/booking_payment_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/profile/wishlist_screen.dart';
import 'features/marketplace/upload_product_screen.dart';
import 'features/style_quiz/style_quiz_screen.dart';
import 'features/admin/admin_dashboard.dart';
import 'features/admin/product_manager.dart';
import 'features/admin/order_manager.dart';
import 'features/admin/user_list.dart';
import 'features/shoes_outfit/screens/shoes_outfit_screen.dart';
import 'features/not_found_screen.dart';

import 'core/services/auth_service.dart';
import 'core/services/style_profile_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/cart_service.dart';
import 'core/services/order_service.dart';
import 'core/data/outfit_data.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await AuthService.init();
  await StyleProfileService().init();
  final notifService = NotificationService();
  await notifService.init();
  await OutfitData.loadProducts();
  await CartService().loadCart();
  await OrderService().loadOrders();
  runApp(const AIFashionApp());
}

class AIFashionApp extends StatelessWidget {
  const AIFashionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp.router(
          title: 'StyleAI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          routerConfig: _router,
        );
      },
    );
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'ai-studio',
                  builder: (context, state) => const AiStudioScreen(),
                ),
                GoRoute(
                  path: 'virtual-tryon',
                  builder: (context, state) => const VirtualTryOnScreen(),
                ),
                GoRoute(
                  path: 'body-scan',
                  builder: (context, state) => const BodyScanScreen(),
                ),
                GoRoute(
                  path: 'browse-outfits',
                  builder: (context, state) => const OutfitBrowserScreen(),
                ),
                GoRoute(
                  path: 'stylist-chat',
                  builder: (context, state) => const StylistChatScreen(),
                ),
                GoRoute(
                  path: 'style-analyzer',
                  builder: (context, state) => const StyleAnalyzerScreen(),
                ),
                GoRoute(
                  path: 'style-quiz',
                  builder: (context, state) => const StyleQuizScreen(),
                ),
                GoRoute(
                  path: 'tailors',
                  builder: (context, state) => const TailorsScreen(),
                ),
                GoRoute(
                  path: 'invite-earn',
                  builder: (context, state) => const InviteEarnScreen(),
                ),
                GoRoute(
                  path: 'body-scanner',
                  builder: (context, state) => const BodyScannerLanding(),
                ),
                GoRoute(
                  path: 'body-scan/preparation',
                  builder: (context, state) => const ScanPreparation(),
                ),
                GoRoute(
                  path: 'body-scan/camera',
                  builder: (context, state) => const BodyScannerCamera(),
                ),
                GoRoute(
                  path: 'body-scan/quality',
                  builder: (context, state) => const ScanQualityScreen(),
                ),
                GoRoute(
                  path: 'body-scan/processing',
                  builder: (context, state) => const ScanProcessingScreen(),
                ),
                GoRoute(
                  path: 'body-scan/result',
                  builder: (context, state) => const FitProfileResult(),
                ),
                GoRoute(
                  path: 'body-scan/measurements',
                  builder: (context, state) => const MeasurementEditor(),
                ),
                GoRoute(
                  path: 'body-scan/privacy',
                  builder: (context, state) => const PrivacyCenter(),
                ),
                GoRoute(
                  path: 'body-scan/personalization',
                  builder: (context, state) => const OutfitPersonalization(),
                ),
                GoRoute(
                  path: 'body-measurement/upload',
                  builder: (context, state) => const BodyMeasurementUpload(),
                ),
                GoRoute(
                  path: 'body-measurement/guided',
                  builder: (context, state) => const GuidedScanMode(),
                ),
                GoRoute(
                  path: 'body-measurement/quality',
                  builder: (context, state) => const ImageQualityScreen(),
                ),
                GoRoute(
                  path: 'body-measurement/processing',
                  builder: (context, state) => const AIProcessingScreen(),
                ),
                GoRoute(
                  path: 'body-measurement/result',
                  builder: (context, state) => const MeasurementResultScreen(),
                ),
                GoRoute(
                  path: 'body-measurement/editing',
                  builder: (context, state) => const MeasurementEditingScreen(),
                ),
                GoRoute(
                  path: 'body-measurement/size-recommendation',
                  builder: (context, state) => const SizeRecommendationScreen(),
                ),
                GoRoute(
                  path: 'body-measurement/outfit-recommendation',
                  builder: (context, state) => const OutfitRecommendationScreen(),
                ),
                GoRoute(
                  path: 'body-measurement/privacy',
                  builder: (context, state) => const BodyMeasurementPrivacyScreen(),
                ),
                GoRoute(
                  path: 'appearance/capture',
                  builder: (context, state) => const AppearanceCaptureScreen(),
                ),
                GoRoute(
                  path: 'appearance/result',
                  builder: (context, state) {
                    final analysisId = state.extra as String? ?? '';
                    return AppearanceResultScreen(analysisId: analysisId);
                  },
                ),
                GoRoute(
                  path: 'outfit-collection',
                  builder: (context, state) => const OutfitMarketplaceScreen(),
                ),
                GoRoute(
                  path: 'shoes-outfit',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return ShoesOutfitScreen(initialShoes: extra?['product']);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 1: Tailors
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tailors',
              builder: (context, state) => const TailorsScreen(),
              routes: [
                GoRoute(
                  path: 'my-bookings',
                  builder: (context, state) => const MyBookingsScreen(),
                ),
                GoRoute(
                  path: 'booking-payment',
                  builder: (context, state) {
                    final data = state.extra as Map<String, dynamic>? ?? {};
                    return BookingPaymentScreen(
                      tailor: data['tailor'],
                      serviceType: data['serviceType'],
                      date: data['date'],
                      timeSlot: data['timeSlot'] ?? '',
                      notes: data['notes'] ?? '',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 2: Market
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/marketplace',
              builder: (context, state) {
                final searchQuery = state.uri.queryParameters['search'] ?? '';
                return MarketplaceScreen(initialSearch: searchQuery);
              },
              routes: [
                GoRoute(
                  path: 'upload-product',
                  builder: (context, state) => const UploadProductScreen(),
                ),
                GoRoute(
                  path: 'cart',
                  builder: (context, state) => const CartScreen(),
                ),
                GoRoute(
                  path: 'checkout',
                  builder: (context, state) => const CheckoutScreen(),
                ),
                GoRoute(
                  path: 'outfit-collection',
                  builder: (context, state) => const OutfitMarketplaceScreen(),
                ),
              ],
            ),
          ],
        ),
        // Tab 3: Orders
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const MyOrdersScreen(),
              routes: [
                GoRoute(
                  path: 'order-confirmation',
                  builder: (context, state) {
                    final orderId = state.extra as String? ?? '';
                    return OrderConfirmationScreen(orderId: orderId);
                  },
                ),
                GoRoute(
                  path: 'order-detail',
                  builder: (context, state) {
                    final orderId = state.extra as String? ?? '';
                    return OrderDetailScreen(orderId: orderId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit-profile',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'saved-looks',
                  builder: (context, state) => const SavedLooksScreen(),
                ),
                GoRoute(
                  path: 'wishlist',
                  builder: (context, state) => const WishlistScreen(),
                ),
                GoRoute(
                  path: 'addresses',
                  builder: (context, state) => const AddressesScreen(),
                ),
                GoRoute(
                  path: 'payment-methods',
                  builder: (context, state) => const PaymentMethodsScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'help-support',
                  builder: (context, state) => const HelpSupportScreen(),
                ),
                GoRoute(
                  path: 'style-analyzer',
                  builder: (context, state) => const StyleAnalyzerScreen(),
                ),
                GoRoute(
                  path: 'stylist-chat',
                  builder: (context, state) => const StylistChatScreen(),
                ),
                GoRoute(
                  path: 'body-measurement/upload',
                  builder: (context, state) => const BodyMeasurementUpload(),
                ),
                GoRoute(
                  path: 'style-quiz',
                  builder: (context, state) => const StyleQuizScreen(),
                ),
                GoRoute(
                  path: 'my-orders',
                  builder: (context, state) => const MyOrdersScreen(),
                ),
                GoRoute(
                  path: 'admin',
                  builder: (context, state) => const AdminDashboard(),
                  routes: [
                    GoRoute(
                      path: 'products',
                      builder: (context, state) => const ProductManagerScreen(),
                    ),
                    GoRoute(
                      path: 'orders',
                      builder: (context, state) => const OrderManagerScreen(),
                    ),
                    GoRoute(
                      path: 'users',
                      builder: (context, state) => const UserListScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
