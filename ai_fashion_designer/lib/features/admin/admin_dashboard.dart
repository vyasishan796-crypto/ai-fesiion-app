import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'admin_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await _adminService.getStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
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
        title: Text('Admin Dashboard', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentPurple))
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    const SizedBox(height: 16),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    Text('Quick Actions', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    const SizedBox(height: 12),
                    _buildActionCards(),
                    const SizedBox(height: 24),
                    if (_stats != null) ...[
                      Text('Recent Orders', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      const SizedBox(height: 12),
                      _buildRecentOrders(),
                    ],
                    const SizedBox(height: 24),
                    if (_stats != null) ...[
                      Text('Order Status', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      const SizedBox(height: 12),
                      _buildOrderStatusChart(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox();
    final cards = [
      {'title': 'Total Revenue', 'value': '₹${(_stats!['total_revenue'] ?? 0).toStringAsFixed(0)}', 'icon': Icons.currency_rupee_rounded, 'color': const Color(0xFF22C55E)},
      {'title': 'Total Orders', 'value': '${_stats!['total_orders'] ?? 0}', 'icon': Icons.shopping_bag_rounded, 'color': AppColors.accentPurple},
      {'title': 'Total Users', 'value': '${_stats!['total_users'] ?? 0}', 'icon': Icons.people_rounded, 'color': const Color(0xFF2563EB)},
      {'title': 'Products', 'value': '${_stats!['total_products'] ?? 0}', 'icon': Icons.inventory_2_rounded, 'color': const Color(0xFFF59E0B)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5),
      itemCount: cards.length,
      itemBuilder: (ctx, i) {
        final card = cards[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: (card['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(card['icon'] as IconData, color: card['color'] as Color, size: 20),
              ),
              const Spacer(),
              Text(card['value'] as String, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
              Text(card['title'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 80 * i));
      },
    );
  }

  Widget _buildActionCards() {
    final actions = [
      {'title': 'Manage Products', 'subtitle': 'Add, edit, delete products', 'icon': Icons.inventory_2_outlined, 'color': AppColors.accentPurple, 'route': '/admin/products'},
      {'title': 'Manage Orders', 'subtitle': 'Update order status', 'icon': Icons.receipt_long_outlined, 'color': const Color(0xFF2563EB), 'route': '/admin/orders'},
      {'title': 'View Users', 'subtitle': 'All registered users', 'icon': Icons.people_outline_rounded, 'color': const Color(0xFF22C55E), 'route': '/admin/users'},
      {'title': 'Django Admin', 'subtitle': 'Full backend management', 'icon': Icons.admin_panel_settings_outlined, 'color': const Color(0xFFF59E0B), 'route': ''},
    ];

    return Column(
      children: actions.map((a) {
        return GestureDetector(
          onTap: () {
            if (a['route'] != '') {
              context.push(a['route'] as String);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: (a['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['title'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
                      Text(a['subtitle'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.inkMuted48.withOpacity(0.5)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentOrders() {
    final orders = _stats!['recent_orders'] as List? ?? [];
    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Center(child: Text('No orders yet', style: GoogleFonts.inter(color: AppColors.inkMuted48))),
      );
    }

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length > 5 ? 5 : orders.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (ctx, i) {
          final order = orders[i];
          final status = order['status'] ?? 'pending';
          final color = _statusColor(status);
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.receipt_rounded, color: color, size: 20),
            ),
            title: Text('Order #${order['id']}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('₹${order['total'] ?? 0}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderStatusChart() {
    final pending = _stats!['pending_orders'] ?? 0;
    final shipped = _stats!['shipped_orders'] ?? 0;
    final delivered = _stats!['delivered_orders'] ?? 0;
    final cancelled = _stats!['cancelled_orders'] ?? 0;
    final total = pending + shipped + delivered + cancelled;

    if (total == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          _statusBar('Pending', pending, total, const Color(0xFFF59E0B)),
          const SizedBox(height: 8),
          _statusBar('Shipped', shipped, total, const Color(0xFF2563EB)),
          const SizedBox(height: 8),
          _statusBar('Delivered', delivered, total, const Color(0xFF22C55E)),
          const SizedBox(height: 8),
          _statusBar('Cancelled', cancelled, total, const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _statusBar(String label, int count, int total, Color color) {
    final fraction = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink))),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 30, child: Text('$count', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink), textAlign: TextAlign.right)),
      ],
    );
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
}
