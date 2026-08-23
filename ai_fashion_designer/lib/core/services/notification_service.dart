import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _enabled = true;
  int _idCounter = 0;

  bool get enabled => _enabled;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onTap,
    );

    const androidChannel = AndroidNotificationChannel(
      'styleai_main',
      'StyleAI Notifications',
      description: 'Order updates, price drops, outfit suggestions',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const priceChannel = AndroidNotificationChannel(
      'styleai_price',
      'Price Alerts',
      description: 'Price drop alerts for wishlisted items',
      importance: Importance.max,
      enableVibration: true,
    );
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(priceChannel);

    const orderChannel = AndroidNotificationChannel(
      'styleai_orders',
      'Order Updates',
      description: 'Order status and delivery updates',
      importance: Importance.high,
    );
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(orderChannel);

    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('notifications_enabled') ?? true;

    _initialized = true;
    debugPrint('NotificationService initialized');
    startDailyStyleTips();
  }

  void _onTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> _requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      if (granted != null && !granted) {
        _enabled = false;
      }
    }
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    if (value) await _requestPermission();
  }

  int _nextId() => ++_idCounter;

  Future<void> showOrderPlaced(String orderId, String itemSummary) async {
    if (!_enabled) return;
    await _plugin.show(
      _nextId(),
      'Order Confirmed!',
      'Order $orderId placed — $itemSummary',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'styleai_orders',
          'Order Updates',
          channelDescription: 'Order status and delivery updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF7C4DFF),
        ),
      ),
    );
  }

  Future<void> showOrderShipped(String orderId, String courier) async {
    if (!_enabled) return;
    await _plugin.show(
      _nextId(),
      'Order Shipped!',
      'Order $orderId shipped via $courier. Track now!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'styleai_orders',
          'Order Updates',
          channelDescription: 'Order status and delivery updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF7C4DFF),
        ),
      ),
    );
  }

  Future<void> showOrderDelivered(String orderId) async {
    if (!_enabled) return;
    await _plugin.show(
      _nextId(),
      'Order Delivered!',
      'Order $orderId has been delivered. Enjoy your new style!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'styleai_orders',
          'Order Updates',
          channelDescription: 'Order status and delivery updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF22C55E),
        ),
      ),
    );
  }

  Future<void> showPriceDrop(String productName, String oldPrice, String newPrice) async {
    if (!_enabled) return;
    await _plugin.show(
      _nextId(),
      'Price Drop Alert!',
      '$productName dropped from $oldPrice to $newPrice',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'styleai_price',
          'Price Alerts',
          channelDescription: 'Price drop alerts for wishlisted items',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFFF6B35),
        ),
      ),
    );
  }

  Future<void> showOutfitReady(String outfitName) async {
    if (!_enabled) return;
    await _plugin.show(
      _nextId(),
      'Your Outfit is Ready!',
      '$outfitName — styled just for you. Take a look!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'styleai_main',
          'StyleAI Notifications',
          channelDescription: 'Order updates, price drops, outfit suggestions',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF7C4DFF),
        ),
      ),
    );
  }

  Future<void> showBookingConfirmed(String tailorName, String date) async {
    if (!_enabled) return;
    await _plugin.show(
      _nextId(),
      'Booking Confirmed!',
      'Appointment with $tailorName on $date confirmed.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'styleai_main',
          'StyleAI Notifications',
          channelDescription: 'Order updates, price drops, outfit suggestions',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF7C4DFF),
        ),
      ),
    );
  }

  Future<void> showWishlistSale(String productName, String discount) async {
    if (!_enabled) return;
    await _plugin.show(
      _nextId(),
      'Sale on Wishlisted Item!',
      '$productName is now $discount% off! Grab it before it\'s gone.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'styleai_price',
          'Price Alerts',
          channelDescription: 'Price drop alerts for wishlisted items',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF7C4DFF),
        ),
      ),
    );
  }

  Future<void> showDailyStyleTip(String tip) async {
    if (!_enabled) return;
    await _plugin.show(
      _nextId(),
      'Daily Style Tip',
      tip,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'styleai_main',
          'StyleAI Notifications',
          channelDescription: 'Order updates, price drops, outfit suggestions',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF7C4DFF),
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  void startDailyStyleTips() {
    if (!_enabled) return;
    final tips = [
      'Layer a blazer over a graphic tee for instant smart-casual vibes.',
      'Roll up your sleeves — it makes any outfit look effortlessly cool.',
      'White sneakers match literally everything. Invest in a good pair.',
      'Earth tones like olive, tan, and rust are always in style.',
      'A well-fitted outfit beats expensive clothes every time.',
      'Mix textures — denim with knitwear, leather with cotton.',
      'Accessories can transform a basic outfit. Try a watch or bracelet.',
      'Monochrome outfits create a sleek, put-together look.',
      'Dark wash jeans are versatile — dress them up or down.',
      'Fit is king. Tailor your clothes for the perfect silhouette.',
      'Pastel colors work great for spring and summer outfits.',
      'A classic white shirt is the most versatile piece in any wardrobe.',
      'Match your belt with your shoes for a polished look.',
      'Don\'t be afraid to mix patterns — stripes and checks can work.',
      'Invest in quality basics — they form the foundation of every outfit.',
    ];
    final now = DateTime.now();
    final todayTip = tips[now.day % tips.length];
    showDailyStyleTip(todayTip);
  }
}
