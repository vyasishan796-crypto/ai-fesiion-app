import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class OutfitTile extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final String? price;
  final VoidCallback? onTap;
  final bool isDark;

  const OutfitTile({
    super.key,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.price,
    this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceTile1 : AppColors.canvasParchment,
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withOpacity(0.22),
                  offset: const Offset(3, 5),
                  blurRadius: 30,
                ),
              ],
            ),
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _placeholder,
                  )
                : _placeholder,
          ),
          AppSpacing.heightXs,
          Text(
            title,
            style: isDark
                ? AppTypography.bodyStrongDark
                : AppTypography.bodyStrong,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: isDark
                  ? AppTypography.captionDark
                  : AppTypography.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (price != null) ...[
            const SizedBox(height: 2),
            Text(
              price!,
              style: isDark
                  ? AppTypography.bodyDark
                  : AppTypography.body,
            ),
          ],
        ],
      ),
    );
  }

  Widget get _placeholder {
    return Center(
      child: Icon(
        Icons.checkroom_outlined,
        size: 40,
        color: isDark ? AppColors.bodyMuted : AppColors.inkMuted48,
      ),
    );
  }
}
