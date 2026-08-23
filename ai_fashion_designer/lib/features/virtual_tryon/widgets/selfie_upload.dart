import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class SelfieUpload extends StatelessWidget {
  final File? image;
  final ValueChanged<File> onImageSelected;

  const SelfieUpload({
    super.key,
    this.image,
    required this.onImageSelected,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Your Photo',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            letterSpacing: -0.224,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: image != null ? AppColors.canvasParchment : AppColors.canvas,
              borderRadius: AppRadius.lg,
              border: Border.all(
                color: image != null ? AppColors.primary : AppColors.hairline,
                width: image != null ? 2 : 1,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: AppRadius.lg,
                    child: Image.file(
                      image!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 48,
                        color: AppColors.inkMuted48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to upload photo',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          color: AppColors.inkMuted48,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Camera or Gallery',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.inkMuted48,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(
                'Camera',
                style: GoogleFonts.inter(),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                'Gallery',
                style: GoogleFonts.inter(),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
