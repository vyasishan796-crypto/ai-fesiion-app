import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/services/cart_service.dart';
import '../../core/services/order_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/order.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPayment = 0;
  final CartService _cart = CartService();
  final OrderService _orderService = OrderService();
  List<Map<String, dynamic>> _addresses = [];
  int _selectedAddress = 0;
  bool _isPlacing = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_addresses');
    if (data != null) {
      final list = jsonDecode(data) as List;
      setState(() => _addresses = List<Map<String, dynamic>>.from(list));
    } else {
      setState(() {
        _addresses = [
          {'label': 'Home', 'address': '14, Green Park Colony, Jaipur, Rajasthan', 'icon': 'home', 'phone': '9876543210'},
          {'label': 'Office', 'address': '201, Tech Park, Malviya Nagar, Jaipur', 'icon': 'work', 'phone': '9876543210'},
        ];
      });
    }
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_addresses', jsonEncode(_addresses));
  }

  IconData _iconFromString(String icon) {
    switch (icon) {
      case 'home': return Icons.home_rounded;
      case 'work': return Icons.work_rounded;
      case 'school': return Icons.school_rounded;
      case 'location': return Icons.location_on_rounded;
      default: return Icons.home_rounded;
    }
  }

  Future<void> _placeOrder() async {
    if (_isPlacing) return;
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cart is empty'), backgroundColor: Colors.black));
      return;
    }
    if (_addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please add a delivery address'), backgroundColor: Colors.black));
      return;
    }
    setState(() => _isPlacing = true);
    try {
      final addr = _addresses[_selectedAddress];
      final paymentMethods = ['UPI', 'Credit Card', 'Cash on Delivery'];
      final orderAddress = OrderAddress(label: addr['label'] ?? 'Home', fullAddress: addr['address'] ?? '', phone: addr['phone'] ?? '');
      final order = await _orderService.placeOrder(address: orderAddress, paymentMethod: paymentMethods[_selectedPayment]);
      final itemCount = order.items.length;
      final itemNames = order.items.map((i) => i.product.name).join(', ');
      await NotificationService().showOrderPlaced(order.id, itemCount > 2 ? '${itemNames.substring(0, 40)}...' : itemNames);
      if (mounted) context.push('/orders/order-confirmation', extra: order.id);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error placing order: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), color: Colors.white, onPressed: () => Navigator.pop(context)),
        centerTitle: true,
        title: Text('CHECKOUT', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressSection(),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 20),
            _buildPaymentSection(),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 20),
            _buildOrderSummary(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: GestureDetector(
            onTap: _isPlacing ? null : _placeOrder,
            child: Container(
              decoration: BoxDecoration(color: _isPlacing ? Colors.grey[400] : Colors.black, borderRadius: BorderRadius.circular(30)),
              child: Center(
                child: _isPlacing
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('PLACE ORDER — ₹${_cart.grandTotal}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SHIPPING ADDRESS', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
            GestureDetector(
              onTap: () => _showAddAddressDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                child: Text('+ ADD NEW', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...List.generate(_addresses.length, (i) {
          final addr = _addresses[i];
          final isSelected = _selectedAddress == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedAddress = i),
            onLongPress: () => _confirmDeleteAddress(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? Colors.black : Colors.grey[200]!, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: isSelected ? Colors.white.withOpacity(0.15) : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: Icon(_iconFromString(addr['icon'] ?? 'home'), color: isSelected ? Colors.white : Colors.black, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(addr['label'] ?? 'Home', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : Colors.black)),
                        const SizedBox(height: 2),
                        Text(addr['address'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: isSelected ? Colors.white70 : AppColors.inkMuted48)),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle_rounded, size: 22, color: Colors.white),
                ],
              ),
            ),
          );
        }),
      ],
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildPaymentSection() {
    final payments = [
      {'title': 'UPI', 'subtitle': 'GPay, PhonePe, Paytm', 'icon': Icons.phone_iphone_rounded},
      {'title': 'Credit / Debit Card', 'subtitle': 'Visa, Mastercard, RuPay', 'icon': Icons.credit_card_rounded},
      {'title': 'Cash on Delivery', 'subtitle': 'Pay when delivered', 'icon': Icons.payments_rounded},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PAYMENT METHOD', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
        const SizedBox(height: 14),
        ...List.generate(payments.length, (i) {
          final p = payments[i];
          final isSelected = _selectedPayment == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedPayment = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? Colors.black : Colors.grey[200]!, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: isSelected ? Colors.white.withOpacity(0.15) : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: Icon(p['icon'] as IconData, color: isSelected ? Colors.white : Colors.black, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['title'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : Colors.black)),
                        Text(p['subtitle'] as String, style: GoogleFonts.inter(fontSize: 11, color: isSelected ? Colors.white70 : AppColors.inkMuted48)),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle_rounded, size: 22, color: Colors.white),
                ],
              ),
            ),
          );
        }),
      ],
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms);
  }

  Widget _buildOrderSummary() {
    final subtotal = _cart.subtotal;
    final delivery = _cart.deliveryCharges;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ORDER SUMMARY', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey[200]!)),
          child: Column(
            children: [
              _summaryRow('SUBTOTAL (${_cart.totalItems} ITEMS)', '₹$subtotal'),
              const SizedBox(height: 8),
              _summaryRow('DELIVERY', delivery == 0 ? 'FREE' : '₹$delivery', isFree: delivery == 0),
              if (_cart.totalSavings > 0) ...[
                const SizedBox(height: 8),
                _summaryRow('YOU SAVE', '-₹${_cart.totalSavings}', isGreen: true),
              ],
              const SizedBox(height: 12),
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
                  Text('₹${_cart.grandTotal}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms, delay: 200.ms);
  }

  Widget _summaryRow(String label, String value, {bool isFree = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkMuted48, letterSpacing: 0.5)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isGreen ? AppColors.success : Colors.black)),
      ],
    );
  }

  void _showAddAddressDialog() {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedIcon = 'home';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('ADD NEW ADDRESS', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
              const SizedBox(height: 16),
              Row(
                children: ['home', 'work', 'school', 'location'].map((icon) {
                  final isSelected = selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedIcon = icon),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      child: Icon(_iconFromString(icon), color: isSelected ? Colors.white : AppColors.inkMuted48, size: 20),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _nikeField(labelController, 'Label (Home / Office)'),
              const SizedBox(height: 12),
              _nikeField(addressController, 'Full Address', maxLines: 3),
              const SizedBox(height: 12),
              _nikeField(phoneController, 'Phone Number', keyboard: TextInputType.phone),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: GestureDetector(
                  onTap: () {
                    if (labelController.text.isNotEmpty && addressController.text.isNotEmpty) {
                      setState(() => _addresses.add({'label': labelController.text, 'address': addressController.text, 'icon': selectedIcon, 'phone': phoneController.text}));
                      _saveAddresses();
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                    child: Center(child: Text('SAVE ADDRESS', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nikeField(TextEditingController c, String hint, {int maxLines = 1, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  void _confirmDeleteAddress(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('DELETE ADDRESS?', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1)),
        content: Text('Remove ${_addresses[index]['label']}?', style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkMuted48)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('CANCEL', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.inkMuted48))),
          TextButton(
            onPressed: () {
              setState(() {
                _addresses.removeAt(index);
                if (_selectedAddress >= _addresses.length) _selectedAddress = 0;
              });
              _saveAddresses();
              Navigator.pop(ctx);
            },
            child: Text('DELETE', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
