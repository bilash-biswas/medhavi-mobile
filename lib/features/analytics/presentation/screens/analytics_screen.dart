import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = AppStrings.isBn(ref);

    final accuracyPercent = (state.overallAccuracy * 100).round();
    final maxWeekly = state.weeklyTrend.fold<int>(
        1, (prev, el) => el > prev ? el : prev);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          AppStrings.tr(ref, 'analytics_title'),
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.t(ref, 'রিফ্রেশ করুন', 'Refresh'),
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            onPressed: () =>
                ref.read(analyticsControllerProvider.notifier).refreshStats(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await ref.read(analyticsControllerProvider.notifier).refreshStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                            value: state.overallAccuracy.clamp(0.0, 1.0),
                            strokeWidth: 8,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                        Text(
                          '${AppStrings.num(ref, accuracyPercent)}%',
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
                            state.totalSolved > 0
                                ? AppStrings.t(
                                    ref,
                                    'মোট ${AppStrings.num(ref, state.totalSolved)}টি প্রশ্নের মধ্যে ${AppStrings.num(ref, state.totalCorrect)}টি সঠিক উত্তর দিয়েছেন।',
                                    'You answered ${state.totalCorrect} out of ${state.totalSolved} questions correctly.',
                                  )
                                : AppStrings.t(
                                    ref,
                                    'আপনার নির্ভুলতা ও বিষয়ভিত্তিক অগ্রগতি দেখতে অনুশীলন শুরু করুন।',
                                    'Start practicing to track your accuracy and subject mastery.',
                                  ),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.35,
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
                      value: AppStrings.num(ref, state.totalSolved),
                      icon: LucideIcons.layers,
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiStatCard(
                      title: AppStrings.tr(ref, 'correct_answers'),
                      value: AppStrings.num(ref, state.totalCorrect),
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
                      value: AppStrings.num(ref, state.mistakesRectified),
                      icon: LucideIcons.refreshCw,
                      color: AppColors.rose,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiStatCard(
                      title: AppStrings.t(
                          ref, 'ধারাবাহিক স্ট্রিক', 'Active Streak'),
                      value: isBn
                          ? '${AppStrings.num(ref, state.streakDays)} দিন'
                          : '${state.streakDays} Days',
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
                AppStrings.t(ref, 'সাপ্তাহিক অনুশীলন ট্রেন্ড',
                    'Weekly Practice Trend'),
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
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(state.weeklyTrend.length, (idx) {
                        final count = state.weeklyTrend[idx];
                        final barHeight = count > 0
                            ? ((count / maxWeekly) * 84).clamp(10.0, 84.0)
                            : 6.0;
                        final daysBn = [
                          'সোম',
                          'মঙ্গল',
                          'বুধ',
                          'বৃহঃ',
                          'শুক্র',
                          'শনি',
                          'রবি'
                        ];
                        final daysEn = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.num(ref, count),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 22,
                              height: barHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: count > 0
                                      ? [AppColors.primary, AppColors.secondary]
                                      : [
                                          Colors.grey.withValues(alpha: 0.25),
                                          Colors.grey.withValues(alpha: 0.35),
                                        ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isBn ? daysBn[idx] : daysEn[idx],
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
                    AppStrings.t(ref, '১০টি বিষয়', '10 Subjects'),
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
                  return _SubjectProgressBar(
                    subj: subj,
                    isDark: isDark,
                    isBn: isBn,
                    ref: ref,
                  );
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
                    AppStrings.t(ref, 'দুর্বল বিষয়ে ড্রিল শুরু করুন',
                        'Start Weak Subject Drill'),
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
  final bool isBn;
  final WidgetRef ref;

  const _SubjectProgressBar({
    required this.subj,
    required this.isDark,
    required this.isBn,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (subj.accuracy * 100).round();

    Color statusColor;
    String statusLabel;

    if (subj.solved == 0) {
      statusColor = Colors.blueGrey;
      statusLabel = isBn ? 'শুরু হয়নি' : 'Not Started';
    } else if (subj.accuracy >= 0.75) {
      statusColor = AppColors.success;
      statusLabel = isBn ? 'শক্তিশালী' : 'Strong';
    } else if (subj.accuracy >= 0.60) {
      statusColor = Colors.amber;
      statusLabel = isBn ? 'মধ্যম' : 'Moderate';
    } else {
      statusColor = AppColors.rose;
      statusLabel = isBn ? 'মনোযোগ প্রয়োজন' : 'Needs Focus';
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
              Expanded(
                child: Text(
                  isBn ? subj.name : subj.nameEn,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    '${AppStrings.num(ref, percent)}%',
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
              value: subj.accuracy.clamp(0.0, 1.0),
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
                isBn
                    ? 'সমাধান: ${AppStrings.num(ref, subj.solved)}টি'
                    : 'Solved: ${subj.solved}',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                isBn
                    ? 'সঠিক: ${AppStrings.num(ref, subj.correct)}টি'
                    : 'Correct: ${subj.correct}',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
