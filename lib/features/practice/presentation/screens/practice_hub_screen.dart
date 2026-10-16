import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/core/components/auto_hide_app_bar.dart';
import 'package:medhavi_mobile/core/utils/bengali_numeral_converter.dart';
import 'package:medhavi_mobile/features/practice/presentation/controllers/practice_session_controller.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/controllers/question_bank_controller.dart';
import 'package:medhavi_mobile/features/bookmarks/presentation/controllers/bookmarks_controller.dart';
import 'package:medhavi_mobile/features/mistakes/presentation/controllers/mistakes_controller.dart';

const List<Map<String, dynamic>> _kDefaultBcsSubjects = [
  {
    'id': 'sub_bcs_bangla',
    'name': 'বাংলা ভাষা ও সাহিত্য',
    'nameEn': 'Bengali Language & Literature',
    'marks': '৩৫',
    'icon': LucideIcons.bookOpen,
    'color': Color(0xFF4F46E5),
  },
  {
    'id': 'sub_bcs_english',
    'name': 'English Language & Literature',
    'nameEn': 'English Language & Literature',
    'marks': '৩৫',
    'icon': LucideIcons.languages,
    'color': Color(0xFF0284C7),
  },
  {
    'id': 'sub_bcs_bd_affairs',
    'name': 'বাংলাদেশ বিষয়াবলি',
    'nameEn': 'Bangladesh Affairs',
    'marks': '৩০',
    'icon': LucideIcons.landmark,
    'color': Color(0xFF16A34A),
  },
  {
    'id': 'sub_bcs_intl_affairs',
    'name': 'আন্তর্জাতিক বিষয়াবলি',
    'nameEn': 'International Affairs',
    'marks': '২০',
    'icon': LucideIcons.globe,
    'color': Color(0xFFD97706),
  },
  {
    'id': 'sub_bcs_math',
    'name': 'গাণিতিক যুক্তি (Mathematics)',
    'nameEn': 'Mathematical Reasoning',
    'marks': '১৫',
    'icon': LucideIcons.calculator,
    'color': Color(0xFF9333EA),
  },
  {
    'id': 'sub_bcs_mental_ability',
    'name': 'মানসিক দক্ষতা',
    'nameEn': 'Mental Ability',
    'marks': '১৫',
    'icon': LucideIcons.brain,
    'color': Color(0xFFEA580C),
  },
  {
    'id': 'sub_bcs_science',
    'name': 'সাধারণ বিজ্ঞান',
    'nameEn': 'General Science',
    'marks': '১৫',
    'icon': LucideIcons.flaskConical,
    'color': Color(0xFF0D9488),
  },
  {
    'id': 'sub_bcs_ict',
    'name': 'তথ্য ও যোগাযোগ প্রযুক্তি (ICT)',
    'nameEn': 'Computer & ICT',
    'marks': '১৫',
    'icon': LucideIcons.cpu,
    'color': Color(0xFF2563EB),
  },
  {
    'id': 'sub_bcs_geography',
    'name': 'ভূগোল, পরিবেশ ও দুর্যোগ ব্যবস্থাপনা',
    'nameEn': 'Geography & Environment',
    'marks': '১০',
    'icon': LucideIcons.mapPin,
    'color': Color(0xFF059669),
  },
  {
    'id': 'sub_bcs_ethics',
    'name': 'নৈতিকতা, মূল্যবোধ ও সুশাসন',
    'nameEn': 'Ethics, Values & Governance',
    'marks': '১০',
    'icon': LucideIcons.scale,
    'color': Color(0xFFDC2626),
  },
];

class _PracticeConfig {
  final PracticeMode mode;
  final int questionCount;
  const _PracticeConfig({required this.mode, required this.questionCount});
}

class PracticeHubScreen extends ConsumerWidget {
  const PracticeHubScreen({super.key});

