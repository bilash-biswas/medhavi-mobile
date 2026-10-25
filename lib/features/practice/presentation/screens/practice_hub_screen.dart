import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/core/components/auto_hide_app_bar.dart';
import 'package:medhavi_mobile/core/localization/app_strings.dart';
import 'package:medhavi_mobile/features/practice/presentation/controllers/practice_session_controller.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/controllers/question_bank_controller.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/screens/question_bank_screen.dart'
    show kBcsBatches;
import 'package:medhavi_mobile/features/bookmarks/presentation/controllers/bookmarks_controller.dart';
import 'package:medhavi_mobile/features/mistakes/presentation/controllers/mistakes_controller.dart';
import 'package:medhavi_mobile/features/analytics/presentation/controllers/analytics_controller.dart';

const List<Map<String, dynamic>> _kDefaultBcsSubjects = [
  {
    'id': 'sub_bcs_bangla',
    'name': 'বাংলা ভাষা ও সাহিত্য',
    'nameEn': 'Bengali Language & Literature',
    'marks': '35',
    'icon': LucideIcons.bookOpen,
    'color': Color(0xFF4F46E5),
  },
  {
    'id': 'sub_bcs_english',
    'name': 'English Language & Literature',
    'nameEn': 'English Language & Literature',
    'marks': '35',
    'icon': LucideIcons.languages,
    'color': Color(0xFF0284C7),
  },
  {
    'id': 'sub_bcs_bd_affairs',
    'name': 'বাংলাদেশ বিষয়াবলি',
    'nameEn': 'Bangladesh Affairs',
    'marks': '30',
    'icon': LucideIcons.landmark,
    'color': Color(0xFF16A34A),
  },
  {
    'id': 'sub_bcs_intl_affairs',
    'name': 'আন্তর্জাতিক বিষয়াবলি',
    'nameEn': 'International Affairs',
    'marks': '20',
    'icon': LucideIcons.globe,
    'color': Color(0xFFD97706),
  },
  {
    'id': 'sub_bcs_math',
    'name': 'গাণিতিক যুক্তি (Mathematics)',
    'nameEn': 'Mathematical Reasoning',
    'marks': '15',
    'icon': LucideIcons.calculator,
    'color': Color(0xFF9333EA),
  },
  {
    'id': 'sub_bcs_mental_ability',
    'name': 'মানসিক দক্ষতা',
    'nameEn': 'Mental Ability',
    'marks': '15',
    'icon': LucideIcons.brain,
    'color': Color(0xFFEA580C),
  },
  {
    'id': 'sub_bcs_science',
    'name': 'সাধারণ বিজ্ঞান',
    'nameEn': 'General Science',
    'marks': '15',
    'icon': LucideIcons.flaskConical,
    'color': Color(0xFF0D9488),
  },
  {
    'id': 'sub_bcs_ict',
    'name': 'তথ্য ও যোগাযোগ প্রযুক্তি (ICT)',
    'nameEn': 'Computer & ICT',
    'marks': '15',
    'icon': LucideIcons.cpu,
    'color': Color(0xFF2563EB),
  },
  {
    'id': 'sub_bcs_geography',
    'name': 'ভূগোল, পরিবেশ ও দুর্যোগ ব্যবস্থাপনা',
    'nameEn': 'Geography & Environment',
    'marks': '10',
    'icon': LucideIcons.mapPin,
    'color': Color(0xFF059669),
  },
  {
    'id': 'sub_bcs_ethics',
    'name': 'নৈতিকতা, মূল্যবোধ ও সুশাসন',
    'nameEn': 'Ethics, Values & Governance',
    'marks': '10',
    'icon': LucideIcons.scale,
    'color': Color(0xFFDC2626),
  },
];

