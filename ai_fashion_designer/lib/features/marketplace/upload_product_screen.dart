import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({super.key});

  @override
  State<UploadProductScreen> createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'T-Shirts';
  String _selectedGender = 'Men';
  String _selectedCondition = 'New';
  File? _selectedImage;
  final List<String> _selectedSizes = [];
  bool _isSaving = false;

  static const List<String> _categories = [
    'T-Shirts', 'Shirts', 'Jackets', 'Jeans', 'Sneakers', 'Tops',
    'Dresses', 'Kurtis', 'Bags', 'Accessories', 'Trousers', 'Hoodies',
  ];
  static const List<String> _genders = ['Men', 'Women', 'Unisex'];
  static const List<String> _conditions = ['New', 'Like New', 'Good', 'Fair'];
  static const List<String> _menSizes = ['S', 'M', 'L', 'XL', 'XXL'];
  static const List<String> _womenSizes = ['XS', 'S', 'M', 'L', 'XL'];
  static const List<String> _shoeSizes = ['6', '7', '8', '9', '10', '11'];

  List<String> get _availableSizes {
    if (_selectedCategory == 'Sneakers') return _shoeSizes;
    return _selectedGender == 'Women' ? _womenSizes : _menSizes;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final listing = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'name': _nameController.text.trim(),
      'brand': _brandController.text.trim(),
      'category': _selectedCategory,
      'gender': _selectedGender.toLowerCase(),
      'price': int.parse(_priceController.text.trim()),
      'originalPrice': int.parse(_priceController.text.trim()),
      'discount': 0,
      'imageUrl': _selectedImage?.path ?? '',
      'description': _descController.text.trim(),
      'sizes': _selectedSizes,
      'condition': _selectedCondition,
      'isUserListing': true,
      'listedAt': DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('user_listings') ?? '[]';
    final listings = jsonDecode(existing) as List;
    listings.add(listing);
    await prefs.setString('user_listings', jsonEncode(listings));

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product listed successfully!'), backgroundColor: AppColors.success),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
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
        title: Text('Sell a Product', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildTextField('Product Name', _nameController, Icons.label_outline, required: true),
              const SizedBox(height: 16),
              _buildTextField('Brand', _brandController, Icons.business_center_outlined, required: true),
              const SizedBox(height: 16),
              _buildTextField('Price (₹)', _priceController, Icons.currency_rupee, required: true, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildDropdown('Category', _selectedCategory, _categories, (v) => setState(() => _selectedCategory = v!)),
              const SizedBox(height: 16),
              _buildDropdown('Gender', _selectedGender, _genders, (v) => setState(() => _selectedGender = v!)),
              const SizedBox(height: 16),
              _buildDropdown('Condition', _selectedCondition, _conditions, (v) => setState(() => _selectedCondition = v!)),
              const SizedBox(height: 16),
              Text('Sizes', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSizes.map((size) {
                  final isSelected = _selectedSizes.contains(size);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        if (isSelected) _selectedSizes.remove(size);
                        else _selectedSizes.add(size);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentPurple : AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.accentPurple : AppColors.dividerSoft),
                      ),
                      child: Text(size, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.ink)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _buildTextField('Description', _descController, Icons.description_outlined, maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('List Product', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.canvasParchment,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerSoft, width: 1.5),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedImage!, fit: BoxFit.cover),
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.inkMuted48),
                  const SizedBox(height: 12),
                  Text('Tap to add product photo', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text('JPG, PNG up to 5MB', style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted48)),
                ],
              ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool required = false, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: required ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        labelStyle: GoogleFonts.inter(fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentPurple)),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentPurple)),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: GoogleFonts.inter()))).toList(),
      onChanged: onChanged,
    );
  }
}
