import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/core/components/auto_hide_app_bar.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/controllers/question_bank_controller.dart';
import 'package:medhavi_mobile/features/bookmarks/presentation/controllers/bookmarks_controller.dart';
import 'package:medhavi_mobile/features/mistakes/presentation/controllers/mistakes_controller.dart';

class PracticeHubScreen extends ConsumerWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qbState = ref.watch(questionBankControllerProvider);
    final bmState = ref.watch(bookmarksControllerProvider);
    final mbState = ref.watch(mistakesControllerProvider);

    return Scaffold(
      appBar: AutoHideAppBar(
        child: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.playCircle,
                    color: AppColors.emerald, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'অনুশীলন হাব (Practice Hub)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'বিষয়ভিত্তিক কুইজ ও প্রস্তুতি',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Live Quiz Banner
            GestureDetector(
              onTap: () => context.push('/live-quiz'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.radio, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'লাইভ মেগা মডেল টেস্ট',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '• LIVE',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'টাইমার ও নেগেটিভ মার্কিং সহ রিয়েল বিসিএস প্রিলি সিমুলেশন',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 1. Practice Modes Cards
            _PracticeBannerCard(
              title: 'বিসিএস প্রশ্ন ব্যাংক অনুশীলন',
              subtitle: '১০ম থেকে ৫০তম বিসিএস প্রিলির ৫,৪২৩টি প্রশ্ন একনজরে অনুশীলন করুন',
              badge: 'সকল বিষয়',
              icon: LucideIcons.bookOpen,
              color: AppColors.primary,
              onTap: () => context.go('/question-bank'),
            ),
            const SizedBox(height: 12),

            _PracticeBannerCard(
              title: 'বুকমার্ক করা প্রশ্ন অনুশীলন',
              subtitle: '${bmState.questions.length}টি প্রশ্ন সংরক্ষিত রয়েছে',
              badge: 'ব্যক্তিগত রিভিশন',
              icon: LucideIcons.bookmark,
              color: AppColors.amber,
              onTap: () => context.go('/bookmarks'),
            ),
            const SizedBox(height: 12),

            _PracticeBannerCard(
              title: 'ভুল প্রশ্ন সংশোধন (Mistake Drill)',
              subtitle: '${mbState.questions.length}টি ভুল প্রশ্নের দুর্বলতা দূর করুন',
              badge: 'উচ্চ অগ্রাধিকার',
              icon: LucideIcons.alertTriangle,
              color: AppColors.rose,
              onTap: () => context.go('/mistakes'),
            ),
            const SizedBox(height: 24),

            // 2. Subject-wise Practice Launchers
            const Text(
              'বিষয়ভিত্তিক অনুশীলন নির্বাচন করুন',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: qbState.subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final sub = qbState.subjects[index];
                return Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.fileText,
                          color: AppColors.primary, size: 18),
                    ),
                    title: Text(
                      sub['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      sub['nameEn'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                      child: const Text('অনুশীলন', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        ref
                            .read(questionBankControllerProvider.notifier)
                            .setSubject(sub['id'] ?? '');
                        context.go('/question-bank');
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeBannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PracticeBannerCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
