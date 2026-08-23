import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'admin_service.dart';

class ProductManagerScreen extends StatefulWidget {
  const ProductManagerScreen({super.key});

  @override
  State<ProductManagerScreen> createState() => _ProductManagerScreenState();
}

class _ProductManagerScreenState extends State<ProductManagerScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await _adminService.getProducts(search: _searchController.text);
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Product?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('Delete "$name" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _adminService.deleteProduct(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product deleted'), backgroundColor: AppColors.success));
        _loadProducts();
      }
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
        title: Text('Products (${_products.length})', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _loadProducts(),
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.inkMuted48),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentPurple))
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.inkMuted48),
                            const SizedBox(height: 16),
                            Text('No products found', style: GoogleFonts.inter(fontSize: 16, color: AppColors.inkMuted48)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _products.length,
                          itemBuilder: (ctx, i) {
                            final product = _products[i];
                            return _buildProductCard(product, i);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(),
        backgroundColor: AppColors.accentPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Product', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildProductCard(dynamic product, int index) {
    final prices = product['platform_prices'] as List? ?? [];
    final inStock = product['in_stock'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              product['image_url'] ?? '',
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60, height: 60, color: AppColors.canvasParchment,
                child: Icon(Icons.image_outlined, color: AppColors.inkMuted48),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'] ?? '', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${product['brand'] ?? ''} • ${product['category'] ?? ''}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.inkMuted48)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('₹${product['price'] ?? 0}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accentPurple)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: inStock ? const Color(0xFF22C55E).withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(inStock ? 'In Stock' : 'Out of Stock', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: inStock ? const Color(0xFF22C55E) : AppColors.error)),
                    ),
                    if (prices.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.accentPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('${prices.length} platforms', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.accentPurple)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, size: 20, color: AppColors.inkMuted48),
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: AppColors.ink), const SizedBox(width: 8), Text('Edit')])),
              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.error), const SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.error))])),
            ],
            onSelected: (val) {
              if (val == 'delete') _deleteProduct(product['id'], product['name']);
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'T-Shirts';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.inkMuted48.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('Add New Product', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 16),
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Product Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentPurple)))),
                const SizedBox(height: 12),
                TextField(controller: brandController, decoration: InputDecoration(labelText: 'Brand', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentPurple)))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentPurple))))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentPurple))),
                        items: ['T-Shirts', 'Shirts', 'Jackets', 'Jeans', 'Sneakers', 'Dresses', 'Accessories', 'Tops', 'Kurtis'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.inter()))).toList(),
                        onChanged: (v) => setSheetState(() => selectedCategory = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: descController, maxLines: 2, decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentPurple)))),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                        final data = {
                          'name': nameController.text,
                          'brand': brandController.text,
                          'price': double.tryParse(priceController.text) ?? 0,
                          'category': selectedCategory,
                          'description': descController.text,
                          'image_url': 'https://picsum.photos/seed/admin/400/500',
                          'in_stock': true,
                          'rating': 4.0,
                          'review_count': 0,
                          'platform': 'StyleAI',
                          'sizes': ['S', 'M', 'L', 'XL'],
                          'colors': [],
                          'tags': [],
                          'delivery_info': 'Free delivery',
                        };
                        final result = await _adminService.createProduct(data);
                        if (result != null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product created!'), backgroundColor: AppColors.success));
                          Navigator.pop(ctx);
                          _loadProducts();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text('Create Product', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}