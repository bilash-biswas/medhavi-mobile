import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/core/components/katex_math_text.dart';
import 'package:medhavi_mobile/core/localization/app_strings.dart';
import 'package:medhavi_mobile/core/utils/bengali_numeral_converter.dart';
import 'package:medhavi_mobile/features/practice/presentation/controllers/practice_session_controller.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/controllers/question_bank_controller.dart';

class PracticeSessionScreen extends ConsumerWidget {
  const PracticeSessionScreen({super.key});

  String _formatTimer(WidgetRef ref, int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final mRaw = m.toString().padLeft(2, '0');
    final sRaw = s.toString().padLeft(2, '0');
    final mStr = AppStrings.isBn(ref)
        ? BengaliNumeralConverter.toBengali(mRaw)
        : mRaw;
    final sStr = AppStrings.isBn(ref)
        ? BengaliNumeralConverter.toBengali(sRaw)
        : sRaw;
    return '$mStr:$sStr';
  }

  void _showExitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.t(ref, 'অনুশীলন বন্ধ করবেন?', 'End Practice Session?')),
        content: Text(
          AppStrings.t(
            ref,
            'এখন বের হলে আপনার বর্তমান সেশনের অগ্রগতি সংরক্ষিত হবে না। আপনি কি নিশ্চিত?',
            'If you exit now, your current session progress will not be saved. Are you sure?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.t(ref, 'চালিয়ে যান', 'Continue')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: Text(AppStrings.t(ref, 'বের হয়ে যান', 'Exit')),
          ),
        ],
      ),
    );
  }

  void _showQuestionPalette(BuildContext context, WidgetRef ref) {
    final state = ref.read(practiceSessionControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.t(ref, 'প্রশ্ন তালিকা ও ন্যাভিগেশন', 'Question Palette & Navigation'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: state.questions.length,
                    itemBuilder: (context, idx) {
                      final q = state.questions[idx];
                      final isCurrent = idx == state.currentIndex;
                      final isAnswered = state.selectedAnswers.containsKey(q.id);
                      final isCorrect = isAnswered &&
                          state.selectedAnswers[q.id] == q.correctOptionId;

                      Color bg;
                      Color textColor;

                      if (isCurrent) {
                        bg = AppColors.primary;
                        textColor = Colors.white;
                      } else if (state.mode == PracticeMode.instant && isAnswered) {
                        bg = isCorrect ? AppColors.emerald : AppColors.rose;
                        textColor = Colors.white;
                      } else if (isAnswered) {
                        bg = AppColors.primary.withValues(alpha: 0.15);
                        textColor = AppColors.primary;
                      } else {
                        bg = isDark ? AppColors.cardDark : Colors.grey.shade100;
                        textColor = isDark ? Colors.white70 : Colors.black87;
                      }

                      return InkWell(
                        onTap: () {
                          ref
                              .read(practiceSessionControllerProvider.notifier)
                              .jumpToQuestion(idx);
                          Navigator.of(ctx).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(12),
                            border: isCurrent
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: Text(
                            AppStrings.num(ref, idx + 1),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showScorecardModal(BuildContext context, WidgetRef ref) {
    final state = ref.read(practiceSessionControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Indicator Pill
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Trophy Emblem
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.trophy,
                      color: AppColors.primary, size: 36),
                ),
                const SizedBox(height: 12),

                Text(
                  AppStrings.t(ref, 'অনুশীলন সম্পন্ন হয়েছে!', 'Practice Completed!'),
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  state.mode == PracticeMode.exam
                      ? AppStrings.t(
                          ref,
                          'নেগেটিভ মার্কিং (-০.৫০) সহ চূড়ান্ত ফলাফল',
                          'Final score with negative marking (-0.50)',
                        )
                      : AppStrings.t(
                          ref,
                          'আপনার নিয়মিত অনুশীলনের সার্বিক অগ্রগতি',
                          'Your overall practice session performance',
                        ),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),

                // Score Hero Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            AppStrings.num(
                              ref,
                              state.mode == PracticeMode.exam
                                  ? state.totalScore.toStringAsFixed(1)
                                  : '${state.correctCount}/${state.totalQuestions}',
                            ),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            state.mode == PracticeMode.exam
                                ? AppStrings.t(ref, 'মোট স্কোর', 'Total Score')
                                : AppStrings.t(ref, 'সঠিক উত্তর', 'Correct Answers'),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                      Container(height: 40, width: 1, color: Colors.white24),
                      Column(
                        children: [
                          Text(
                            '${AppStrings.num(ref, state.accuracyPercentage)}%',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          Text(
                            AppStrings.t(ref, 'নির্ভুলতা (Accuracy)', 'Accuracy'),
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Breakdown Stats
                Row(
                  children: [
                    Expanded(
                      child: _ScoreMiniCard(
                        label: AppStrings.t(ref, 'সঠিক', 'Correct'),
                        value: AppStrings.num(ref, state.correctCount),
                        color: AppColors.emerald,
                        icon: LucideIcons.checkCircle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ScoreMiniCard(
                        label: AppStrings.t(ref, 'ভুল', 'Wrong'),
                        value: AppStrings.num(ref, state.incorrectCount),
                        color: AppColors.rose,
                        icon: LucideIcons.xCircle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ScoreMiniCard(
                        label: AppStrings.t(ref, 'উত্তরহীন', 'Skipped'),
                        value: AppStrings.num(ref, state.unattemptedCount),
                        color: Colors.grey,
                        icon: LucideIcons.helpCircle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref
                              .read(practiceSessionControllerProvider.notifier)
                              .restartPractice();
                        },
                        icon: const Icon(LucideIcons.rotateCcw, size: 16),
                        label: Text(AppStrings.t(ref, 'আবার দিন', 'Retry')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.pop();
                        },
                        icon: const Icon(LucideIcons.arrowRight, size: 16),
                        label: Text(AppStrings.t(ref, 'হাবে ফিরুন', 'Back to Hub')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceSessionControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qbState = ref.watch(questionBankControllerProvider);

    if (state.isLoading || (state.questions.isEmpty && state.errorMessage == null)) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          title: Text(
            state.title.isNotEmpty
                ? state.title
                : AppStrings.t(ref, 'অনুশীলন লোড হচ্ছে...', 'Loading Practice...'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                AppStrings.t(
                  ref,
                  'বিসিএস প্রশ্ন সংগ্রহ করা হচ্ছে...',
                  'Fetching BCS questions...',
                ),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    if (state.errorMessage != null && state.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          title: Text(
            state.title.isNotEmpty
                ? state.title
                : AppStrings.t(ref, 'অনুশীলন সেশন', 'Practice Session'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.alertTriangle,
                    size: 48, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(LucideIcons.arrowLeft, size: 16),
                  label: Text(AppStrings.t(ref, 'ফিরে যান', 'Go Back')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = state.currentQuestion;
    if (question == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          title: Text(AppStrings.t(ref, 'অনুশীলন সেশন', 'Practice Session')),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.t(ref, 'কোনো প্রশ্ন নেই', 'No questions available')),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(AppStrings.t(ref, 'ফিরে যান', 'Go Back')),
              ),
            ],
          ),
        ),
      );
    }

    final totalQ = state.totalQuestions;
    final currIdx = state.currentIndex;
    final isLast = currIdx == totalQ - 1;
    final selectedOption = state.selectedAnswers[question.id];
    final isRevealed = state.revealedMap[question.id] == true;
    final isBookmarked = qbState.bookmarkedIds.contains(question.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => _showExitDialog(context, ref),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              state.mode == PracticeMode.instant
                  ? AppStrings.t(ref, 'তাত্ক্ষণিক শিখন মোড', 'Instant Learning Mode')
                  : AppStrings.t(
                      ref,
                      'পরীক্ষা মোড • নেগেটিভ মার্কিং সহ',
                      'Exam Mode • Negative Marking',
                    ),
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          // Timer or Mode Pill
          if (state.mode == PracticeMode.exam)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: state.timeRemainingSeconds < 60
                    ? AppColors.rose.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.timer,
                    size: 14,
                    color: state.timeRemainingSeconds < 60
                        ? AppColors.rose
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimer(ref, state.timeRemainingSeconds),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: state.timeRemainingSeconds < 60
                          ? AppColors.rose
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

          // Bookmark Toggle
          IconButton(
            tooltip: isBookmarked
                ? AppStrings.t(ref, 'বুকমার্ক সরান', 'Remove Bookmark')
                : AppStrings.t(ref, 'বুকমার্ক করুন', 'Bookmark'),
            icon: Icon(
              isBookmarked ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
              color: isBookmarked ? AppColors.amber : null,
              size: 20,
            ),
            onPressed: () {
              ref
                  .read(questionBankControllerProvider.notifier)
                  .toggleBookmark(question.id);
            },
          ),

          // Question Palette Grid Icon
          IconButton(
            tooltip: AppStrings.t(ref, 'সব প্রশ্ন দেখুন', 'Question Palette'),
            icon: const Icon(LucideIcons.layoutGrid, size: 20),
            onPressed: () => _showQuestionPalette(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Linear Progress Indicator
          LinearProgressIndicator(
            value: totalQ > 0 ? (currIdx + 1) / totalQ : 0,
            backgroundColor: isDark ? AppColors.cardDark : Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Counter & Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${AppStrings.t(ref, 'প্রশ্ন', 'Question')}: ${AppStrings.num(ref, currIdx + 1)}/${AppStrings.num(ref, totalQ)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      if (question.tags.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppStrings.isBn(ref)
                                ? BengaliNumeralConverter.formatBcsSource(
                                    question.tags.first)
                                : question.tags.first,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Question Text Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: KaTexMathText(
                      text: question.question,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Options List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: question.options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, optIdx) {
                      final option = question.options[optIdx];
                      final isSelected = selectedOption == option.id;
                      final isCorrect = question.correctOptionId == option.id;

                      Color bg;
                      Color borderColor;
                      Color textColor;
                      Widget? statusIcon;

                      if (state.mode == PracticeMode.instant && isRevealed) {
                        if (isCorrect) {
                          bg = AppColors.emerald.withValues(alpha: 0.12);
                          borderColor = AppColors.emerald;
                          textColor = AppColors.emerald;
                          statusIcon = const Icon(LucideIcons.checkCircle,
                              color: AppColors.emerald, size: 18);
                        } else if (isSelected) {
                          bg = AppColors.rose.withValues(alpha: 0.12);
                          borderColor = AppColors.rose;
                          textColor = AppColors.rose;
                          statusIcon = const Icon(LucideIcons.xCircle,
                              color: AppColors.rose, size: 18);
                        } else {
                          bg = isDark ? AppColors.cardDark : AppColors.cardLight;
                          borderColor = isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight;
                          textColor = isDark ? Colors.white70 : Colors.black87;
                        }
                      } else {
                        if (isSelected) {
                          bg = AppColors.primary.withValues(alpha: 0.12);
                          borderColor = AppColors.primary;
                          textColor = AppColors.primary;
                          statusIcon = const Icon(LucideIcons.checkCircle2,
                              color: AppColors.primary, size: 18);
                        } else {
                          bg = isDark ? AppColors.cardDark : AppColors.cardLight;
                          borderColor = isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight;
                          textColor = isDark ? Colors.white70 : Colors.black87;
                        }
                      }

                      final optionPrefixes = AppStrings.isBn(ref)
                          ? ['ক', 'খ', 'গ', 'ঘ']
                          : ['A', 'B', 'C', 'D'];
                      final prefix = optIdx < optionPrefixes.length
                          ? optionPrefixes[optIdx]
                          : '${optIdx + 1}';

                      return InkWell(
                        onTap: () {
                          ref
                              .read(practiceSessionControllerProvider.notifier)
                              .selectOption(option.id);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: borderColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  prefix,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: borderColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: KaTexMathText(
                                  text: option.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (statusIcon != null) statusIcon,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Instant Mode Explanation
                  if (state.mode == PracticeMode.instant &&
                      isRevealed &&
                      question.explanation.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.emerald.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.sparkles,
                                  size: 16, color: AppColors.emerald),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.t(
                                  ref,
                                  'সঠিক উত্তর ও বিশদ ব্যাখ্যা',
                                  'Correct Answer & Detailed Explanation',
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          KaTexMathText(
                            text: question.explanation,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              height: 1.5,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: currIdx > 0
                      ? () => ref
                          .read(practiceSessionControllerProvider.notifier)
                          .previousQuestion()
                      : null,
                  icon: const Icon(LucideIcons.chevronLeft, size: 16),
                  label: Text(AppStrings.t(ref, 'পূর্ববর্তী', 'Previous')),
                ),
                const Spacer(),
                if (isLast || state.mode == PracticeMode.exam)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLast ? AppColors.primary : AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      ref
                          .read(practiceSessionControllerProvider.notifier)
                          .submitPractice();
                      _showScorecardModal(context, ref);
                    },
                    icon: const Icon(LucideIcons.checkCheck, size: 16),
                    label: Text(
                      isLast
                          ? AppStrings.t(ref, 'ফলাফল দেখুন', 'View Results')
                          : AppStrings.t(ref, 'সাবমিট করুন', 'Submit'),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => ref
                        .read(practiceSessionControllerProvider.notifier)
                        .nextQuestion(),
                    icon: const Icon(LucideIcons.chevronRight, size: 16),
                    label: Text(AppStrings.t(ref, 'পরবর্তী', 'Next')),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ScoreMiniCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
