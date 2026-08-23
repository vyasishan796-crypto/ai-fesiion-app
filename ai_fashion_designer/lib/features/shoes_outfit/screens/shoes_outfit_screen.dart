import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/data/outfit_data.dart';
import '../../../core/models/product.dart';

class ShoesOutfitScreen extends StatefulWidget {
  final Product? initialShoes;
  const ShoesOutfitScreen({super.key, this.initialShoes});
  @override
  State<ShoesOutfitScreen> createState() => _ShoesOutfitScreenState();
}

class _ShoesOutfitScreenState extends State<ShoesOutfitScreen> {
  File? _shoesImage;
  String? _shoesImageB64;
  Product? _selectedShoes;
  String? _outfitImageUrl;
  Map<String, dynamic>? _shoesAnalysis;
  bool _loading = false;
  final _promptCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialShoes != null) {
      _selectedShoes = widget.initialShoes;
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    final f = await ImagePicker().pickImage(source: src, maxWidth: 1024, imageQuality: 85);
    if (f == null) return;
    final file = File(f.path);
    final bytes = await file.readAsBytes();
    setState(() {
      _shoesImage = file;
      _shoesImageB64 = base64Encode(bytes);
      _selectedShoes = null;
    });
  }

  void _pickFromProducts() {
    final shoes = OutfitData.allProducts.where((p) => p.category == 'Sneakers' || p.category == 'Footwear').take(20).toList();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => DraggableScrollableSheet(initialChildSize: 0.7, maxChildSize: 0.9, expand: false, builder: (_, c) => GridView.builder(controller: c, padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: shoes.length, itemBuilder: (_, i) {
      final p = shoes[i];
      final sel = _selectedShoes?.id == p.id;
      return GestureDetector(onTap: () { setState(() { _selectedShoes = p; _shoesImage = null; _shoesImageB64 = null; }); Navigator.pop(ctx); }, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? AppColors.primary : AppColors.dividerSoft, width: sel ? 2 : 1)), clipBehavior: Clip.antiAlias, child: Column(children: [Expanded(child: CachedNetworkImage(imageUrl: p.imageUrl, fit: BoxFit.cover, width: double.infinity)), Padding(padding: const EdgeInsets.all(8), child: Text(p.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis))])));
    })));
  }

  Future<void> _generate() async {
    if (_shoesImageB64 == null && _selectedShoes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick shoes image or product first'), backgroundColor: AppColors.warning));
      return;
    }
    setState(() => _loading = true);
    try {
      final body = <String, dynamic>{
        if (_shoesImageB64 != null) 'shoes_image_base64': _shoesImageB64!,
        if (_selectedShoes != null) 'shoes_product_id': _selectedShoes!.id,
        'user_prompt': _promptCtrl.text,
        'mime': 'image/jpeg',
      };
      final resp = await http.post(Uri.parse('${ApiConstants.backendBaseUrl}/shoes-outfit/'), headers: {
        'Content-Type': 'application/json',
        if (AuthService.accessToken != null && !AuthService.accessToken!.startsWith('local_token_'))
          'Authorization': 'Bearer ${AuthService.accessToken}',
      }, body: jsonEncode(body)).timeout(const Duration(seconds: 60));
      if (resp.statusCode != 200) throw Exception(resp.body);
      final data = jsonDecode(resp.body);
      setState(() {
        _outfitImageUrl = data['outfit_image_url'];
        _shoesAnalysis = data['shoes_analysis'];
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white), onPressed: () => Navigator.pop(context)), centerTitle: true, title: Text('SHOES → OUTFIT', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SELECT SHOES', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
          const SizedBox(height: 12),
          // Shoes preview
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey[200]!)),
            clipBehavior: Clip.antiAlias,
            child: _selectedShoes != null
                ? CachedNetworkImage(imageUrl: _selectedShoes!.imageUrl, fit: BoxFit.cover, width: double.infinity, height: 200)
                : _shoesImage != null
                    ? Image.file(_shoesImage!, fit: BoxFit.cover, width: double.infinity, height: 200)
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.image_outlined, size: 40, color: AppColors.inkMuted48), const SizedBox(height: 8), Text('No shoes selected', style: GoogleFonts.inter(color: AppColors.inkMuted48))]),
          ),
          if (_selectedShoes != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('${_selectedShoes!.brand} ${ _selectedShoes!.name} • ${_selectedShoes!.category}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _pillBtn('Gallery', Icons.photo_library_outlined, () => _pickImage(ImageSource.gallery))),
            const SizedBox(width: 10),
            Expanded(child: _pillBtn('Camera', Icons.camera_alt_outlined, () => _pickImage(ImageSource.camera))),
            const SizedBox(width: 10),
            Expanded(child: _pillBtn('Products', Icons.storefront_outlined, _pickFromProducts)),
          ]),
          const SizedBox(height: 20),
          Text('OUTFIT STYLE (OPTIONAL)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
          const SizedBox(height: 10),
          TextField(
            controller: _promptCtrl,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              hintText: 'e.g. streetwear college look, casual',
              hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.inkMuted48),
              filled: true, fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 52,
            child: GestureDetector(
              onTap: _loading ? null : _generate,
              child: Container(
                decoration: BoxDecoration(color: _loading ? Colors.grey[400] : Colors.black, borderRadius: BorderRadius.circular(30)),
                child: Center(child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('GENERATE OUTFIT →', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1))),
              ),
            ),
          ),
          if (_shoesAnalysis != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
              child: Row(children: [
                const Icon(Icons.auto_awesome, size: 18, color: Colors.black),
                const SizedBox(width: 8),
                Expanded(child: Text('Shoes: ${_shoesAnalysis!['color']} ${_shoesAnalysis!['style']} • ${_shoesAnalysis!['material']}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black))),
              ]),
            ),
          ],
          if (_outfitImageUrl != null) ...[
            const SizedBox(height: 20),
            Text('AI OUTFIT FOR YOUR SHOES', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(_outfitImageUrl!, fit: BoxFit.cover, width: double.infinity, height: 420, loadingBuilder: (c, child, p) => p == null ? child : Container(height: 420, color: Colors.grey[100], child: const Center(child: CircularProgressIndicator(color: Colors.black))), errorBuilder: (_,__,___) => Container(height: 200, color: Colors.grey[100], child: const Icon(Icons.broken_image))),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _pillBtn('Regenerate', Icons.refresh_rounded, _generate)),
              const SizedBox(width: 10),
              Expanded(child: _pillBtn('Save', Icons.bookmark_outline, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!'), backgroundColor: Colors.black)))),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _pillBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 1.2)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: Colors.black), const SizedBox(width: 6), Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black))]),
      ),
    );
  }
}
