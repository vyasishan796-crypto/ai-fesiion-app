import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<Map<String, dynamic>> _cards = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('payment_cards');
    if (data != null) {
      final list = jsonDecode(data) as List;
      setState(() {
        _cards = List<Map<String, dynamic>>.from(list);
        _loaded = true;
      });
    } else {
      setState(() {
        _cards = [
          {'brand': 'Visa', 'last4': '4242', 'expiry': '12/26', 'isDefault': true},
          {'brand': 'Mastercard', 'last4': '8888', 'expiry': '08/27', 'isDefault': false},
        ];
        _loaded = true;
      });
      _saveCards();
    }
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('payment_cards', jsonEncode(_cards));
  }

  Color _brandColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa': return const Color(0xFF1A1F71);
      case 'mastercard': return const Color(0xFFEB001B);
      case 'rupay': return const Color(0xFF0070BA);
      case 'amex': return const Color(0xFF006FCF);
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Payment Methods', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Your Cards', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.5)).animate().fadeIn(),
            const SizedBox(height: 20),
            if (_cards.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.credit_card_off_rounded, size: 64, color: AppColors.inkMuted48),
                      const SizedBox(height: 16),
                      Text('No cards saved', style: GoogleFonts.inter(fontSize: 16, color: AppColors.inkMuted48)),
                      const SizedBox(height: 8),
                      Text('Add your first card below', style: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48)),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_cards.length, (i) {
                final card = _cards[i];
                final color = _brandColor(card['brand'] ?? 'Visa');
                final isDefault = card['isDefault'] == true;
                return Dismissible(
                  key: Key('card_${card['last4']}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Remove Card?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        content: Text('Delete ${card['brand']} ending in ${card['last4']}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('Delete', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    setState(() => _cards.removeAt(i));
                    _saveCards();
                  },
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        for (int j = 0; j < _cards.length; j++) {
                          _cards[j]['isDefault'] = (j == i);
                        }
                      });
                      _saveCards();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDefault ? color : color.withOpacity(0.2), width: isDefault ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.credit_card_rounded, color: color, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${card['brand']} •••• ${card['last4']}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text('Expires ${card['expiry']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted)),
                                    if (isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                        child: Text('Default', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isDefault) Icon(Icons.check_circle_rounded, size: 20, color: color),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 80 * i));
              }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _showAddCardDialog(),
                icon: const Icon(Icons.add, size: 20),
                label: Text('Add New Card', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 24),
            Text('UPI Payment', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildUpiApp('GPay', AppColors.success),
                const SizedBox(width: 10),
                _buildUpiApp('PhonePe', AppColors.primary),
                const SizedBox(width: 10),
                _buildUpiApp('Paytm', AppColors.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiApp(String name, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ),
      ),
    );
  }

  void _showAddCardDialog() {
    final numberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();
    String selectedBrand = 'Visa';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.inkMuted48.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('Add New Card', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 16),
                Row(
                  children: ['Visa', 'Mastercard', 'RuPay', 'Amex'].map((brand) {
                    final isSelected = selectedBrand == brand;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedBrand = brand),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? _brandColor(brand) : AppColors.canvasParchment,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(brand, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.ink)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expiryController,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: InputDecoration(
                          labelText: 'MM/YY', counterText: '',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: cvvController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'CVV', counterText: '',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Cardholder Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (numberController.text.length >= 4 && expiryController.text.isNotEmpty && nameController.text.isNotEmpty) {
                        final last4 = numberController.text.substring(numberController.text.length - 4);
                        setState(() {
                          _cards.add({
                            'brand': selectedBrand,
                            'last4': last4,
                            'expiry': expiryController.text,
                            'isDefault': _cards.isEmpty,
                          });
                        });
                        _saveCards();
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Save Card', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
