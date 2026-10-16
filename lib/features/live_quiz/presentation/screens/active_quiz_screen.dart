import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/katex_math_text.dart';
import '../../../../core/utils/bengali_numeral_converter.dart';
import '../controllers/live_quiz_controller.dart';

class ActiveQuizScreen extends ConsumerWidget {
  const ActiveQuizScreen({super.key});

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final mStr = m.toString().padLeft(2, '0');
    final sStr = s.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  void _showScorecard(BuildContext context, WidgetRef ref) {
    final state = ref.read(liveQuizControllerProvider);
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
        final totalQuestions = state.questions.length;
        final accuracy = totalQuestions > 0
            ? ((state.correctCount / totalQuestions) * 100).toInt()
            : 0;

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
                  'পরীক্ষা সম্পন্ন হয়েছে!',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  'আপনার ফলাফল ও নেগেটিভ মার্কিং হিসাব প্রস্তুত',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),

                // Score Hero Banner
                Container(
                  padding: const EdgeInsets.all(16),
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
                            BengaliNumeralConverter.toBengaliNumber(
                                state.totalScore.toStringAsFixed(1)),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'মোট নম্বর',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white24,
                      ),
                      Column(
                        children: [
                          Text(
                            '${BengaliNumeralConverter.toBengaliNumber(accuracy)}%',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          Text(
                            'নির্ভুলতা',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Breakdown Pills
                Row(
                  children: [
                    Expanded(
                      child: _ScoreMiniCard(
                        label: 'সঠিক',
                        value: BengaliNumeralConverter.toBengaliNumber(state.correctCount),
                        color: AppColors.success,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ScoreMiniCard(
                        label: 'ভুল (-০.৫০)',
                        value: BengaliNumeralConverter.toBengaliNumber(state.incorrectCount),
                        color: AppColors.rose,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ScoreMiniCard(
                        label: 'অনুত্তরিত',
                        value: BengaliNumeralConverter.toBengaliNumber(state.unattemptedCount),
                        color: Colors.grey,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/');
                    },
                    child: Text(
                      'হোম ড্যাশবোর্ডে ফিরে যান',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveQuizControllerProvider);
    final notifier = ref.read(liveQuizControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentQuestion = state.currentQuestion;
    final hasNext = state.currentIndex < state.questions.length - 1;
    final hasPrev = state.currentIndex > 0;
    final isLowTime = state.timeRemainingSeconds <= 60;

    // Auto show scorecard if completed
    ref.listen(liveQuizControllerProvider, (prev, next) {
      if (next.isCompleted && prev?.isCompleted != true) {
        _showScorecard(context, ref);
      }
    });

    if (currentQuestion == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'কোনো প্রশ্ন পাওয়া যায়নি।',
            style: GoogleFonts.hindSiliguri(),
          ),
        ),
      );
    }

    final selectedOption = state.selectedAnswers[currentQuestion.id];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'প্রশ্ন ${BengaliNumeralConverter.toBengaliNumber(state.currentIndex + 1)} / ${BengaliNumeralConverter.toBengaliNumber(state.questions.length)}',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Countdown Timer Pill
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isLowTime
                  ? Colors.red.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLowTime ? Colors.red : AppColors.primary,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.clock,
                  size: 14,
                  color: isLowTime ? Colors.red : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  BengaliNumeralConverter.toBengaliNumber(
                      _formatTime(state.timeRemainingSeconds)),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isLowTime ? Colors.red : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timer Progress Bar
            LinearProgressIndicator(
              value: state.totalTimeSeconds > 0
                  ? state.timeRemainingSeconds / state.totalTimeSeconds
                  : 0.0,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                isLowTime ? Colors.red : AppColors.primary,
              ),
              minHeight: 3,
            ),

            // Question Card Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BCS Batch Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        BengaliNumeralConverter.toBengaliBcsTitle(
                            currentQuestion.source ?? ''),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Question Text (KaTeX)
                    KaTexMathText(
                      text: currentQuestion.text,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Options List
                    ...currentQuestion.options.map((option) {
                      final isSelected = selectedOption == option.id;
                      final optionBadge = _getBanglaLetter(option.id);

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifier.selectOption(currentQuestion.id, option.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : (isDark ? AppColors.cardDark : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? Colors.white10
                                          : AppColors.borderLight),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    optionBadge,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white70
                                              : Colors.black87),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: KaTexMathText(
                                  text: option.text,
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Navigation & Submit Bar
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prev
                  OutlinedButton.icon(
                    onPressed: hasPrev ? notifier.prevQuestion : null,
                    icon: const Icon(LucideIcons.chevronLeft, size: 16),
                    label: Text('পূর্ববর্তী', style: GoogleFonts.hindSiliguri()),
                  ),

                  // Submit
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            'পরীক্ষা সাবমিট করতে চান?',
                            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            'আপনি ${BengaliNumeralConverter.toBengaliNumber(state.selectedAnswers.length)}টি প্রশ্নের উত্তর দিয়েছেন। সাবমিট করলে আর পরিবর্তন করা যাবে না।',
                            style: GoogleFonts.hindSiliguri(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('বাতিল'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white),
                              onPressed: () {
                                Navigator.pop(ctx);
                                notifier.submitQuiz();
                              },
                              child: const Text('সাবমিট করুন'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('সাবমিট', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  ),

                  // Next
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: hasNext ? notifier.nextQuestion : null,
                    label: Text('পরবর্তী', style: GoogleFonts.hindSiliguri()),
                    icon: const Icon(LucideIcons.chevronRight, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBanglaLetter(String id) {
    switch (id.toLowerCase()) {
      case 'a':
      case 'opt_1':
        return 'ক';
      case 'b':
      case 'opt_2':
        return 'খ';
      case 'c':
      case 'opt_3':
        return 'গ';
      case 'd':
      case 'opt_4':
        return 'ঘ';
      default:
        return id;
    }
  }
}

class _ScoreMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _ScoreMiniCard({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.hindSiliguri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.hindSiliguri(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
