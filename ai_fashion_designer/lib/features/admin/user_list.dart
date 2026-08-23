import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'admin_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _adminService.getUsers();
    if (mounted) {
      setState(() {
        _users = users;
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
        title: Text('Users (${_users.length})', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentPurple))
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (ctx, i) => _buildUserCard(_users[i], i),
              ),
            ),
    );
  }

  Widget _buildUserCard(dynamic user, int index) {
    final isAdmin = user['is_superuser'] ?? false;
    final orderCount = user['order_count'] ?? 0;
    final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    final initials = name.isNotEmpty ? name[0].toUpperCase() : (user['username'] ?? '?')[0].toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isAdmin ? AppColors.accentPurple.withOpacity(0.1) : const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(initials, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: isAdmin ? AppColors.accentPurple : const Color(0xFF2563EB))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user['username'] ?? '', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.accentPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('ADMIN', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.accentPurple)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(user['email'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 12, color: AppColors.inkMuted48),
                    const SizedBox(width: 4),
                    Text('$orderCount orders', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.inkMuted48.withOpacity(0.4)),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
  }
}
