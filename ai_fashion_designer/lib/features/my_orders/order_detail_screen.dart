import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/order.dart';
import '../../core/services/order_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = OrderService().getOrder(orderId);
    if (order == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.black, title: Text('ORDER DETAIL', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2))),
        body: Center(child: Text('Order not found', style: GoogleFonts.inter(color: AppColors.inkMuted48))),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), color: Colors.white, onPressed: () => Navigator.pop(context)),
        centerTitle: true,
        title: Text(order.id, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(order),
            const SizedBox(height: 12),
            _buildTimeline(order),
            const SizedBox(height: 12),
            _buildDeliveryAddress(order),
            const SizedBox(height: 12),
            _buildPaymentInfo(order),
            const SizedBox(height: 12),
            _buildOrderItems(order),
            const SizedBox(height: 12),
            _buildPriceBreakdown(order),
            if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GestureDetector(
                    onTap: () => _cancelOrder(context, order),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(30)),
                      child: Center(child: Text('CANCEL ORDER', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 1))),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(Order order) {
    Color statusColor;
    IconData statusIcon;
    switch (order.status) {
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        statusColor = Colors.black;
        statusIcon = Icons.inventory_2_rounded;
        break;
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        statusColor = Colors.black;
        statusIcon = Icons.local_shipping_rounded;
        break;
      case OrderStatus.delivered:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case OrderStatus.cancelled:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.grey[50],
      child: Column(
        children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: statusColor == Colors.black ? Colors.black : statusColor, shape: BoxShape.circle), child: Icon(statusIcon, size: 32, color: Colors.white)),
          const SizedBox(height: 14),
          Text(order.statusText.toUpperCase(), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text('Ordered on ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48)),
          if (order.trackingId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
              child: Text('TRACKING: ${order.trackingId}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.5)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(Order order) {
    final completedCount = order.timeline.where((t) => t.isCompleted).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ORDER TIMELINE', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
          const SizedBox(height: 16),
          ...List.generate(order.timeline.length, (index) {
            final step = order.timeline[index];
            final isLast = index == order.timeline.length - 1;
            final isCompleted = step.isCompleted;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: isCompleted ? Colors.black : Colors.white, shape: BoxShape.circle, border: Border.all(color: isCompleted ? Colors.black : Colors.grey[300]!, width: 2)),
                      child: isCompleted ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : Container(width: 8, height: 8, margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: index == completedCount ? Colors.black.withOpacity(0.3) : Colors.transparent, shape: BoxShape.circle)),
                    ),
                    if (!isLast) Container(width: 2, height: 36, color: isCompleted ? Colors.black : Colors.grey[200]),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.status.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500, color: isCompleted ? Colors.black : AppColors.inkMuted48, letterSpacing: 0.5)),
                        if (step.detail != null && isCompleted) ...[
                          const SizedBox(height: 2),
                          Text(step.detail!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
                        ],
                        if (isCompleted) ...[
                          const SizedBox(height: 2),
                          Text('${step.date.day}/${step.date.month}/${step.date.year} ${step.date.hour}:${step.date.minute.toString().padLeft(2, '0')}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.inkMuted48.withOpacity(0.7))),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.location_on_rounded, size: 16, color: Colors.black), const SizedBox(width: 6), Text('DELIVERY ADDRESS', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1))]),
          const SizedBox(height: 10),
          Text(order.address.label.toUpperCase(), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(order.address.fullAddress, style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48, height: 1.4)),
          const SizedBox(height: 2),
          Text(order.address.phone, style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.payment_rounded, size: 16, color: Colors.black), const SizedBox(width: 6), Text('PAYMENT', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1))]),
          const SizedBox(height: 10),
          Text(order.paymentMethod, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 4),
          Text('Total: ₹${order.grandTotal}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildOrderItems(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ITEMS (${order.items.length})', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
          const SizedBox(height: 14),
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(width: 60, height: 70, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Image.network(item.product.imageUrl, width: 60, height: 70, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.image_outlined, color: AppColors.inkMuted48)))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product.brand.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.inkMuted48, letterSpacing: 1)),
                        Text(item.product.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('Size: ${item.selectedSize}  •  Qty: ${item.quantity}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
                      ],
                    ),
                  ),
                  Text('₹${item.totalPrice}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PRICE DETAILS', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
          const SizedBox(height: 14),
          _buildPriceRow('SUBTOTAL', '₹${order.subtotal}'),
          _buildPriceRow('DELIVERY', order.deliveryCharges == 0 ? 'FREE' : '₹${order.deliveryCharges}'),
          if (order.savings > 0) _buildPriceRow('SAVINGS', '-₹${order.savings}', isGreen: true),
          const SizedBox(height: 10),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 10),
          _buildPriceRow('TOTAL', '₹${order.grandTotal}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkMuted48, letterSpacing: 0.5)),
          Text(value, style: GoogleFonts.inter(fontSize: isBold ? 14 : 12, fontWeight: isBold ? FontWeight.w800 : FontWeight.w700, color: isGreen ? AppColors.success : Colors.black)),
        ],
      ),
    );
  }

  void _cancelOrder(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('CANCEL ORDER?', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1)),
        content: Text('Are you sure you want to cancel this order?', style: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('NO', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.inkMuted48))),
          TextButton(
            onPressed: () {
              OrderService().cancelOrder(order.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order cancelled', style: GoogleFonts.inter()), backgroundColor: Colors.black));
            },
            child: Text('YES, CANCEL', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
