import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../controllers/live_quiz_controller.dart';
import 'package:medhavi_mobile/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:medhavi_mobile/features/analytics/presentation/controllers/analytics_controller.dart';

class LiveQuizHubScreen extends ConsumerWidget {
  const LiveQuizHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          AppStrings.tr(ref, 'live_quiz_title'),
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.wait([
            ref.read(analyticsControllerProvider.notifier).refreshStats(),
            ref.read(notificationsControllerProvider.notifier).refresh(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Featured Live Mega Exam Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.radio, size: 12, color: Colors.red),
                            SizedBox(width: 5),
                            Text(
                              'LIVE NOW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.red,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.users, size: 12, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              '১,২৮০ জন প্রার্থী',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    '৪৭তম বিসিএস মেগা মডেল টেস্ট - ০১',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    'সম্পূর্ণ ২০০ নম্বরের পূর্ণাঙ্গ প্রিলিমিনারি পরীক্ষা। নেগেটিভ মার্কিং: -০.৫০',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDC2626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(LucideIcons.playCircle, size: 18),
                      label: Text(
                        'এখনই লাইভ পরীক্ষায় অংশ নিন',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        ref
                            .read(liveQuizControllerProvider.notifier)
                            .startQuiz(durationSeconds: 300);
                        context.push('/live-quiz/exam');
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Speed Drill Card
            Text(
              'দ্রুত কুইজ ও স্পিড ড্রিল',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _QuizFormatCard(
              title: AppStrings.tr(ref, 'speed_drill'),
              subtitle: '৫টি বাছাইকৃত প্রশ্ন • ৫ মিনিট • তাত্ক্ষণিক সমাধান ও KaTeX ব্যাখ্যা',
              icon: LucideIcons.zap,
              badge: 'জনপ্রিয়',
              gradientColors: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
              isDark: isDark,
              onTap: () {
                ref
                    .read(liveQuizControllerProvider.notifier)
                    .startQuiz(durationSeconds: 300);
                context.push('/live-quiz/exam');
              },
            ),
            const SizedBox(height: 12),

            _QuizFormatCard(
              title: 'গাণিতিক যুক্তি স্পিড চ্যালেঞ্জ',
              subtitle: '১০টি সমীকরণ ও বীজগণিত সূত্র • KaTeX ক্যানভাস • ১০ মিনিট',
              icon: LucideIcons.binary,
              badge: 'গণিত স্পেশাল',
              gradientColors: const [Color(0xFF4F46E5), Color(0xFF3730A3)],
              isDark: isDark,
              onTap: () {
                ref
                    .read(liveQuizControllerProvider.notifier)
                    .startQuiz(durationSeconds: 600);
                context.push('/live-quiz/exam');
              },
            ),
            const SizedBox(height: 12),

            _QuizFormatCard(
              title: 'বাংলা সাহিত্য ও ব্যাকরণ চ্যালেঞ্জ',
              subtitle: 'প্রাচীন, মধ্য ও আধুনিক যুগ • ১৫টি প্রশ্ন • ১২ মিনিট',
              icon: LucideIcons.bookMarked,
              badge: 'বাংলা স্পেশাল',
              gradientColors: const [Color(0xFF10B981), Color(0xFF047857)],
              isDark: isDark,
              onTap: () {
                ref
                    .read(liveQuizControllerProvider.notifier)
                    .startQuiz(durationSeconds: 720);
                context.push('/live-quiz/exam');
              },
            ),
            const SizedBox(height: 24),

            // 3. Quiz Rules Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.shieldAlert,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'বিসিএস লাইভ কুইজ নির্দেশিকা',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• প্রতিটি সঠিক উত্তরের জন্য ১ নম্বর যোগ হবে।\n'
                    '• ভুল উত্তরের জন্য ০.৫০ নম্বর কাটা যাবে (অফিসিয়াল বিসিএস সিলেবাস)।\n'
                    '• সময় শেষ হলে স্বয়ংক্রিয়ভাবে খাতা সাবমিট হয়ে যাবে।\n'
                    '• পরীক্ষা শেষে বিস্তারিত ব্যাখ্যা ও ভুল বিশ্লেষণ স্কোরকার্ডে প্রদর্শিত হবে।',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                ],
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

class _QuizFormatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;
  final List<Color> gradientColors;
  final bool isDark;
  final VoidCallback onTap;

  const _QuizFormatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
    required this.gradientColors,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: gradientColors.first.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: gradientColors.first,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gradientColors.first,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onTap,
                    child: Text(
                      'শুরু করুন',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
