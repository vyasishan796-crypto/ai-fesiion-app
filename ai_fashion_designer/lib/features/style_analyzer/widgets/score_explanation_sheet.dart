import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/style_analysis.dart';
import '../../../core/services/gemini_analyzer_service.dart';

class ScoreExplanationSheet extends StatefulWidget {
  final StyleAnalysis analysis;
  const ScoreExplanationSheet({super.key, required this.analysis});

  static Future<void> show(BuildContext context, StyleAnalysis analysis) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScoreExplanationSheet(analysis: analysis),
    );
  }

  @override
  State<ScoreExplanationSheet> createState() => _ScoreExplanationSheetState();
}

class _ScoreExplanationSheetState extends State<ScoreExplanationSheet> {
  String? _explanation;
  bool _isLoading = true;
  final _analyzer = GeminiAnalyzerService();

  @override
  void initState() {
    super.initState();
    _loadExplanation();
  }

  Future<void> _loadExplanation() async {
    try {
      final response = await _analyzer.askQuestion(
        widget.analysis,
        'Explain my outfit score in detail. Why did I get ${widget.analysis.totalScore}/100? What are my strongest and weakest factors? Give specific improvement tips for the lowest scoring factors.',
      );
      if (!mounted) return;
      setState(() {
        _explanation = response;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _explanation = 'Your outfit scored ${widget.analysis.totalScore}/100 overall. '
            'Strongest: ${_getStrongestFactor()}. '
            'Needs work: ${_getWeakestFactor()}. '
            'Try adjusting the weakest area for a higher score next time!';
        _isLoading = false;
      });
    }
  }

  String _getStrongestFactor() {
    if (widget.analysis.scoreBreakdown.isEmpty) return 'Overall coordination';
    final sorted = widget.analysis.scoreBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return '${_factorLabel(sorted.first.key)} (${sorted.first.value})';
  }

  String _getWeakestFactor() {
    if (widget.analysis.scoreBreakdown.isEmpty) return 'Minor improvements possible';
    final sorted = widget.analysis.scoreBreakdown.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return '${_factorLabel(sorted.first.key)} (${sorted.first.value})';
  }

  String _factorLabel(String key) {
    const labels = {
      'personalStyle': 'Personal Style',
      'occasion': 'Occasion Fit',
      'color': 'Color Harmony',
      'weather': 'Weather Match',
      'fit': 'Fit',
      'budget': 'Value',
    };
    return labels[key] ?? key;
  }

  Color _scoreColor(int score) {
    if (score >= 90) return const Color(0xFF34C759);
    if (score >= 80) return const Color(0xFF7C4DFF);
    if (score >= 70) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }

  IconData _factorIcon(String key) {
    const icons = {
      'personalStyle': Icons.style_outlined,
      'occasion': Icons.event_outlined,
      'color': Icons.palette_outlined,
      'weather': Icons.wb_sunny_outlined,
      'fit': Icons.straighten_outlined,
      'budget': Icons.payments_outlined,
    };
    return icons[key] ?? Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        Text(
                          'Your Score Explained',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1D1D1F),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTotalScore(),
                    const SizedBox(height: 28),
                    Text(
                      'Score Breakdown',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D1D1F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFactorBars(),
                    const SizedBox(height: 28),
                    Text(
                      'AI Analysis',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D1D1F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExplanation(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalScore() {
    final score = widget.analysis.totalScore;
    final color = _scoreColor(score);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      Text(
                        '/ 100',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.analysis.overallStyle,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.analysis.scoreReason ??
                      '${_getStrongestFactor()} is your strength. ${_getWeakestFactor()} could be improved.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildFactorBars() {
    if (widget.analysis.scoreBreakdown.isEmpty) return const SizedBox();
    final factors = ['personalStyle', 'occasion', 'color', 'weather', 'fit', 'budget'];
    return Column(
      children: factors.map((key) {
        final score = widget.analysis.scoreBreakdown[key] ?? 85;
        final color = _scoreColor(score);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(_factorIcon(key), size: 18, color: color),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: Text(
                  _factorLabel(key),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 32,
                child: Text(
                  '$score',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildExplanation() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F6FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF7C4DFF),
              strokeWidth: 2,
            ),
            const SizedBox(height: 12),
            Text(
              'AI is analyzing your score...',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F6FF), Color(0xFFF0EBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF7C4DFF)),
              const SizedBox(width: 8),
              Text(
                'AI Answer',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7C4DFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _explanation!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF1D1D1F),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}
