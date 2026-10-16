import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/bengali_numeral_converter.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accuracyPercent = (state.overallAccuracy * 100).toInt();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          AppStrings.tr(ref, 'analytics_title'),
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Overall Accuracy Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Circular Progress Indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 84,
                        height: 84,
                        child: CircularProgressIndicator(
                          value: state.overallAccuracy,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF10B981), // Emerald green
                          ),
                        ),
                      ),
                      Text(
                        '${BengaliNumeralConverter.toBengaliNumber(accuracyPercent)}%',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr(ref, 'overall_accuracy'),
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'আপনার প্রস্তুতি অন্যান্য প্রার্থীদের তুলনায় শীর্ষ ২২% এর মধ্যে রয়েছে।',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. KPI Cards Grid
            Row(
              children: [
                Expanded(
                  child: _KpiStatCard(
                    title: AppStrings.tr(ref, 'total_solved'),
                    value: BengaliNumeralConverter.toBengaliNumber(state.totalSolved),
                    icon: LucideIcons.layers,
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KpiStatCard(
                    title: AppStrings.tr(ref, 'correct_answers'),
                    value: BengaliNumeralConverter.toBengaliNumber(state.totalCorrect),
                    icon: LucideIcons.checkCircle2,
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _KpiStatCard(
                    title: AppStrings.tr(ref, 'mistakes_rectified'),
                    value: BengaliNumeralConverter.toBengaliNumber(state.mistakesRectified),
                    icon: LucideIcons.refreshCw,
                    color: AppColors.rose,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KpiStatCard(
                    title: 'স্টাডি স্ট্রিক',
                    value: '${BengaliNumeralConverter.toBengaliNumber(state.streakDays)} দিন',
                    icon: LucideIcons.flame,
                    color: Colors.orange,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Weekly Study Activity Chart
            Text(
              'সাপ্তাহিক অনুশীলন ট্রেন্ড',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(state.weeklyTrend.length, (idx) {
                      final count = state.weeklyTrend[idx];
                      final maxVal = 120.0;
                      final barHeight = (count / maxVal) * 90;
                      final days = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'];

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            BengaliNumeralConverter.toBengaliNumber(count),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 22,
                            height: barHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: idx == 5 // Saturday peak
                                    ? [AppColors.primary, AppColors.secondary]
                                    : [
                                        AppColors.primary.withValues(alpha: 0.6),
                                        AppColors.primary.withValues(alpha: 0.9),
                                      ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            days[idx],
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Subject-wise Mastery Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.tr(ref, 'subject_mastery'),
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '১০টি বিষয়',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final subj = state.subjects[index];
                return _SubjectProgressBar(subj: subj, isDark: isDark);
              },
            ),
            const SizedBox(height: 24),

            // 5. Practice CTA
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(LucideIcons.playCircle, size: 18),
                label: Text(
                  'দুর্বল বিষয়ে ড্রিল শুরু করুন',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => context.go('/practice'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _KpiStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _KpiStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectProgressBar extends StatelessWidget {
  final SubjectPerformance subj;
  final bool isDark;

  const _SubjectProgressBar({required this.subj, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final percent = (subj.accuracy * 100).toInt();

    Color statusColor;
    String statusLabel;

    if (subj.accuracy >= 0.75) {
      statusColor = AppColors.success;
      statusLabel = 'শক্তিশালী';
    } else if (subj.accuracy >= 0.60) {
      statusColor = Colors.amber;
      statusLabel = 'মধ্যম';
    } else {
      statusColor = AppColors.rose;
      statusLabel = 'মনোযোগ প্রয়োজন';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subj.name,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${BengaliNumeralConverter.toBengaliNumber(percent)}%',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linear Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: subj.accuracy,
              minHeight: 6,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'সমাধান: ${BengaliNumeralConverter.toBengaliNumber(subj.solved)}টি',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 10,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                'সঠিক: ${BengaliNumeralConverter.toBengaliNumber(subj.correct)}টি',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 10,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
