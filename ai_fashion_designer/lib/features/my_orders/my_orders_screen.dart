import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/order.dart';
import '../../core/services/order_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final all = _orderService.orders;
    final processing = all.where((o) => o.status == OrderStatus.processing || o.status == OrderStatus.confirmed).toList();
    final shipped = all.where((o) => o.status == OrderStatus.shipped || o.status == OrderStatus.outForDelivery).toList();
    final delivered = all.where((o) => o.status == OrderStatus.delivered).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Navigator.canPop(context) ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), color: Colors.white, onPressed: () => Navigator.pop(context)) : null,
        centerTitle: true,
        title: Text('MY ORDERS', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: AppColors.inkMuted48,
              labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
              indicatorColor: Colors.black,
              indicatorWeight: 2.5,
              tabs: [
                Tab(text: 'ALL (${all.length})'),
                Tab(text: 'ACTIVE (${processing.length})'),
                Tab(text: 'SHIPPED (${shipped.length})'),
                Tab(text: 'DONE (${delivered.length})'),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(all),
                _buildOrderList(processing),
                _buildOrderList(shipped),
                _buildOrderList(delivered),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: const Icon(Icons.receipt_long_outlined, size: 36, color: AppColors.inkMuted48)),
        const SizedBox(height: 14),
        Text('NO ORDERS YET', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text('Your orders will appear here', style: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48)),
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _orderCard(orders[index]),
    );
  }

  Widget _orderCard(Order order) {
    final statusColor = _getStatusColor(order.status);
    return GestureDetector(
      onTap: () => context.push('/orders/order-detail', extra: order.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey[200]!)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(order.id, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(order.statusText.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
              ),
            ]),
            const SizedBox(height: 14),
            ...order.items.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(width: 40, height: 40, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)), child: Image.network(item.product.imageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.image_outlined, size: 18, color: AppColors.inkMuted48)))),
                const SizedBox(width: 10),
                Expanded(child: Text('${item.product.name} ×${item.quantity}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text('₹${item.totalPrice}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
              ]),
            )),
            const SizedBox(height: 8),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${order.items.length} ITEMS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkMuted48, letterSpacing: 0.5)),
              Text('₹${order.grandTotal}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black)),
            ]),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms, delay: const Duration(milliseconds: 60)).slideY(begin: 0.03),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed: return Colors.black;
      case OrderStatus.processing: return const Color(0xFF111111);
      case OrderStatus.shipped: return Colors.black;
      case OrderStatus.outForDelivery: return Colors.black;
      case OrderStatus.delivered: return AppColors.success;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }
}
