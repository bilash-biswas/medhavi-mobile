import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/bengali_numeral_converter.dart';
import '../../../../core/components/katex_math_text.dart';
import '../controllers/daily_challenge_controller.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  Timer? _countdownTimer;
  String _countdownText = '';
  bool _copied = false;

  final List<String> _bnOptionLetters = ['ক', 'খ', 'গ', 'ঘ', 'ঙ'];
  final List<String> _enOptionLetters = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateCountdown();
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final diff = midnight.difference(now);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    setState(() {
      _countdownText = '$h:$m:$s';
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _generateWordleCard(DailyChallengeState state, bool isBn) {
    final buffer = StringBuffer();
    buffer.writeln('মেধাবী দৈনিক চ্যালেঞ্জ • ${state.dateStr}');
    final accuracy = (state.score /
            (state.questions.isEmpty ? 1 : state.questions.length) *
            100)
        .round();
    buffer.writeln(
        'স্কোর: ${state.score}/${state.questions.length} ($accuracy%) | সময়: ${_formatDuration(state.durationSeconds)}');

    final emojiRow = state.questions.map((q) {
      final sel = state.selectedAnswers[q.id];
      return sel == q.correctOptionId ? '🟩' : '🟥';
    }).join('');
    buffer.writeln(emojiRow);
    if (state.currentStreak > 0) {
      buffer.writeln('স্ট্রিক: ${state.currentStreak} দিন 🔥');
    }
    buffer.writeln('চ্যালেঞ্জ নিন: https://medhavi-nine.vercel.app/daily');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyChallengeControllerProvider);
    final notifier = ref.read(dailyChallengeControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = AppStrings.isBn(ref);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.flame, color: Colors.orange, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.t(ref, 'দৈনিক চ্যালেঞ্জ', 'Daily Challenge'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (!state.isCompleted && !state.isLoading) ...[
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.clock, size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(
                    _formatDuration(state.durationSeconds),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.alertTriangle,
                            color: AppColors.error, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: notifier.init,
                          child: Text(AppStrings.t(ref, 'পুনরায় চেষ্টা', 'Retry')),
                        ),
                      ],
                    ),
                  ),
                )
              : state.isCompleted
                  ? _buildCompletedView(context, state, isDark, isBn)
                  : _buildActiveQuizView(context, state, notifier, isDark, isBn),
    );
  }

  // Active Quiz View (5-Step Runner)
  Widget _buildActiveQuizView(
    BuildContext context,
    DailyChallengeState state,
    DailyChallengeController notifier,
    bool isDark,
    bool isBn,
  ) {
    final question = state.currentQuestion;
    if (question == null) {
      return const SizedBox.shrink();
    }

    final total = state.questions.length;
    final current = state.currentIndex + 1;
    final progress = current / (total == 0 ? 1 : total);
    final selectedOptionId = state.selectedAnswers[question.id];
    final isAnswered = selectedOptionId != null;
    final optionLetters = isBn ? _bnOptionLetters : _enOptionLetters;

    return Column(
      children: [
        // 1. Progress Bar & Step Indicator
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card with Subject Badge & Step count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isBn
                          ? 'প্রশ্ন ${BengaliNumeralConverter.toBengaliNumber(current)} / ${BengaliNumeralConverter.toBengaliNumber(total)}'
                          : 'Question $current of $total',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (question.source != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isBn
                            ? BengaliNumeralConverter.toBengaliBcsTitle(
                                question.source!)
                            : question.source!,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Question Text Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: KaTexMathText(
                  text: question.question,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Options
              ...question.options.asMap().entries.map((entry) {
                final idx = entry.key;
                final opt = entry.value;
                final letter =
                    idx < optionLetters.length ? optionLetters[idx] : '${idx + 1}';

                final isSelected = selectedOptionId == opt.id;
                final isCorrect = question.correctOptionId == opt.id;

                Color borderColor =
                    isDark ? AppColors.borderDark : AppColors.borderLight;
                Color bgColor = isDark ? AppColors.cardDark : Colors.white;
                Color textColor = isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight;

                if (isAnswered) {
                  if (isCorrect) {
                    borderColor = AppColors.success;
                    bgColor = AppColors.success.withValues(alpha: 0.12);
                    textColor = AppColors.success;
                  } else if (isSelected) {
                    borderColor = AppColors.error;
                    bgColor = AppColors.error.withValues(alpha: 0.12);
                    textColor = AppColors.error;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: isAnswered
                        ? null
                        : () => notifier.selectAnswer(question.id, opt.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: isSelected || (isAnswered && isCorrect) ? 1.5 : 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isAnswered && isCorrect
                                  ? AppColors.success
                                  : isAnswered && isSelected
                                      ? AppColors.error
                                      : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: (isAnswered && (isCorrect || isSelected))
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: KaTexMathText(
                              text: opt.text,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                color: textColor,
                                fontWeight: isSelected || (isAnswered && isCorrect)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isAnswered) ...[
                            if (isCorrect)
                              const Icon(LucideIcons.checkCircle2,
                                  color: AppColors.success, size: 18)
                            else if (isSelected)
                              const Icon(LucideIcons.xCircle,
                                  color: AppColors.error, size: 18),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Explanation Box when answered
              if (isAnswered && question.explanation.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.lightbulb,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.t(ref, 'ব্যাখ্যা ও সমাধান', 'Explanation'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      KaTexMathText(
                        text: question.explanation,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bottom Navigation Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Row(
            children: [
              if (state.currentIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: notifier.previousQuestion,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(AppStrings.t(ref, 'পূর্ববর্তী', 'Previous')),
                  ),
                ),
              if (state.currentIndex > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: !isAnswered
                      ? null
                      : state.currentIndex == total - 1
                          ? notifier.finishChallenge
                          : notifier.nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    state.currentIndex == total - 1
                        ? AppStrings.t(ref, 'ফলাফল দেখুন ➔', 'Finish & Results ➔')
                        : AppStrings.t(ref, 'পরবর্তী প্রশ্ন ➔', 'Next Question ➔'),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Completed State View
  Widget _buildCompletedView(
    BuildContext context,
    DailyChallengeState state,
    bool isDark,
    bool isBn,
  ) {
    final total = state.questions.length;
    final score = state.score;
    final accuracy = (score / (total == 0 ? 1 : total) * 100).round();
    final optionLetters = isBn ? _bnOptionLetters : _enOptionLetters;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Hero Score Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFFEEF2FF), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.trophy,
                    color: Colors.orange, size: 32),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.t(ref, 'চমৎকার সম্পন্ন হয়েছে!', 'Challenge Completed!'),
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.t(ref, 'আজকের দৈনিক ৫টি প্রশ্নের চ্যালেঞ্জ সম্পন্ন',
                    'Today\'s 5-question challenge finished'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricTile(
                    label: AppStrings.t(ref, 'স্কোর', 'Score'),
                    value: isBn
                        ? '${BengaliNumeralConverter.toBengaliNumber(score)}/${BengaliNumeralConverter.toBengaliNumber(total)}'
                        : '$score/$total',
                    color: AppColors.primary,
                  ),
                  _buildMetricTile(
                    label: AppStrings.t(ref, 'সঠিকতা', 'Accuracy'),
                    value: isBn
                        ? '${BengaliNumeralConverter.toBengaliNumber(accuracy)}%'
                        : '$accuracy%',
                    color: AppColors.success,
                  ),
                  _buildMetricTile(
                    label: AppStrings.t(ref, 'সময়', 'Duration'),
                    value: _formatDuration(state.durationSeconds),
                    color: Colors.amber.shade700,
                  ),
                  _buildMetricTile(
                    label: AppStrings.t(ref, 'স্ট্রিক', 'Streak'),
                    value: isBn
                        ? '🔥 ${BengaliNumeralConverter.toBengaliNumber(state.currentStreak)}'
                        : '🔥 ${state.currentStreak}',
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Wordle-Style Copyable Share Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.sparkles, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.t(ref, 'শেয়ারযোগ্য রেজাল্ট কার্ড', 'Shareable Result Card'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  _generateWordleCard(state, isBn),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final card = _generateWordleCard(state, isBn);
                    Clipboard.setData(ClipboardData(text: card));
                    HapticFeedback.mediumImpact();
                    setState(() => _copied = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.t(ref,
                            'রেজাল্ট কার্ড ক্লিপবোর্ডে কপি করা হয়েছে!',
                            'Result card copied to clipboard!')),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _copied = false);
                    });
                  },
                  icon: Icon(_copied ? LucideIcons.check : LucideIcons.copy, size: 16),
                  label: Text(_copied
                      ? AppStrings.t(ref, 'কপি সম্পন্ন হয়েছে!', 'Copied!')
                      : AppStrings.t(ref, 'কার্ড কপি করুন', 'Copy Card')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Midnight Countdown Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.clock, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.t(ref, 'পরবর্তী চ্যালেঞ্জ বাকি:', 'Next Challenge In:'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Text(
                _countdownText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. Review Accordion (Detailed Breakdown)
        Text(
          AppStrings.t(ref, 'প্রশ্নোত্তর পর্যালোচনা (৫টি প্রশ্ন)', 'Question Review'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...state.questions.asMap().entries.map((entry) {
          final idx = entry.key;
          final q = entry.value;
          final userSelected = state.selectedAnswers[q.id];
          final isCorrect = userSelected == q.correctOptionId;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isCorrect
                    ? AppColors.success.withValues(alpha: 0.4)
                    : AppColors.error.withValues(alpha: 0.4),
              ),
            ),
            child: ExpansionTile(
              leading: Icon(
                isCorrect ? LucideIcons.checkCircle2 : LucideIcons.xCircle,
                color: isCorrect ? AppColors.success : AppColors.error,
                size: 20,
              ),
              title: Text(
                isBn
                    ? 'প্রশ্ন ${BengaliNumeralConverter.toBengaliNumber(idx + 1)}'
                    : 'Question ${idx + 1}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isCorrect
                    ? AppStrings.t(ref, 'সঠিক উত্তর', 'Correct')
                    : AppStrings.t(ref, 'ভুল উত্তর', 'Incorrect'),
                style: TextStyle(
                  fontSize: 11,
                  color: isCorrect ? AppColors.success : AppColors.error,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KaTexMathText(
                        text: q.question,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ...q.options.asMap().entries.map((optEntry) {
                        final optIdx = optEntry.key;
                        final opt = optEntry.value;
                        final optLetter = optIdx < optionLetters.length
                            ? optionLetters[optIdx]
                            : '${optIdx + 1}';
                        final isThisCorrect = q.correctOptionId == opt.id;
                        final isThisSelected = userSelected == opt.id;

                        Color color = isDark ? Colors.white70 : Colors.black87;
                        if (isThisCorrect) color = AppColors.success;
                        if (isThisSelected && !isThisCorrect) color = AppColors.error;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Text('$optLetter. ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, color: color)),
                              Expanded(
                                child: Text(opt.text,
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: isThisCorrect || isThisSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal)),
                              ),
                              if (isThisCorrect)
                                const Text(' (সঠিক)',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold)),
                              if (isThisSelected && !isThisCorrect)
                                const Text(' (আপনার উত্তর)',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }),
                      if (q.explanation.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            q.explanation,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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
    );
  }
}
