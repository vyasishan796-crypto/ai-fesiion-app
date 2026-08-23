import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/booking.dart';
import '../../core/services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _bookingService.loadBookings();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.canvasParchment, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink)),
                ),
                const SizedBox(width: 12),
                Text('My Bookings', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
              ]),
            ),
            const SizedBox(height: 12),
            Container(
              color: AppColors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.accentPurple,
                unselectedLabelColor: AppColors.inkMuted48,
                labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                indicatorColor: AppColors.accentPurple,
                indicatorWeight: 2.5,
                tabs: [
                  Tab(text: 'Active (${_bookingService.pendingBookings.length})'),
                  Tab(text: 'Completed (${_bookingService.completedBookings.length})'),
                  Tab(text: 'Cancelled (${_bookingService.cancelledBookings.length})'),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _bookingService,
                builder: (context, _) => TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(_bookingService.pendingBookings, isActive: true),
                    _buildBookingList(_bookingService.completedBookings),
                    _buildBookingList(_bookingService.cancelledBookings),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings, {bool isActive = false}) {
    if (bookings.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(isActive ? Icons.pending_actions_rounded : Icons.check_circle_outline_rounded, size: 48, color: AppColors.inkMuted48.withOpacity(0.3)),
        const SizedBox(height: 12),
        Text('No ${isActive ? 'active' : ''} bookings yet', style: GoogleFonts.inter(fontSize: 16, color: AppColors.inkMuted48)),
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _bookingCard(bookings[index]),
    );
  }

  Widget _bookingCard(Booking booking) {
    final statusColor = _getStatusColor(booking.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.dividerSoft), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(booking.tailor.image, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 44, height: 44, color: AppColors.canvasParchment, child: const Icon(Icons.content_cut_rounded, size: 18, color: AppColors.inkMuted48)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.tailor.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
              Text(booking.serviceTypeText, style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(booking.statusText, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.inkMuted48),
            const SizedBox(width: 4),
            Text('${booking.date.day}/${booking.date.month}/${booking.date.year}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
            const SizedBox(width: 12),
            Icon(Icons.access_time_rounded, size: 12, color: AppColors.inkMuted48),
            const SizedBox(width: 4),
            Text(booking.timeSlot, style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
            const Spacer(),
            Text('₹${booking.estimatedPrice}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accentPurple)),
          ]),
          if (booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _cancelBooking(booking),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text('Cancel', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: 60)).slideY(begin: 0.03),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return const Color(0xFFF59E0B);
      case BookingStatus.confirmed: return AppColors.accentPurple;
      case BookingStatus.inProgress: return const Color(0xFF3B82F6);
      case BookingStatus.completed: return const Color(0xFF22C55E);
      case BookingStatus.cancelled: return const Color(0xFFEF4444);
    }
  }

  void _cancelBooking(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancel Booking?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('Cancel booking with ${booking.tailor.name}?', style: GoogleFonts.inter(fontSize: 14, color: AppColors.inkMuted48)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('No', style: GoogleFonts.inter(color: AppColors.inkMuted48))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Yes, Cancel', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirm == true) await _bookingService.cancelBooking(booking.id);
  }
}
