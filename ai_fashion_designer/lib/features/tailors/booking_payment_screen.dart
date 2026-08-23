import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/models/booking.dart';
import '../../core/services/booking_service.dart';

class BookingPaymentScreen extends StatefulWidget {
  final Tailor tailor;
  final ServiceType serviceType;
  final DateTime date;
  final String timeSlot;
  final String notes;

  const BookingPaymentScreen({
    super.key,
    required this.tailor,
    required this.serviceType,
    required this.date,
    required this.timeSlot,
    this.notes = '',
  });

  @override
  State<BookingPaymentScreen> createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends State<BookingPaymentScreen> {
  PaymentMethod? _selectedMethod;
  bool _isProcessing = false;

  // UPI
  final _upiController = TextEditingController(text: 'user@paytm');

  // Card
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardNameController = TextEditingController();

  // Net Banking
  String? _selectedBank;

  Widget _brandLogo(String brand, double size) {
    final logoUrl = _getBrandLogoUrl(brand);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        logoUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getBrandColor(brand).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(_getBrandIcon(brand), size: size * 0.5, color: _getBrandColor(brand)),
        ),
      ),
    );
  }

  String _getBrandLogoUrl(String brand) {
    const urls = {
      'gpay': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Google_Pay_Logo.svg/200px-Google_Pay_Logo.svg.png',
      'phonepe': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/PhonePe_Logo.svg/200px-PhonePe_Logo.svg.png',
      'paytm': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Paytm_Logo_%282019%29.svg/200px-Paytm_Logo_%282019%29.svg.png',
      'bhim': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/BHIM_logo.svg/200px-BHIM_logo.svg.png',
      'visa': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/200px-Visa_Inc._logo.svg.png',
      'mastercard': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/200px-Mastercard-logo.svg.png',
      'rupay': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/RuPay_logo.svg/200px-RuPay_logo.svg.png',
      'sbi': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/State_Bank_of_India_logo.svg/200px-State_Bank_of_India_logo.svg.png',
      'hdfc': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/HDFC_Bank_Logo.svg/200px-HDFC_Bank_Logo.svg.png',
      'icici': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/ICICI_Bank_logo.svg/200px-ICICI_Bank_logo.svg.png',
      'axis': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Axis_Bank_logo.svg/200px-Axis_Bank_logo.svg.png',
      'kotak': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Kotak_Mahindra_Bank_logo.svg/200px-Kotak_Mahindra_Bank_logo.svg.png',
      'pnb': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Punjab_National_Bank_logo.svg/200px-Punjab_National_Bank_logo.svg.png',
    };
    return urls[brand] ?? '';
  }

  Color _getBrandColor(String brand) {
    const colors = {
      'gpay': Color(0xFF4285F4),
      'phonepe': Color(0xFF5F259F),
      'paytm': Color(0xFF00BAF2),
      'bhim': Color(0xFF023E8A),
      'visa': Color(0xFF1A1F71),
      'mastercard': Color(0xFFEB001B),
      'rupay': Color(0xFF004C8F),
      'sbi': Color(0xFF2196F3),
      'hdfc': Color(0xFF004C8F),
      'icici': Color(0xFFF58220),
      'axis': Color(0xFF97144D),
      'kotak': Color(0xFFED1C24),
      'pnb': Color(0xFF005BA1),
    };
    return colors[brand] ?? AppColors.inkMuted48;
  }

  IconData _getBrandIcon(String brand) {
    const icons = {
      'visa': Icons.credit_card_rounded,
      'mastercard': Icons.credit_card_rounded,
      'rupay': Icons.credit_card_rounded,
    };
    return icons[brand] ?? Icons.account_balance_rounded;
  }

  int get _estimatedPrice {
    switch (widget.serviceType) {
      case ServiceType.customTailoring: return 1500;
      case ServiceType.alteration: return 300;
      case ServiceType.measurement: return 150;
      case ServiceType.consultation: return 200;
    }
  }

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: AppColors.canvasParchment,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.ink,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Payment', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSummary(),
                  const SizedBox(height: 20),
                  Text('Select Payment Method', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  const SizedBox(height: 12),
                  _buildPaymentMethods(),
                  const SizedBox(height: 16),
                  if (_selectedMethod != null) _buildPaymentForm(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomBar(bottomPad),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.tailor.image,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    color: AppColors.canvasParchment,
                    child: const Icon(Icons.content_cut_rounded, size: 18, color: AppColors.inkMuted48),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.tailor.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
                    Text(widget.serviceType == ServiceType.customTailoring ? 'Custom Tailoring' :
                         widget.serviceType == ServiceType.alteration ? 'Alteration' :
                         widget.serviceType == ServiceType.measurement ? 'Measurement' : 'Consultation',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _summaryRow(Icons.calendar_today_rounded, 'Date', '${widget.date.day}/${widget.date.month}/${widget.date.year}'),
          const SizedBox(height: 8),
          _summaryRow(Icons.access_time_rounded, 'Time', widget.timeSlot),
          if (widget.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _summaryRow(Icons.notes_rounded, 'Notes', widget.notes, maxLines: 1),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
              Text('₹$_estimatedPrice', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.accentPurple)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _summaryRow(IconData icon, String label, String value, {int maxLines = 2}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.inkMuted48),
        const SizedBox(width: 8),
        Text('$label:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.ink), maxLines: maxLines, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'method': PaymentMethod.upi, 'title': 'UPI', 'subtitle': 'GPay, PhonePe, Paytm', 'color': const Color(0xFF6D28D9), 'logos': ['gpay', 'phonepe', 'paytm']},
      {'method': PaymentMethod.creditCard, 'title': 'Credit Card', 'subtitle': 'Visa, Mastercard, Rupay', 'color': const Color(0xFF2563EB), 'logos': ['visa', 'mastercard', 'rupay']},
      {'method': PaymentMethod.debitCard, 'title': 'Debit Card', 'subtitle': 'All banks accepted', 'color': const Color(0xFF059669), 'logos': ['visa', 'mastercard', 'rupay']},
      {'method': PaymentMethod.netBanking, 'title': 'Net Banking', 'subtitle': 'All major banks', 'color': const Color(0xFFD97706), 'logos': ['sbi', 'hdfc', 'icici']},
      {'method': PaymentMethod.cod, 'title': 'Cash on Delivery', 'subtitle': 'Pay at the tailor shop', 'color': const Color(0xFFDC2626), 'logos': []},
    ];

    return Column(
      children: methods.asMap().entries.map((entry) {
        final i = entry.key;
        final m = entry.value;
        final isSelected = _selectedMethod == m['method'];
        final logos = (m['logos'] as List).cast<String>();
        return GestureDetector(
          onTap: () => setState(() => _selectedMethod = m['method'] as PaymentMethod),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accentPurple : AppColors.dividerSoft,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: (m['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: logos.isNotEmpty
                      ? _getCategoryIcon(m['method'] as PaymentMethod)
                      : const Icon(Icons.payments_rounded, color: Color(0xFFDC2626), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['title'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
                      Text(m['subtitle'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
                    ],
                  ),
                ),
                if (logos.isNotEmpty)
                  ...logos.take(3).map((l) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _brandLogo(l, 28),
                  )),
                const SizedBox(width: 6),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.accentPurple : AppColors.inkMuted48.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Container(
                          margin: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: AppColors.accentPurple, shape: BoxShape.circle),
                        )
                      : null,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 60 * i)).slideX(begin: 0.03),
        );
      }).toList(),
    );
  }

  Widget _getCategoryIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:
        return const Icon(Icons.phone_iphone_rounded, color: Color(0xFF6D28D9), size: 22);
      case PaymentMethod.creditCard:
        return const Icon(Icons.credit_card_rounded, color: Color(0xFF2563EB), size: 22);
      case PaymentMethod.debitCard:
        return const Icon(Icons.credit_card_rounded, color: Color(0xFF059669), size: 22);
      case PaymentMethod.netBanking:
        return const Icon(Icons.account_balance_rounded, color: Color(0xFFD97706), size: 22);
      case PaymentMethod.cod:
        return const Icon(Icons.payments_rounded, color: Color(0xFFDC2626), size: 22);
    }
  }

  Widget _buildPaymentForm() {
    switch (_selectedMethod!) {
      case PaymentMethod.upi:
        return _buildUPIForm();
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return _buildCardForm();
      case PaymentMethod.netBanking:
        return _buildNetBankingForm();
      case PaymentMethod.cod:
        return _buildCODForm();
    }
  }

  Widget _buildUPIForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('UPI ID', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
          const SizedBox(height: 8),
          TextField(
            controller: _upiController,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: 'yourname@paytm',
              hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48),
              prefixIcon: const Icon(Icons.phone_android_rounded, size: 18, color: AppColors.inkMuted48),
              filled: true,
              fillColor: AppColors.canvasParchment,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),
          Text('Pay with', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inkMuted48)),
          const SizedBox(height: 10),
          Row(
            children: [
              _upiAppLogo('gpay', 'Google Pay', const Color(0xFF4285F4)),
              const SizedBox(width: 10),
              _upiAppLogo('phonepe', 'PhonePe', const Color(0xFF5F259F)),
              const SizedBox(width: 10),
              _upiAppLogo('paytm', 'Paytm', const Color(0xFF00BAF2)),
              const SizedBox(width: 10),
              _upiAppLogo('bhim', 'BHIM', const Color(0xFF023E8A)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _upiAppLogo(String brand, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _upiController.text = 'user@$brand';
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              _brandLogo(brand, 32),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _brandLogo('visa', 32),
              const SizedBox(width: 8),
              _brandLogo('mastercard', 32),
              const SizedBox(width: 8),
              _brandLogo('rupay', 32),
            ],
          ),
          const SizedBox(height: 14),
          _cardField('Card Number', _cardNumberController, '1234 5678 9012 3456', TextInputType.number, Icons.credit_card_rounded),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _cardField('Expiry', _cardExpiryController, 'MM/YY', TextInputType.datetime, Icons.calendar_today_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _cardField('CVV', _cardCvvController, '123', TextInputType.number, Icons.lock_outline_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          _cardField('Cardholder Name', _cardNameController, 'John Doe', TextInputType.name, Icons.person_outline_rounded),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF22C55E)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your card info is encrypted & secure',
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF22C55E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _cardField(String label, TextEditingController ctrl, String hint, TextInputType type, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48),
            prefixIcon: Icon(icon, size: 18, color: AppColors.inkMuted48),
            filled: true,
            fillColor: AppColors.canvasParchment,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildNetBankingForm() {
    final banks = [
      {'name': 'State Bank of India', 'brand': 'sbi', 'color': const Color(0xFF2196F3)},
      {'name': 'HDFC Bank', 'brand': 'hdfc', 'color': const Color(0xFF004C8F)},
      {'name': 'ICICI Bank', 'brand': 'icici', 'color': const Color(0xFFF58220)},
      {'name': 'Axis Bank', 'brand': 'axis', 'color': const Color(0xFF97144D)},
      {'name': 'Kotak Mahindra', 'brand': 'kotak', 'color': const Color(0xFFED1C24)},
      {'name': 'Punjab National Bank', 'brand': 'pnb', 'color': const Color(0xFF005BA1)},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Bank', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: banks.length,
            itemBuilder: (context, index) {
              final bank = banks[index];
              final isSelected = _selectedBank == bank['name'];
              return GestureDetector(
                onTap: () => setState(() => _selectedBank = bank['name'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? (bank['color'] as Color).withOpacity(0.08) : AppColors.canvasParchment,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? bank['color'] as Color : AppColors.dividerSoft,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _brandLogo(bank['brand'] as String, 36),
                      const SizedBox(height: 6),
                      Text(
                        bank['name'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? bank['color'] as Color : AppColors.ink,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildCODForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: AppRadius.md,
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.payments_rounded, color: Color(0xFFDC2626), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pay ₹$_estimatedPrice at the shop', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text('Pay cash when you visit the tailor', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildBottomBar(double bottomPad) {
    final canPay = _selectedMethod != null &&
        (_selectedMethod == PaymentMethod.cod ||
         (_selectedMethod == PaymentMethod.upi && _upiController.text.isNotEmpty) ||
         (_selectedMethod == PaymentMethod.netBanking && _selectedBank != null) ||
         (_selectedMethod == PaymentMethod.creditCard && _cardNumberController.text.isNotEmpty) ||
         (_selectedMethod == PaymentMethod.debitCard && _cardNumberController.text.isNotEmpty));

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: canPay ? _processPayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPurple,
            disabledBackgroundColor: AppColors.inkMuted48.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  _selectedMethod == PaymentMethod.cod ? 'Confirm Booking (COD)' : 'Pay ₹$_estimatedPrice',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    final booking = await BookingService().createBookingWithPayment(
      tailor: widget.tailor,
      serviceType: widget.serviceType,
      date: widget.date,
      timeSlot: widget.timeSlot,
      paymentMethod: _selectedMethod!,
      notes: widget.notes,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _PaymentSuccessDialog(
          booking: booking,
          onDone: () {
            Navigator.pop(ctx);
            context.go('/home');
          },
        ),
      );
    }
  }
}

class _PaymentSuccessDialog extends StatelessWidget {
  final Booking booking;
  final VoidCallback onDone;
  const _PaymentSuccessDialog({required this.booking, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, size: 40, color: Colors.white),
            ).animate().scale(duration: 400.ms, begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            const SizedBox(height: 8),
            Text(
              booking.paymentMethod == PaymentMethod.cod ? 'Booking confirmed! Pay at the shop.' : 'Payment of ₹${booking.estimatedPrice} received.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.canvasParchment,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _infoRow('Booking ID', booking.id),
                  const SizedBox(height: 6),
                  _infoRow('Tailor', booking.tailor.name),
                  const SizedBox(height: 6),
                  _infoRow('Date', '${booking.date.day}/${booking.date.month}/${booking.date.year}'),
                  const SizedBox(height: 6),
                  _infoRow('Time', booking.timeSlot),
                  const SizedBox(height: 6),
                  _infoRow('Payment', booking.paymentMethodText),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('Done', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48)),
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
      ],
    );
  }
}
