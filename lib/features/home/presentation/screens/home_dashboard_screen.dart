import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/controllers/question_bank_controller.dart';
import 'package:medhavi_mobile/features/bookmarks/presentation/controllers/bookmarks_controller.dart';
import 'package:medhavi_mobile/features/mistakes/presentation/controllers/mistakes_controller.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qbState = ref.watch(questionBankControllerProvider);
    final bmState = ref.watch(bookmarksControllerProvider);
    final mbState = ref.watch(mistakesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.graduationCap,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'মেধাবী (Medhavi)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'স্মার্ট বিসিএস ও ক্যারিয়ার প্রস্তুতি',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.sparkles,
                                size: 13, color: Colors.amber),
                            SizedBox(width: 5),
                            Text(
                              '১০ম - ৫০তম বিসিএস সংগ্রহ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '৫,৪২৩+ বিসিএস প্রশ্ন ও বিস্তারিত ব্যাখ্যা',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'প্রতিটি প্রশ্নের নির্ভুল ব্যাখ্যা, গণিত ও বিজ্ঞানের KaTeX সূত্র এবং সেলফ-টেস্টিং সুবিধা।',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                    icon: const Icon(LucideIcons.bookOpen, size: 18),
                    label: const Text(
                      'প্রশ্ন ব্যাংকে পড়ুন',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => context.go('/question-bank'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'প্রশ্ন ব্যাংক',
                    value: '৫,৪২৩টি',
                    subtitle: '১০ম - ৫০তম বিসিএস',
                    icon: LucideIcons.layers,
                    color: AppColors.primary,
                    onTap: () => context.go('/question-bank'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'বুকমার্কসমূহ',
                    value: '${bmState.questions.length}টি',
                    subtitle: 'সংরক্ষিত প্রশ্ন',
                    icon: LucideIcons.bookmark,
                    color: AppColors.amber,
                    onTap: () => context.go('/bookmarks'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'ভুল ব্যাংক',
                    value: '${mbState.questions.length}টি',
                    subtitle: 'পুনরাবৃত্তি সংশোধন',
                    icon: LucideIcons.alertTriangle,
                    color: AppColors.rose,
                    onTap: () => context.go('/mistakes'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'অনুশীলন হাব',
                    value: '১০টি বিষয়',
                    subtitle: 'কাস্টম পরীক্ষা',
                    icon: LucideIcons.playCircle,
                    color: AppColors.emerald,
                    onTap: () => context.go('/practice'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Quick BCS Batch Selector
            const Text(
              'জনপ্রিয় বিসিএস প্রশ্নব্যাচ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _BatchChip(
                  label: '৫০তম বিসিএস',
                  tag: '50th-bcs',
                  onTap: () {
                    ref
                        .read(questionBankControllerProvider.notifier)
                        .setBatch('50th-bcs');
                    context.go('/question-bank');
                  },
                ),
                _BatchChip(
                  label: '৪৯তম বিসিএস',
                  tag: '49th-bcs',
                  onTap: () {
                    ref
                        .read(questionBankControllerProvider.notifier)
                        .setBatch('49th-bcs');
                    context.go('/question-bank');
                  },
                ),
                _BatchChip(
                  label: '৪৮তম বিসিএস',
                  tag: '48th-bcs',
                  onTap: () {
                    ref
                        .read(questionBankControllerProvider.notifier)
                        .setBatch('48th-bcs');
                    context.go('/question-bank');
                  },
                ),
                _BatchChip(
                  label: '৪৭তম বিসিএস',
                  tag: '47th-bcs',
                  onTap: () {
                    ref
                        .read(questionBankControllerProvider.notifier)
                        .setBatch('47th-bcs');
                    context.go('/question-bank');
                  },
                ),
                _BatchChip(
                  label: '৪৬তম বিসিএস',
                  tag: '46th-bcs',
                  onTap: () {
                    ref
                        .read(questionBankControllerProvider.notifier)
                        .setBatch('46th-bcs');
                    context.go('/question-bank');
                  },
                ),
                _BatchChip(
                  label: '৪৫তম বিসিএস',
                  tag: '45th-bcs',
                  onTap: () {
                    ref
                        .read(questionBankControllerProvider.notifier)
                        .setBatch('45th-bcs');
                    context.go('/question-bank');
                  },
                ),
                _BatchChip(
                  label: '৪৪তম বিসিএস',
                  tag: '44th-bcs',
                  onTap: () {
                    ref
                        .read(questionBankControllerProvider.notifier)
                        .setBatch('44th-bcs');
                    context.go('/question-bank');
                  },
                ),
                _BatchChip(
                  label: '৪৩তম বিসিএস',
                  tag: '43rd-bcs',
                  onTap: () {
                    ref
                        .read(questionBankControllerProvider.notifier)
                        .setBatch('43rd-bcs');
                    context.go('/question-bank');
                  },
                ),
                _BatchChip(
                  label: '৪১তম বিসিএস',
                  tag: '41st-bcs',
                  onTap: () {
                    ref
                        .read(questionBankControllerProvider.notifier)
                        .setBatch('41st-bcs');
                    context.go('/question-bank');
                  },
                ),
                _BatchChip(
                  label: '৪০তম বিসিএস',
                  tag: '40th-bcs',
                  onTap: () {
                    ref
                        .read(questionBankControllerProvider.notifier)
                        .setBatch('40th-bcs');
                    context.go('/question-bank');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. BCS Subjects Explorer
            const Text(
              'বিসিএস প্রিলিমিনারি বিষয়সমূহ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (qbState.subjects.isNotEmpty) ...[
              Column(
                children: qbState.subjects.map((sub) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.book,
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
                      trailing: const Icon(LucideIcons.chevronRight, size: 16),
                      onTap: () {
                        ref
                            .read(questionBankControllerProvider.notifier)
                            .setSubject(sub['id'] ?? '');
                        context.go('/question-bank');
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Icon(LucideIcons.chevronRight,
                      size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchChip extends StatelessWidget {
  final String label;
  final String tag;
  final VoidCallback onTap;

  const _BatchChip({
    required this.label,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(LucideIcons.sparkles, size: 14, color: AppColors.primary),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
