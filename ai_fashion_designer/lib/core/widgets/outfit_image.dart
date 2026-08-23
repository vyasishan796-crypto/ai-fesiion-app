import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OutfitImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? child;

  const OutfitImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.22),
            offset: const Offset(3, 5),
            blurRadius: 30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: child ??
            (imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: fit,
                    width: width,
                    height: height,
                    errorBuilder: (context, error, stackTrace) {
                      return _placeholder;
                    },
                  )
                : _placeholder),
      ),
    );
  }

  Widget get _placeholder {
    return Container(
      width: width,
      height: height,
      color: AppColors.canvasParchment,
      child: const Center(
        child: Icon(
          Icons.checkroom_outlined,
          size: 48,
          color: AppColors.inkMuted48,
        ),
      ),
    );
  }
}
