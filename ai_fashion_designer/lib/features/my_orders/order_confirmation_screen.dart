import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/order_service.dart';
import '../../core/services/notification_service.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = OrderService().getOrder(orderId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (order != null) {
        final items = order.items.map((i) => i.product.name).join(', ');
        NotificationService().showOrderPlaced(orderId, items.isNotEmpty ? items : 'Fashion items');
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, size: 44, color: Colors.white),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text('ORDER PLACED!', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 2)).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                const SizedBox(height: 8),
                Text('Thank you for your purchase', style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkMuted48)).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey[200]!)),
                  child: Column(
                    children: [
                      _buildInfoRow('ORDER ID', orderId),
                      if (order != null) ...[
                        const SizedBox(height: 10),
                        _buildInfoRow('TOTAL', '₹${order.grandTotal}'),
                        const SizedBox(height: 10),
                        _buildInfoRow('PAYMENT', order.paymentMethod.toUpperCase()),
                        const SizedBox(height: 10),
                        _buildInfoRow('DELIVERY', '${order.estimatedDelivery.day}/${order.estimatedDelivery.month}/${order.estimatedDelivery.year}'),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_rounded, size: 18, color: Colors.black),
                      const SizedBox(width: 10),
                      Expanded(child: Text('You will receive a confirmation shortly', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black))),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)), child: Center(child: Text('CONTINUE SHOPPING', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)))),
                  ),
                ).animate().fadeIn(delay: 1000.ms),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GestureDetector(
                    onTap: () => context.push('/order-detail', extra: orderId),
                    child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(30)), child: Center(child: Text('VIEW ORDER', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 1)))),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkMuted48, letterSpacing: 0.5)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black)),
      ],
    );
  }
}
