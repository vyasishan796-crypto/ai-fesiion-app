import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/outfit_matcher_service.dart';

class MatchedOutfitsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> matchedOutfits;
  final VoidCallback? onReset;

  const MatchedOutfitsWidget({
    super.key,
    required this.matchedOutfits,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    if (matchedOutfits.isEmpty) return const SizedBox();

    final matcher = OutfitMatcherService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Best Matches from 1000 Outfits',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D1D1F),
                    ),
                  ),
                  Text(
                    'Top ${matchedOutfits.length} outfits matching your style',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: matchedOutfits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final outfit = matchedOutfits[index];
              final matchScore = (outfit['_matchScore'] as double).round();
              final imageUrl = matcher.getImageUrl(outfit, index);
              return _buildMatchedCard(context, outfit, imageUrl, matchScore, index);
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildMatchedCard(
    BuildContext context,
    Map<String, dynamic> outfit,
    String imageUrl,
    int matchScore,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showOutfitDetail(context, outfit, imageUrl);
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _getScoreColor(matchScore).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF5F5F7),
                        child: const Center(
                          child: Icon(Icons.checkroom, size: 40, color: Color(0xFFBDBDBD)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(matchScore),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$matchScore% match',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (outfit['top'] != null && (outfit['top'] as String).isNotEmpty)
                      Text(
                        outfit['top'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D1D1F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    if (outfit['bottom'] != null && (outfit['bottom'] as String).isNotEmpty)
                      Text(
                        outfit['bottom'],
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (outfit['shoes'] != null && (outfit['shoes'] as String).isNotEmpty)
                      Text(
                        outfit['shoes'],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildTag(outfit['season'] ?? '', const Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        _buildTag(outfit['occasion'] ?? '', const Color(0xFF7C3AED)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      outfit['budget'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80), duration: 400.ms)
     .slideX(begin: 0.1, end: 0);
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 70) return const Color(0xFF10B981);
    if (score >= 50) return const Color(0xFF2563EB);
    if (score >= 30) return const Color(0xFFF59E0B);
    return const Color(0xFF6B7280);
  }

  void _showOutfitDetail(BuildContext context, Map<String, dynamic> outfit, String imageUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: const Color(0xFFF5F5F7),
                    child: const Center(child: Icon(Icons.checkroom, size: 60, color: Color(0xFFBDBDBD))),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildDetailChip('${outfit['occasion']}', const Color(0xFF7C3AED)),
                  const SizedBox(width: 6),
                  _buildDetailChip('${outfit['style']}', const Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  _buildDetailChip('${outfit['season']}', const Color(0xFF10B981)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Outfit Details',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1D1D1F),
                ),
              ),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.checkroom, 'Top', '${outfit['top'] ?? 'N/A'}'),
              if (outfit['layer'] != null && (outfit['layer'] as String).isNotEmpty)
                _buildDetailRow(Icons.layers, 'Layer', '${outfit['layer']}'),
              _buildDetailRow(Icons.straighten, 'Bottom', '${outfit['bottom'] ?? 'N/A'}'),
              _buildDetailRow(Icons.directions_walk, 'Shoes', '${outfit['shoes'] ?? 'N/A'}'),
              const SizedBox(height: 16),
              _buildInfoRow('Budget', '${outfit['budget'] ?? 'N/A'}'),
              _buildInfoRow('Skin Tone', '${outfit['skinTone'] ?? 'N/A'}'),
              _buildInfoRow('Good Colors', '${outfit['goodColors'] ?? 'N/A'}'),
              _buildInfoRow('Style Score', '${outfit['score'] ?? 0}%'),
              _buildInfoRow('Match Score', '${outfit['_matchScore']?.round() ?? 0}%'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1D1D1F),
            ),
          ),
        ],
      ),
    );
  }
}
