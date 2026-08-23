import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _loaded = false;

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
      setState(() {
        _addresses = List<Map<String, dynamic>>.from(list);
        _loaded = true;
      });
    } else {
      setState(() {
        _addresses = [
          {'label': 'Home', 'address': '14, Green Park Colony, Jaipur, Rajasthan', 'icon': 'home', 'phone': '9876543210', 'isDefault': true},
          {'label': 'Office', 'address': '201, Tech Park, Malviya Nagar, Jaipur', 'icon': 'work', 'phone': '9876543210', 'isDefault': false},
        ];
        _loaded = true;
      });
      _saveAddresses();
    }
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_addresses', jsonEncode(_addresses));
  }

  IconData _iconFromString(String icon) {
    switch (icon) {
      case 'home': return Icons.home_outlined;
      case 'work': return Icons.work_outline;
      case 'school': return Icons.school_outlined;
      case 'location': return Icons.location_on_outlined;
      default: return Icons.home_outlined;
    }
  }

  void _deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Address?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('Remove ${_addresses[index]['label']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _addresses.removeAt(index));
              _saveAddresses();
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _setDefault(int index) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i]['isDefault'] = (i == index);
      }
    });
    _saveAddresses();
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
        title: Text(
          'My Addresses',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _showAddDialog(context),
            child: Text('+ Add', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ],
      ),
      body: _addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined, size: 64, color: AppColors.inkMuted48),
                  const SizedBox(height: 16),
                  Text('No addresses saved', style: GoogleFonts.inter(fontSize: 16, color: AppColors.inkMuted48)),
                  const SizedBox(height: 8),
                  Text('Add your delivery addresses', style: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Saved Addresses',
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.5),
                  ).animate().fadeIn(),
                  const SizedBox(height: 20),
                  ...List.generate(_addresses.length, (i) {
                    final addr = _addresses[i];
                    final isDefault = addr['isDefault'] == true;
                    return GestureDetector(
                      onLongPress: () => _setDefault(i),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDefault ? AppColors.primary : AppColors.border, width: isDefault ? 2 : 1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: isDefault ? AppColors.primary.withOpacity(0.1) : AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_iconFromString(addr['icon'] ?? 'home'), color: isDefault ? AppColors.primary : AppColors.inkMuted, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(addr['label'] ?? 'Address', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                      if (isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                          child: Text('Default', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(addr['address'] ?? '', style: GoogleFonts.inter(fontSize: 13, color: AppColors.inkSecondary, height: 1.4)),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              icon: Icon(Icons.more_vert, size: 18, color: AppColors.inkMuted),
                              itemBuilder: (ctx) => [
                                PopupMenuItem(value: 'default', child: Text(isDefault ? 'Remove Default' : 'Set as Default')),
                                PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                              ],
                              onSelected: (val) {
                                if (val == 'default') _setDefault(i);
                                if (val == 'delete') _deleteAddress(i);
                              },
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 60 * i)),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedIcon = 'home';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.inkMuted48.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Add New Address', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
              const SizedBox(height: 16),
              Row(
                children: ['home', 'work', 'school', 'location'].map((icon) {
                  final isSelected = selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedIcon = icon),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.canvasParchment,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_iconFromString(icon), color: isSelected ? Colors.white : AppColors.inkMuted48, size: 20),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: 'Label (Home/Office/College)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Full Address',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (labelController.text.isNotEmpty && addressController.text.isNotEmpty) {
                      setState(() {
                        _addresses.add({
                          'label': labelController.text,
                          'address': addressController.text,
                          'icon': selectedIcon,
                          'phone': phoneController.text,
                          'isDefault': _addresses.isEmpty,
                        });
                      });
                      _saveAddresses();
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Save Address', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
