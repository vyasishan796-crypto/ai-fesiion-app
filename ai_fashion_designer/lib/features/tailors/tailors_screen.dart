import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/booking.dart';
import '../../core/services/booking_service.dart';

class TailorsScreen extends StatefulWidget {
  const TailorsScreen({super.key});

  @override
  State<TailorsScreen> createState() => _TailorsScreenState();
}

class _TailorsScreenState extends State<TailorsScreen> {
  final BookingService _bookingService = BookingService();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isMapView = false;
  LatLng? _userPos;
  bool _locLoading = false;
  final MapController _mapController = MapController();

  List<Tailor> get _filteredTailors {
    var list = _searchQuery.isEmpty
        ? BookingService.defaultTailors
        : BookingService.defaultTailors.where((t) =>
            t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.specialty.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.address.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    // Sort by distance if location available
    if (_userPos != null) {
      final Distance d = const Distance();
      list = List.from(list)..sort((a, b) {
        final da = d.as(LengthUnit.Kilometer, _userPos!, LatLng(a.lat, a.lng));
        final db = d.as(LengthUnit.Kilometer, _userPos!, LatLng(b.lat, b.lng));
        return da.compareTo(db);
      });
    }
    return list;
  }

  String _distanceText(Tailor t) {
    if (_userPos == null) return t.distance;
    final d = const Distance().as(LengthUnit.Kilometer, _userPos!, LatLng(t.lat, t.lng));
    return d < 1 ? '${(d * 1000).round()} m' : '${d.toStringAsFixed(1)} km';
  }

  @override
  void initState() {
    super.initState();
    _bookingService.loadBookings();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _locLoading = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() => _locLoading = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      setState(() {
        _userPos = LatLng(pos.latitude, pos.longitude);
        _locLoading = false;
      });
    } catch (_) {
      setState(() => _locLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: Text('TAILORS', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2)),
        actions: [
          Stack(clipBehavior: Clip.none, children: [
            IconButton(icon: const Icon(Icons.receipt_long_rounded, size: 22), color: Colors.white, onPressed: () => context.push('/my-bookings')),
            if (_bookingService.bookingCount > 0)
              Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Text('${_bookingService.bookingCount}', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black)))),
          ]),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey[200]!)),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search tailors...',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.inkMuted48),
                      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _getLocation,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14)),
                  child: _locLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.my_location_rounded, size: 20, color: Colors.white),
                ),
              ),
            ]),
          ),
          // List | Map toggle
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Expanded(child: _toggleBtn('LIST', Icons.list_rounded, !_isMapView, () => setState(() => _isMapView = false))),
                Expanded(child: _toggleBtn('MAP', Icons.map_outlined, _isMapView, () => setState(() => _isMapView = true))),
              ]),
            ),
          ),
          Expanded(
            child: _filteredTailors.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: const Icon(Icons.content_cut_rounded, size: 36, color: AppColors.inkMuted48)),
                      const SizedBox(height: 14),
                      Text('NO TAILORS FOUND', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
                    ]),
                  )
                : _isMapView
                    ? Column(children: [
                        Container(
                          height: 280,
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey[200]!)),
                          child: Stack(children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _userPos ?? const LatLng(26.9124, 75.7873),
                                initialZoom: 12.5,
                              ),
                              children: [
                                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.styleai.app'),
                                MarkerLayer(
                                  markers: [
                                    if (_userPos != null)
                                      Marker(
                                        point: _userPos!,
                                        width: 40, height: 40,
                                        child: Container(
                                          decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                                          child: const Icon(Icons.person_rounded, size: 18, color: Colors.white),
                                        ),
                                      ),
                                    ..._filteredTailors.map((t) => Marker(
                                          point: LatLng(t.lat, t.lng),
                                          width: 36, height: 36,
                                          child: GestureDetector(
                                            onTap: () => _showBookingDialog(t),
                                            child: Container(
                                              decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)]),
                                              child: const Icon(Icons.content_cut_rounded, size: 16, color: Colors.white),
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 12, right: 12,
                              child: GestureDetector(
                                onTap: () {
                                  if (_userPos != null) _mapController.move(_userPos!, 14);
                                },
                                child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]), child: const Icon(Icons.my_location_rounded, size: 20, color: Colors.black)),
                              ),
                            ),
                            if (_userPos == null)
                              Positioned(
                                bottom: 12, left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                                  child: Text('TAP LOC TO ENABLE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                                ),
                              ),
                          ]),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: _filteredTailors.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) => _buildTailorCard(_filteredTailors[index], index),
                          ),
                        ),
                      ])
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: _filteredTailors.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) => _buildTailorCard(_filteredTailors[index], index),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(color: selected ? Colors.black : Colors.transparent, borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 14, color: selected ? Colors.white : AppColors.inkMuted48),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.inkMuted48, letterSpacing: 1)),
          ]),
        ),
      ),
    );
  }

  Widget _buildTailorCard(Tailor tailor, int index) {
    return GestureDetector(
      onTap: () => _showBookingDialog(tailor),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey[200]!)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 64, height: 64, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Image.network(tailor.image, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.content_cut_rounded, color: AppColors.inkMuted48)))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tailor.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.verified_rounded, size: 10, color: Colors.white), const SizedBox(width: 4), Text('VERIFIED', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5))]),
                      ),
                      const SizedBox(height: 6),
                      Text(tailor.specialty, style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: tailor.isOpen ? Colors.black : Colors.grey[200], borderRadius: BorderRadius.circular(20)), child: Text(tailor.isOpen ? 'OPEN' : 'CLOSED', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: tailor.isOpen ? Colors.white : AppColors.inkMuted48, letterSpacing: 0.5))),
                          const SizedBox(width: 8),
                          const Icon(Icons.star_rounded, size: 14, color: Colors.black),
                          const SizedBox(width: 2),
                          Text('${tailor.rating}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                          const SizedBox(width: 4),
                          Text('(${tailor.reviewCount})', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.inkMuted48),
                const SizedBox(width: 4),
                Expanded(child: Text(tailor.address, style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text(_distanceText(tailor), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.access_time_rounded, size: 14, color: AppColors.inkMuted48), const SizedBox(width: 4), Text('${tailor.openTime} - ${tailor.closeTime}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48))]),
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6, children: tailor.services.take(4).map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)), child: Text(s, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.inkMuted48)))).toList()),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: GestureDetector(onTap: () async { HapticFeedback.lightImpact(); final uri = Uri.parse('tel:${tailor.phone.replaceAll(RegExp(r'[^0-9+]'), '')}'); if (await canLaunchUrl(uri)) await launchUrl(uri); }, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(30)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.phone_rounded, size: 16, color: Colors.black), const SizedBox(width: 6), Text('CALL', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.5))])))),
                const SizedBox(width: 8),
                Expanded(child: GestureDetector(onTap: () async { HapticFeedback.lightImpact(); final query = Uri.encodeComponent(tailor.address); final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.directions_rounded, size: 16, color: Colors.black), const SizedBox(width: 6), Text('MAP', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: 0.5))])))),
                const SizedBox(width: 8),
                Expanded(child: GestureDetector(onTap: tailor.isOpen ? () => _showBookingDialog(tailor) : null, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: tailor.isOpen ? Colors.black : Colors.grey[300], borderRadius: BorderRadius.circular(30)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.calendar_today_rounded, size: 14, color: tailor.isOpen ? Colors.white : AppColors.inkMuted48), const SizedBox(width: 6), Text('BOOK', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: tailor.isOpen ? Colors.white : AppColors.inkMuted48, letterSpacing: 0.5))])))),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: 60 * index)).slideY(begin: 0.05),
    );
  }

  void _showBookingDialog(Tailor tailor) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => _BookingSheet(tailor: tailor, bookingService: _bookingService));
    if (result != null && mounted) context.push('/booking-payment', extra: result);
  }
}

