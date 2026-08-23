import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'admin_service.dart';

class OrderManagerScreen extends StatefulWidget {
  const OrderManagerScreen({super.key});

  @override
  State<OrderManagerScreen> createState() => _OrderManagerScreenState();
}

class _OrderManagerScreenState extends State<OrderManagerScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _filterStatus = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _adminService.getOrders(status: _filterStatus);
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    final result = await _adminService.updateOrderStatus(orderId, newStatus);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #$orderId → $newStatus'), backgroundColor: AppColors.success),
      );
      _loadOrders();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'confirmed': return const Color(0xFF2563EB);
      case 'shipped': return const Color(0xFF8B5CF6);
      case 'delivered': return const Color(0xFF22C55E);
      case 'cancelled': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Orders (${_orders.length})', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', ''),
                  const SizedBox(width: 8),
                  _filterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _filterChip('Confirmed', 'confirmed'),
                  const SizedBox(width: 8),
                  _filterChip('Shipped', 'shipped'),
                  const SizedBox(width: 8),
                  _filterChip('Delivered', 'delivered'),
                  const SizedBox(width: 8),
                  _filterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentPurple))
                : _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.inkMuted48),
                            const SizedBox(height: 16),
                            Text('No orders found', style: GoogleFonts.inter(fontSize: 16, color: AppColors.inkMuted48)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _orders.length,
                          itemBuilder: (ctx, i) => _buildOrderCard(_orders[i], i),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String status) {
    final isSelected = _filterStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() => _filterStatus = status);
        _loadOrders();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPurple : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.ink)),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, int index) {
    final status = order['status'] ?? 'pending';
    final color = _statusColor(status);
    final items = order['items'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.receipt_rounded, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${order['id']}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      Text('${items.length} items • ₹${order['total'] ?? 0}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Payment: ${order['payment_method'] ?? 'N/A'} • ${items.map((i) => i['name']).join(', ').substring(0, 50)}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          if (status != 'delivered' && status != 'cancelled')
            Row(
              children: [
                if (status == 'pending')
                  _actionButton('Confirm', const Color(0xFF2563EB), () => _updateStatus(order['id'], 'confirmed')),
                if (status == 'confirmed')
                  _actionButton('Ship', const Color(0xFF8B5CF6), () => _updateStatus(order['id'], 'shipped')),
                if (status == 'shipped')
                  _actionButton('Deliver', const Color(0xFF22C55E), () => _updateStatus(order['id'], 'delivered')),
                const SizedBox(width: 8),
                _actionButton('Cancel', AppColors.error, () => _updateStatus(order['id'], 'cancelled')),
              ],
            ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}
