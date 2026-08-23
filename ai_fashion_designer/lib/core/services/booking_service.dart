import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import 'notification_service.dart';

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final List<Booking> _bookings = [];
  bool _loaded = false;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  int get bookingCount => _bookings.length;

  List<Booking> get pendingBookings =>
      _bookings.where((b) => b.status == BookingStatus.pending || b.status == BookingStatus.confirmed).toList();
  List<Booking> get completedBookings =>
      _bookings.where((b) => b.status == BookingStatus.completed).toList();
  List<Booking> get cancelledBookings =>
      _bookings.where((b) => b.status == BookingStatus.cancelled).toList();

  Future<void> loadBookings() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('bookings') ?? '[]';
      final list = jsonDecode(data) as List;
      _bookings.clear();
      _bookings.addAll(list.map((e) => Booking.fromMap(e)));
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bookings: $e');
    }
  }

  Future<void> _saveBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_bookings.map((b) => b.toMap()).toList());
      await prefs.setString('bookings', data);
    } catch (e) {
      debugPrint('Error saving bookings: $e');
    }
  }

  Future<Booking> createBooking({
    required Tailor tailor,
    required ServiceType serviceType,
    required DateTime date,
    required String timeSlot,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final booking = Booking(
      id: 'BK-${now.millisecondsSinceEpoch.toString().substring(5)}',
      tailor: tailor,
      serviceType: serviceType,
      date: date,
      timeSlot: timeSlot,
      notes: notes,
      status: BookingStatus.confirmed,
      createdAt: now,
      estimatedPrice: _estimatePrice(serviceType),
    );

    _bookings.insert(0, booking);
    await _saveBookings();
    notifyListeners();
    NotificationService().showBookingConfirmed(
      tailor.name,
      '${date.day}/${date.month}/${date.year} at $timeSlot',
    );
    return booking;
  }

  Future<Booking> createBookingWithPayment({
    required Tailor tailor,
    required ServiceType serviceType,
    required DateTime date,
    required String timeSlot,
    required PaymentMethod paymentMethod,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final booking = Booking(
      id: 'BK-${now.millisecondsSinceEpoch.toString().substring(5)}',
      tailor: tailor,
      serviceType: serviceType,
      date: date,
      timeSlot: timeSlot,
      notes: notes,
      status: BookingStatus.confirmed,
      createdAt: now,
      estimatedPrice: _estimatePrice(serviceType),
      paymentMethod: paymentMethod,
      paymentId: paymentMethod == PaymentMethod.cod ? null : 'PAY-${now.millisecondsSinceEpoch.toString().substring(7)}',
    );

    _bookings.insert(0, booking);
    await _saveBookings();
    notifyListeners();
    NotificationService().showBookingConfirmed(
      tailor.name,
      '${date.day}/${date.month}/${date.year} at $timeSlot',
    );
    return booking;
  }

  Future<void> cancelBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index >= 0) {
      _bookings[index] = _bookings[index].copyWith(status: BookingStatus.cancelled);
      await _saveBookings();
      notifyListeners();
    }
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index >= 0) {
      _bookings[index] = _bookings[index].copyWith(status: status);
      await _saveBookings();
      notifyListeners();
    }
  }

  Booking? getBooking(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  int _estimatePrice(ServiceType type) {
    switch (type) {
      case ServiceType.customTailoring: return 1500;
      case ServiceType.alteration: return 300;
      case ServiceType.measurement: return 150;
      case ServiceType.consultation: return 200;
    }
  }

  static const List<Tailor> defaultTailors = [
    Tailor(
      id: 't1',
      name: 'Libas Tailor',
      specialty: 'Suits, Wedding & Formal Wear',
      rating: 4.9,
      reviewCount: 485,
      distance: '1.2 km',
      address: 'B-10, 17 Pratap Plaza, Pratap Nagar, Jaipur 302033',
      phone: '+91 97725 77671',
      image: 'https://image.hm.com/assets/hm/0e/9d/0e9d5aad30cdb02146ec21cd1ac8059183935ead.jpg?imwidth=400',
      lat: 26.8580,
      lng: 75.8100,
    ),
    Tailor(
      id: 't2',
      name: 'Sana Designer Studio',
      specialty: 'Bridal, Lehengas & Evening Wear',
      rating: 4.8,
      reviewCount: 312,
      distance: '2.5 km',
      address: '45 Malviya Nagar, Jaipur 302017',
      phone: '+91 98285 12345',
      image: 'https://image.hm.com/assets/hm/01/fd/01fd86bce62ec488046edcd51bb8528f86bf52a1.jpg?imwidth=400',
      lat: 26.8520,
      lng: 75.8045,
    ),
    Tailor(
      id: 't3',
      name: 'Sameeksha Tailors',
      specialty: 'Western Wear & Casuals',
      rating: 4.7,
      reviewCount: 228,
      distance: '1.8 km',
      address: '22 C-Scheme, Ashram Marg, Jaipur 302001',
      phone: '+91 87654 32109',
      image: 'https://image.hm.com/assets/hm/28/0e/280e508290b365e7e872a14152ee16ec10e65753.jpg?imwidth=400',
      lat: 26.9124,
      lng: 75.7873,
    ),
    Tailor(
      id: 't4',
      name: 'Joyti Boutique',
      specialty: 'Kurtis, Sarees & Traditional',
      rating: 4.6,
      reviewCount: 195,
      distance: '3.1 km',
      address: '78 Riddhi Siddhi, Mansarovar, Jaipur 302020',
      phone: '+91 78901 23456',
      image: 'https://image.hm.com/assets/hm/00/8a/008af4accd1366994998b0918f9ede5120b8a405.jpg?imwidth=400',
      lat: 26.8620,
      lng: 75.7680,
    ),
    Tailor(
      id: 't5',
      name: 'Choudhary Tailors',
      specialty: 'Suits, Blazers & Formal Wear',
      rating: 4.5,
      reviewCount: 167,
      distance: '4.0 km',
      address: '15 Johari Bazaar, Jaipur 302003',
      phone: '+91 65432 10987',
      image: 'https://image.hm.com/assets/hm/19/b9/19b96c80c6b674abacbb46438fab81b4b4c1779f.jpg?imwidth=400',
      lat: 26.9270,
      lng: 75.8250,
    ),
    Tailor(
      id: 't6',
      name: 'Fatehpuria Tailoring',
      specialty: 'Sherwanis & Wedding Wear',
      rating: 4.9,
      reviewCount: 412,
      distance: '1.5 km',
      address: '33 Tripolia Bazaar, Jaipur 302002',
      phone: '+91 54321 09876',
      image: 'https://image.hm.com/assets/hm/02/41/02419d88b2721a5ac4f49705686fcd1ec4c07092.jpg?imwidth=400',
      lat: 26.9235,
      lng: 75.8260,
    ),
    Tailor(
      id: 't7',
      name: 'Annapurna Tailors',
      specialty: 'Alterations & Quick Fixes',
      rating: 4.4,
      reviewCount: 143,
      distance: '2.8 km',
      address: '12 MI Road, Near Ganpati Plaza, Jaipur 302001',
      phone: '+91 43210 98765',
      image: 'https://image.hm.com/assets/hm/25/a8/25a8c45bba54c7bbf79ef0c2780af12c55b48469.jpg?imwidth=400',
      lat: 26.9150,
      lng: 75.8150,
    ),
    Tailor(
      id: 't8',
      name: 'Kanupriya Fashion House',
      specialty: 'Indo-Western & Designer Wear',
      rating: 4.7,
      reviewCount: 256,
      distance: '3.5 km',
      address: '56 Vaishali Nagar, Ajmer Road, Jaipur 302021',
      phone: '+91 32109 87654',
      image: 'https://image.hm.com/assets/hm/0b/19/0b193f4320f30801155e33b5d6bd3b08f27d22cd.jpg?imwidth=400',
      lat: 26.8850,
      lng: 75.7580,
    ),
  ];
}