class _BookingSheet extends StatefulWidget {
  final Tailor tailor;
  final BookingService bookingService;
  const _BookingSheet({required this.tailor, required this.bookingService});
  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int _selectedService = 0;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _selectedTimeSlot = 0;
  final TextEditingController _notesController = TextEditingController();
  final List<String> _timeSlots = ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'];
  @override
  void dispose() { _notesController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            Container(width: 50, height: 50, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Image.network(widget.tailor.image, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.content_cut_rounded, color: AppColors.inkMuted48)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.tailor.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)), Text(widget.tailor.specialty, style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48))])),
          ]),
          const SizedBox(height: 20),
          Text('SERVICE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(widget.tailor.services.length, (i) {
            final isSelected = _selectedService == i;
            return GestureDetector(onTap: () => setState(() => _selectedService = i), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.grey[100], borderRadius: BorderRadius.circular(20)), child: Text(widget.tailor.services[i], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.inkMuted48))));
          })),
          const SizedBox(height: 20),
          Text('DATE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
          const SizedBox(height: 10),
          SizedBox(height: 56, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: 14, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (context, index) {
            final date = DateTime.now().add(Duration(days: index + 1));
            final isSelected = _isSameDay(_selectedDate, date);
            return GestureDetector(onTap: () => setState(() => _selectedDate = date), child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 56, decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(['SUN','MON','TUE','WED','THU','FRI','SAT'][date.weekday % 7], style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? Colors.white70 : AppColors.inkMuted48, letterSpacing: 0.5)), const SizedBox(height: 2), Text('${date.day}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : Colors.black))]))); 
          })),
          const SizedBox(height: 20),
          Text('TIME', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(_timeSlots.length, (i) {
            final isSelected = _selectedTimeSlot == i;
            return GestureDetector(onTap: () => setState(() => _selectedTimeSlot = i), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.grey[100], borderRadius: BorderRadius.circular(20)), child: Text(_timeSlots[i], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.inkMuted48))));
          })),
          const SizedBox(height: 20),
          Text('NOTES', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
          const SizedBox(height: 10),
          TextField(controller: _notesController, maxLines: 3, style: GoogleFonts.inter(fontSize: 13, color: Colors.black), decoration: InputDecoration(hintText: 'Describe your requirements...', hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48), filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 1.5)), contentPadding: const EdgeInsets.all(14))),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 52,
            child: GestureDetector(onTap: _confirmBooking, child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)), child: Center(child: Text('PROCEED TO PAYMENT', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1))))),
          ),
        ]),
      ),
    );
  }
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  void _confirmBooking() {
    final services = widget.tailor.services;
    final service = services[_selectedService].toLowerCase();
    ServiceType serviceType;
    if (service.contains('custom') || service.contains('bespoke') || service.contains('streetwear') || service.contains('formal') || service.contains('ethnic') || service.contains('western') || service.contains('kur')) serviceType = ServiceType.customTailoring;
    else if (service.contains('alter') || service.contains('hem') || service.contains('zipper') || service.contains('patch') || service.contains('denim') || service.contains('repair')) serviceType = ServiceType.alteration;
    else if (service.contains('measure')) serviceType = ServiceType.measurement;
    else serviceType = ServiceType.consultation;
    Navigator.pop(context, {'tailor': widget.tailor, 'serviceType': serviceType, 'date': _selectedDate, 'timeSlot': _timeSlots[_selectedTimeSlot], 'notes': _notesController.text});
  }
}