  Future<void> _openPracticeConfigModal({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    String? subjectId,
    String? batchTag,
  }) async {
    final config = await showModalBottomSheet<_PracticeConfig>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _PracticeSetupBottomSheet(
          title: title,
          subjectId: subjectId,
          batchTag: batchTag,
        );
      },
    );

    if (config != null && context.mounted) {
      ref.read(practiceSessionControllerProvider.notifier).startPractice(
            title: title,
            subjectId: subjectId,
            batchTag: batchTag,
            mode: config.mode,
            questionCount: config.questionCount,
          );
      context.push('/practice/session');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qbState = ref.watch(questionBankControllerProvider);
    final bmState = ref.watch(bookmarksControllerProvider);
    final mbState = ref.watch(mistakesControllerProvider);

    final subjects =
        qbState.subjects.isNotEmpty ? qbState.subjects : _kDefaultBcsSubjects;

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
                    'ইন্টারেক্টিভ কুইজ ও বিষয়ভিত্তিক প্র্যাকটিস',
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
            // 1. Featured Quick 20 Mixed Questions Launcher
            GestureDetector(
              onTap: () {
                _openPracticeConfigModal(
                  context: context,
                  ref: ref,
                  title: 'দ্রুত ২০টি বিসিএস প্রিলি প্রশ্ন',
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.zap,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'র‍্যান্ডম বিসিএস প্র্যাকটিস',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '• QUICK',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'সকল বিষয় থেকে নির্বাচিত প্রশ্নে তাত্ক্ষণিক কুইজ শুরু করুন',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Live Quiz Banner
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
                      child: const Icon(LucideIcons.radio,
                          color: Colors.white, size: 22),
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
                    const Icon(LucideIcons.chevronRight,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Quick Revision Cards (Mistakes & Bookmarks)
            Row(
              children: [
                Expanded(
                  child: _QuickModeCard(
                    title: 'ভুল প্রশ্ন ড্রিল',
                    countText:
                        '${BengaliNumeralConverter.toBengali('${mbState.questions.length}')}টি ভুল প্রশ্ন',
                    badge: 'উচ্চ অগ্রাধিকার',
                    icon: LucideIcons.alertTriangle,
                    color: AppColors.rose,
                    onTap: () {
                      if (mbState.questions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'ভুল ব্যাংকে কোনো প্রশ্ন নেই। টেস্টে ভুল হলে তা স্বয়ংক্রিয়ভাবে এখানে জমা হবে।'),
                          ),
                        );
                        return;
                      }
                      ref
                          .read(practiceSessionControllerProvider.notifier)
                          .startPractice(
                            title: 'ভুল প্রশ্ন সংশোধন ড্রিল',
                            preloadedQuestions: mbState.questions,
                            mode: PracticeMode.instant,
                          );
                      context.push('/practice/session');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickModeCard(
                    title: 'বুকমার্ক টেস্ট',
                    countText:
                        '${BengaliNumeralConverter.toBengali('${bmState.questions.length}')}টি সংরক্ষিত',
                    badge: 'ব্যক্তিগত রিভিশন',
                    icon: LucideIcons.bookmark,
                    color: AppColors.amber,
                    onTap: () {
                      if (bmState.questions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'আপনার কোনো বুকমার্ক করা প্রশ্ন নেই। প্রশ্ন ব্যাংক থেকে বুকমার্ক করুন।'),
                          ),
                        );
                        return;
                      }
                      ref
                          .read(practiceSessionControllerProvider.notifier)
                          .startPractice(
                            title: 'বুকমার্ক করা প্রশ্ন অনুশীলন',
                            preloadedQuestions: bmState.questions,
                            mode: PracticeMode.instant,
                          );
                      context.push('/practice/session');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Subject-wise Practice Launchers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'বিষয়ভিত্তিক অনুশীলন',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/question-bank'),
                  icon: const Icon(LucideIcons.bookOpen, size: 14),
                  label: const Text('প্রশ্ন ব্যাংক ব্রাউজ',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final sub = subjects[index];
                final name = sub['name'] as String? ?? '';
                final nameEn = sub['nameEn'] as String? ?? '';
                final subId = sub['id'] as String? ?? '';
                final marks = sub['marks']?.toString() ?? '১৫';
                final icon = (sub['icon'] as IconData?) ?? LucideIcons.fileText;
                final color = (sub['color'] as Color?) ?? AppColors.primary;

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      _openPracticeConfigModal(
                        context: context,
                        ref: ref,
                        title: '$name অনুশীলন',
                        subjectId: subId,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$nameEn • বিসিএস প্রিলি মান: $marks',
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
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(LucideIcons.play, size: 12),
                            label: const Text('শুরু করুন',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              _openPracticeConfigModal(
                                context: context,
                                ref: ref,
                                title: '$name অনুশীলন',
                                subjectId: subId,
                              );
                            },
                          ),
                        ],
                      ),
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

class _QuickModeCard extends StatelessWidget {
  final String title;
  final String countText;
  final String badge;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickModeCard({
    required this.title,
    required this.countText,
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                countText,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeSetupBottomSheet extends ConsumerStatefulWidget {
  final String title;
  final String? subjectId;
  final String? batchTag;

  const _PracticeSetupBottomSheet({
    required this.title,
    this.subjectId,
    this.batchTag,
  });

  @override
  ConsumerState<_PracticeSetupBottomSheet> createState() =>
      __PracticeSetupBottomSheetState();
}

class __PracticeSetupBottomSheetState
    extends ConsumerState<_PracticeSetupBottomSheet> {
  int _questionCount = 20;
  PracticeMode _mode = PracticeMode.instant;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'অনুশীলনের মোড ও প্রশ্নের সংখ্যা নির্ধারণ করুন',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question Count
            const Text(
              'প্রশ্নের সংখ্যা',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [10, 20, 30].map((count) {
                final isSelected = _questionCount == count;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '${BengaliNumeralConverter.toBengali('$count')}টি প্রশ্ন',
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _questionCount = count);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Mode Selector
            const Text(
              'অনুশীলন মোড',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() => _mode = PracticeMode.instant);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _mode == PracticeMode.instant
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : (isDark ? AppColors.cardDark : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _mode == PracticeMode.instant
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.lightbulb,
                            size: 20,
                            color: _mode == PracticeMode.instant
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'শিখন মোড',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'প্রতিটি উত্তরের পর সাথে সাথে বিশদ ব্যাখ্যা',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() => _mode = PracticeMode.exam);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _mode == PracticeMode.exam
                            ? AppColors.rose.withValues(alpha: 0.12)
                            : (isDark ? AppColors.cardDark : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _mode == PracticeMode.exam
                              ? AppColors.rose
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.timer,
                            size: 20,
                            color: _mode == PracticeMode.exam
                                ? AppColors.rose
                                : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'মডেল টেস্ট',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'টাইমার ও নেগেটিভ মার্কিং সহ প্রিলি সিমুলেশন',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(_PracticeConfig(
                    mode: _mode,
                    questionCount: _questionCount,
                  ));
                },
                icon: const Icon(LucideIcons.play, size: 18),
                label: const Text(
                  'অনুশীলন শুরু করুন',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
