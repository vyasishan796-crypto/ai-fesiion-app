enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

enum ServiceType { customTailoring, alteration, measurement, consultation }

enum PaymentMethod { upi, creditCard, debitCard, netBanking, cod }

class Tailor {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final String distance;
  final String address;
  final String phone;
  final String image;
  final bool isOpen;
  final List<String> services;
  final String openTime;
  final String closeTime;
  final double lat;
  final double lng;

  const Tailor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    this.address = '',
    this.phone = '',
    this.image = '',
    this.isOpen = true,
    this.services = const ['Custom Tailoring', 'Alterations', 'Measurements'],
    this.openTime = '9:00 AM',
    this.closeTime = '8:00 PM',
    this.lat = 26.9124,
    this.lng = 75.7873,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'specialty': specialty,
    'rating': rating,
    'reviewCount': reviewCount,
    'distance': distance,
    'address': address,
    'phone': phone,
    'image': image,
    'isOpen': isOpen,
    'services': services,
    'openTime': openTime,
    'closeTime': closeTime,
    'lat': lat,
    'lng': lng,
  };

  factory Tailor.fromMap(Map<String, dynamic> map) => Tailor(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    specialty: map['specialty'] ?? '',
    rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: map['reviewCount'] ?? 0,
    distance: map['distance'] ?? '',
    address: map['address'] ?? '',
    phone: map['phone'] ?? '',
    image: map['image'] ?? '',
    isOpen: map['isOpen'] ?? true,
    services: List<String>.from(map['services'] ?? []),
    openTime: map['openTime'] ?? '9:00 AM',
    closeTime: map['closeTime'] ?? '8:00 PM',
    lat: (map['lat'] as num?)?.toDouble() ?? 26.9124,
    lng: (map['lng'] as num?)?.toDouble() ?? 75.7873,
  );
}

class Booking {
  final String id;
  final Tailor tailor;
  final ServiceType serviceType;
  final DateTime date;
  final String timeSlot;
  final String notes;
  final BookingStatus status;
  final DateTime createdAt;
  final int estimatedPrice;
  final PaymentMethod? paymentMethod;
  final String? paymentId;

  const Booking({
    required this.id,
    required this.tailor,
    required this.serviceType,
    required this.date,
    required this.timeSlot,
    this.notes = '',
    this.status = BookingStatus.pending,
    required this.createdAt,
    this.estimatedPrice = 0,
    this.paymentMethod,
    this.paymentId,
  });

  String get statusText {
    switch (status) {
      case BookingStatus.pending: return 'Pending';
      case BookingStatus.confirmed: return 'Confirmed';
      case BookingStatus.inProgress: return 'In Progress';
      case BookingStatus.completed: return 'Completed';
      case BookingStatus.cancelled: return 'Cancelled';
    }
  }

  String get serviceTypeText {
    switch (serviceType) {
      case ServiceType.customTailoring: return 'Custom Tailoring';
      case ServiceType.alteration: return 'Alteration';
      case ServiceType.measurement: return 'Measurement Only';
      case ServiceType.consultation: return 'Consultation';
    }
  }

  String get paymentMethodText {
    switch (paymentMethod) {
      case PaymentMethod.upi: return 'UPI';
      case PaymentMethod.creditCard: return 'Credit Card';
      case PaymentMethod.debitCard: return 'Debit Card';
      case PaymentMethod.netBanking: return 'Net Banking';
      case PaymentMethod.cod: return 'Cash on Delivery';
      case null: return 'N/A';
    }
  }

  Booking copyWith({
    BookingStatus? status,
    PaymentMethod? paymentMethod,
    String? paymentId,
  }) {
    return Booking(
      id: id,
      tailor: tailor,
      serviceType: serviceType,
      date: date,
      timeSlot: timeSlot,
      notes: notes,
      status: status ?? this.status,
      createdAt: createdAt,
      estimatedPrice: estimatedPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'tailor': tailor.toMap(),
    'serviceType': serviceType.index,
    'date': date.toIso8601String(),
    'timeSlot': timeSlot,
    'notes': notes,
    'status': status.index,
    'createdAt': createdAt.toIso8601String(),
    'estimatedPrice': estimatedPrice,
    'paymentMethod': paymentMethod?.index,
    'paymentId': paymentId,
  };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
    id: map['id'] ?? '',
    tailor: Tailor.fromMap(map['tailor'] ?? {}),
    serviceType: ServiceType.values[map['serviceType'] ?? 0],
    date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    timeSlot: map['timeSlot'] ?? '',
    notes: map['notes'] ?? '',
    status: BookingStatus.values[map['status'] ?? 0],
    createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    estimatedPrice: map['estimatedPrice'] ?? 0,
    paymentMethod: map['paymentMethod'] != null ? PaymentMethod.values[map['paymentMethod']] : null,
    paymentId: map['paymentId'],
  );
}