class _PracticeConfig {
  final PracticeMode mode;
  final int questionCount;
  final String batchTag;
  const _PracticeConfig({
    required this.mode,
    required this.questionCount,
    this.batchTag = '',
  });
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
            batchTag: config.batchTag.isNotEmpty ? config.batchTag : batchTag,
            mode: config.mode,
            questionCount: config.questionCount,
          );
      context.push('/practice/session');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = AppStrings.isBn(ref);
    final qbState = ref.watch(questionBankControllerProvider);
    final bmState = ref.watch(bookmarksControllerProvider);
    final mbState = ref.watch(mistakesControllerProvider);
    final analytics = ref.watch(analyticsControllerProvider);

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t(
                          ref, 'অনুশীলন হাব (Practice Hub)', 'Practice Hub'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppStrings.t(
                        ref,
                        'ইন্টারেক্টিভ কুইজ ও বিষয়ভিত্তিক প্র্যাকটিস',
                        'Interactive quizzes & subject-wise practice',
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.wait([
            ref.read(questionBankControllerProvider.notifier).init(),
            ref.read(bookmarksControllerProvider.notifier).loadBookmarks(),
            ref.read(mistakesControllerProvider.notifier).loadMistakes(),
            ref.read(analyticsControllerProvider.notifier).refreshStats(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  title: AppStrings.t(ref, 'দ্রুত ২০টি বিসিএস প্রিলি প্রশ্ন',
                      'Quick 20 BCS Preliminary MCQs'),
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
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  AppStrings.t(ref, 'র‍্যান্ডম বিসিএস প্র্যাকটিস',
                                      'Random BCS Practice'),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
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
                            AppStrings.t(
                              ref,
                              'সকল বিষয় ও ১০ম-৫০তম বিসিএস থেকে নির্বাচিত প্রশ্নে কুইজ শুরু করুন',
                              'Start a custom quiz across all subjects & 10th-50th BCS batches',
                            ),
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
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  AppStrings.t(ref, 'লাইভ মেগা মডেল টেস্ট',
                                      'Live Mega Model Test'),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
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
                            AppStrings.t(
                              ref,
                              'টাইমার ও নেগেটিভ মার্কিং সহ রিয়েল বিসিএস প্রিলি সিমুলেশন',
                              'Real BCS Preliminary simulation with timer & negative marking',
                            ),
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
                    title: AppStrings.t(
                        ref, 'ভুল প্রশ্ন ড্রিল', 'Mistakes Drill'),
                    countText: isBn
                        ? '${AppStrings.num(ref, mbState.questions.length)}টি ভুল প্রশ্ন'
                        : '${mbState.questions.length} Mistakes',
                    badge: AppStrings.t(
                        ref, 'উচ্চ অগ্রাধিকার', 'High Priority'),
                    icon: LucideIcons.alertTriangle,
                    color: AppColors.rose,
                    onTap: () {
                      if (mbState.questions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppStrings.t(
                                ref,
                                'ভুল ব্যাংকে কোনো প্রশ্ন নেই। টেস্টে ভুল হলে তা স্বয়ংক্রিয়ভাবে এখানে জমা হবে।',
                                'No questions in your Mistake Bank yet.',
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      ref
                          .read(practiceSessionControllerProvider.notifier)
                          .startPractice(
                            title: AppStrings.t(ref, 'ভুল প্রশ্ন সংশোধন ড্রিল',
                                'Mistake Recovery Drill'),
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
                    title: AppStrings.t(
                        ref, 'বুকমার্ক টেস্ট', 'Bookmarks Drill'),
                    countText: isBn
                        ? '${AppStrings.num(ref, bmState.questions.length)}টি সংরক্ষিত'
                        : '${bmState.questions.length} Saved',
                    badge: AppStrings.t(
                        ref, 'ব্যক্তিগত রিভিশন', 'Saved Revision'),
                    icon: LucideIcons.bookmark,
                    color: AppColors.amber,
                    onTap: () {
                      if (bmState.questions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppStrings.t(
                                ref,
                                'আপনার কোনো বুকমার্ক করা প্রশ্ন নেই। প্রশ্ন ব্যাংক থেকে বুকমার্ক করুন।',
                                'No bookmarked questions yet. Bookmark questions from the Question Bank.',
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      ref
                          .read(practiceSessionControllerProvider.notifier)
                          .startPractice(
                            title: AppStrings.t(
                                ref,
                                'বুকমার্ক করা প্রশ্ন অনুশীলন',
                                'Bookmarked Questions Drill'),
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
                Text(
                  AppStrings.t(
                      ref, 'বিষয়ভিত্তিক অনুশীলন', 'Subject-wise Practice'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/question-bank'),
                  icon: const Icon(LucideIcons.bookOpen, size: 14),
                  label: Text(
                    AppStrings.t(ref, 'প্রশ্ন ব্যাংক ব্রাউজ', 'Browse Bank'),
                    style: const TextStyle(fontSize: 12),
                  ),
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
                final defaultMeta = _kDefaultBcsSubjects.firstWhere(
                  (d) => d['id'] == sub['id'],
                  orElse: () => _kDefaultBcsSubjects[index % _kDefaultBcsSubjects.length],
                );
                final name = sub['name'] as String? ?? '';
                final nameEn = (sub['nameEn'] as String?)?.isNotEmpty == true
                    ? sub['nameEn'] as String
                    : (defaultMeta['nameEn'] as String? ?? '');
                final subId = sub['id'] as String? ?? '';
                final marks =
                    sub['marks']?.toString() ?? defaultMeta['marks'].toString();
                final icon = (sub['icon'] as IconData?) ??
                    (defaultMeta['icon'] as IconData?) ??
                    LucideIcons.fileText;
                final color = (sub['color'] as Color?) ??
                    (defaultMeta['color'] as Color?) ??
                    AppColors.primary;
                final count = qbState.subjectCounts[subId] ?? 0;
                final displayTitle = isBn ? name : nameEn;
                final subjectPerf = analytics.subjects
                    .where((s) => s.subjectId == subId)
                    .firstOrNull;
                final solvedCount = subjectPerf?.solved ?? 0;
                final progress =
                    count > 0 ? (solvedCount / count).clamp(0.0, 1.0) : 0.0;

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      _openPracticeConfigModal(
                        context: context,
                        ref: ref,
                        title: isBn
                            ? '$name অনুশীলন'
                            : '$nameEn Practice',
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
                                  displayTitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 3,
                                    backgroundColor: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      progress >= 0.7
                                          ? AppColors.emerald
                                          : (progress > 0
                                              ? color
                                              : Colors.grey.shade400),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  isBn
                                      ? '${solvedCount > 0 ? '${AppStrings.num(ref, solvedCount)}টি অনুশীলিত • ' : ''}বিসিএস প্রিলি মান: ${AppStrings.num(ref, marks)}'
                                      : '${solvedCount > 0 ? '$solvedCount Solved • ' : ''}BCS Marks: $marks',
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
                            label: Text(
                              AppStrings.t(ref, 'শুরু করুন', 'Start'),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              _openPracticeConfigModal(
                                context: context,
                                ref: ref,
                                title: isBn
                                    ? '$name অনুশীলন'
                                    : '$nameEn Practice',
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
  late String _selectedBatchTag;

  @override
  void initState() {
    super.initState();
    _selectedBatchTag = widget.batchTag ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = AppStrings.isBn(ref);

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
                      Text(
                        AppStrings.t(
                          ref,
                          'অনুশীলনের ব্যাচ, মোড ও প্রশ্নের সংখ্যা নির্ধারণ করুন',
                          'Select BCS batch, mode, and question count',
                        ),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
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
            const SizedBox(height: 16),

            // BCS Batch Selector (10th to 50th BCS)
            Text(
              AppStrings.t(
                  ref, 'বিসিএস ব্যাচ (১০ম - ৫০তম)', 'BCS Batch (10th - 50th)'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedBatchTag,
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: kBcsBatches.map((b) {
                final id = b['id'] ?? '';
                final label = isBn
                    ? (b['labelBn'] ?? b['label']!)
                    : (b['labelEn'] ?? b['label']!);
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedBatchTag = val ?? '');
              },
            ),
            const SizedBox(height: 16),

            // Question Count
            Text(
              AppStrings.t(ref, 'প্রশ্নের সংখ্যা', 'Question Count'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [10, 20, 30, 50].map((count) {
                final isSelected = _questionCount == count;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      isBn
                          ? '${AppStrings.num(ref, count)}টি প্রশ্ন'
                          : '$count Qs',
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
            const SizedBox(height: 16),

            // Mode Selector
            Text(
              AppStrings.t(ref, 'অনুশীলন মোড', 'Practice Mode'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
                            : (isDark
                                ? AppColors.cardDark
                                : Colors.grey.shade100),
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
                          Text(
                            AppStrings.t(ref, 'শিখন মোড', 'Study Mode'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AppStrings.t(
                              ref,
                              'প্রতিটি উত্তরের পর সাথে সাথে বিশদ ব্যাখ্যা',
                              'Instant answer & explanation after each pick',
                            ),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
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
                            : (isDark
                                ? AppColors.cardDark
                                : Colors.grey.shade100),
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
                          Text(
                            AppStrings.t(ref, 'মডেল টেস্ট', 'Exam Mode'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AppStrings.t(
                              ref,
                              'টাইমার ও নেগেটিভ মার্কিং সহ প্রিলি সিমুলেশন',
                              'Timed exam with -0.50 negative marking',
                            ),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

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
                    batchTag: _selectedBatchTag,
                  ));
                },
                icon: const Icon(LucideIcons.play, size: 18),
                label: Text(
                  AppStrings.t(ref, 'অনুশীলন শুরু করুন', 'Start Practice'),
                  style: const TextStyle(
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
