import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/core/utils/bengali_numeral_converter.dart';
import 'package:medhavi_mobile/core/components/katex_math_text.dart';
import 'package:medhavi_mobile/features/question_bank/domain/entities/question_entity.dart';

/// Universal Component-Based Question Card for Medhavi.
/// Reusable across:
/// 1. Question Bank Study Screen (/question-bank)
/// 2. Bookmarks Screen (/bookmarks) with "My Answer" vs "Correct Answer"
/// 3. Mistake Bank Screen (/mistakes) with "My Wrong Answer" vs "Correct Answer"
class StudyQuestionCard extends StatefulWidget {
  final int index;
  final QuestionEntity question;
  final bool isBookmarked;
  final Future<void> Function() onToggleBookmark;
  final String? subjectName;
  final bool defaultRevealed;
  final String? initialSelectedOptionId;
  final void Function(String optionId)? onAnswerSelect;
  final VoidCallback? onRemove;
  final String removeTooltip;
  final bool showPracticeSingle;
  final VoidCallback? onPracticeSingle;

  const StudyQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.isBookmarked,
    required this.onToggleBookmark,
    this.subjectName,
    this.defaultRevealed = false,
    this.initialSelectedOptionId,
    this.onAnswerSelect,
    this.onRemove,
    this.removeTooltip = 'তালিকা থেকে সরান',
    this.showPracticeSingle = false,
    this.onPracticeSingle,
  });

  @override
  State<StudyQuestionCard> createState() => _StudyQuestionCardState();
}

class _StudyQuestionCardState extends State<StudyQuestionCard> {
  late bool _isRevealed;
  String? _selectedOptionId;
  bool _copied = false;
  bool _bookmarkLoading = false;

  final List<String> _optionLetters = ['A', 'B', 'C', 'D', 'E'];
  final List<String> _bnLetters = ['ক', 'খ', 'গ', 'ঘ', 'ঙ'];

  @override
  void initState() {
    super.initState();
    _selectedOptionId = widget.initialSelectedOptionId;
    _isRevealed = widget.defaultRevealed || (_selectedOptionId != null);
  }

  @override
  void didUpdateWidget(covariant StudyQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedOptionId != oldWidget.initialSelectedOptionId) {
      setState(() {
        _selectedOptionId = widget.initialSelectedOptionId;
        if (_selectedOptionId != null) {
          _isRevealed = true;
        }
      });
    }

    if (widget.defaultRevealed != oldWidget.defaultRevealed) {
      setState(() {
        _isRevealed = widget.defaultRevealed;
      });
    }
  }

  void _handleOptionClick(String optionId) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedOptionId = optionId;
      _isRevealed = true;
    });
    widget.onAnswerSelect?.call(optionId);
  }

  void _toggleReveal() {
    HapticFeedback.selectionClick();
    setState(() {
      _isRevealed = !_isRevealed;
    });
  }

  Future<void> _handleBookmark() async {
    setState(() => _bookmarkLoading = true);
    try {
      await widget.onToggleBookmark();
    } finally {
      if (mounted) setState(() => _bookmarkLoading = false);
    }
  }

  void _copyQuestionToClipboard() {
    HapticFeedback.selectionClick();
    final q = widget.question;
    final buffer = StringBuffer();
    buffer.writeln('প্রশ্ন: ${q.question}');
    for (int i = 0; i < q.options.length; i++) {
      final letter = i < _bnLetters.length
          ? '(${_bnLetters[i]})'
          : '(${q.options[i].id.toUpperCase()})';
      buffer.writeln('$letter ${q.options[i].text}');
    }
    final correctOpt = q.options.firstWhere(
      (o) => o.id == q.correctOptionId,
      orElse: () =>
          QuestionOption(id: q.correctOptionId, text: q.correctOptionId),
    );
    buffer.writeln('সঠিক উত্তর: ${correctOpt.text}');
    if (q.explanation.isNotEmpty) {
      buffer.writeln('\nব্যাখ্যা:\n${q.explanation}');
    }
    if (q.source != null) {
      buffer.writeln('\n[উৎস: ${q.source}]');
    }
    buffer.writeln('\n— মেধাবী (Medhavi) প্রশ্ন ব্যাংক');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = Localizations.localeOf(context).languageCode != 'en';
    final q = widget.question;

    final correctOpt = q.options.firstWhere(
      (o) => o.id == q.correctOptionId,
      orElse: () =>
          QuestionOption(id: q.correctOptionId, text: q.correctOptionId),
    );
    final correctIdx = q.options.indexWhere((o) => o.id == q.correctOptionId);
    final correctLetter = correctIdx >= 0
        ? _optionLetters[correctIdx]
        : q.correctOptionId.toUpperCase();

    final userOpt = _selectedOptionId != null
        ? q.options.firstWhere((o) => o.id == _selectedOptionId,
            orElse: () => QuestionOption(id: '', text: ''))
        : null;
    final userIdx = _selectedOptionId != null
        ? q.options.indexWhere((o) => o.id == _selectedOptionId)
        : -1;
    final userLetter = userIdx >= 0
        ? _optionLetters[userIdx]
        : _selectedOptionId?.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Question Index, Source, Subject, Difficulty, Bookmark/Trash)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Index Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBn
                            ? 'প্রশ্ন ${BengaliNumeralConverter.toBengaliNumber(widget.index + 1)}'
                            : 'Q #${widget.index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Source Badge
                    if (q.source != null) ...[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primaryBgDark
                                : AppColors.primaryBgLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            isBn
                                ? BengaliNumeralConverter.toBengaliBcsTitle(
                                    q.source!)
                                : q.source!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],

                    // Subject Badge
                    if (widget.subjectName != null) ...[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.subjectName!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],

                    // Difficulty Badge
                    _buildDifficultyBadge(q.difficulty, isDark, isBn),

                    // Admin Verified Badge
                    if (q.adminVerified) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF064E3B)
                              : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF059669)
                                : const Color(0xFFA7F3D0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.shieldCheck,
                              size: 11,
                              color: isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF059669),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isBn ? 'ভেরিফাইড' : 'Verified',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Remove Button (Optional for Bookmarks / Mistakes)
                    if (widget.onRemove != null) ...[
                      IconButton(
                        onPressed: widget.onRemove,
                        tooltip: widget.removeTooltip,
                        icon: const Icon(LucideIcons.trash2, size: 16),
                        color: Colors.redAccent,
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      const SizedBox(width: 4),
                    ],

                    // Bookmark Star Button
                    IconButton(
                      onPressed: _bookmarkLoading ? null : _handleBookmark,
                      tooltip: isBn
                          ? (widget.isBookmarked
                              ? 'সংরক্ষণ তালিকা থেকে সরান'
                              : 'বুকমার্ক করুন')
                          : (widget.isBookmarked
                              ? 'Remove Bookmark'
                              : 'Bookmark'),
                      icon: Icon(
                        widget.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 20,
                        color: widget.isBookmarked
                            ? Colors.amber
                            : (isDark ? Colors.white38 : Colors.black26),
                      ),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Question Text
                KaTexMathText(
                  text: q.question,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),

          // 2. Comparative Answer Summary Banner
          if (_isRevealed) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildAnswerComparisonBanner(
                isDark: isDark,
                isBn: isBn,
                correctLetter: correctLetter,
                correctText: correctOpt.text,
                userLetter: userLetter,
                userText: userOpt?.text,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 3. Options List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(q.options.length, (optIdx) {
                final opt = q.options[optIdx];
                final letter = optIdx < _optionLetters.length
                    ? _optionLetters[optIdx]
                    : opt.id.toUpperCase();
                final isCorrect = opt.id == q.correctOptionId;
                final isSelected = _selectedOptionId == opt.id;

                return _buildOptionTile(
                  isDark: isDark,
                  isBn: isBn,
                  letter: letter,
                  text: opt.text,
                  isCorrect: isCorrect,
                  isSelected: isSelected,
                  isRevealed: _isRevealed,
                  onTap: () => _handleOptionClick(opt.id),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          // 4. Reveal Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black26
                  : Colors.black.withValues(alpha: 0.02),
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              children: [
                // Toggle Button
                InkWell(
                  onTap: _toggleReveal,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isRevealed
                          ? (isDark
                              ? Colors.white12
                              : Colors.black.withValues(alpha: 0.08))
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isRevealed ? LucideIcons.eyeOff : LucideIcons.eye,
                          size: 14,
                          color: _isRevealed
                              ? (isDark ? Colors.white70 : Colors.black87)
                              : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isBn
                              ? (_isRevealed
                                  ? 'উত্তর ও ব্যাখ্যা লুকান'
                                  : 'উত্তর ও ব্যাখ্যা দেখুন')
                              : (_isRevealed
                                  ? 'Hide Answer & Explanation'
                                  : 'Show Answer & Explanation'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isRevealed
                                ? (isDark ? Colors.white70 : Colors.black87)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Answer Result Status Badge
                if (_selectedOptionId != null) ...[
                  Row(
                    children: [
                      Icon(
                        _selectedOptionId == q.correctOptionId
                            ? LucideIcons.checkCircle2
                            : LucideIcons.xCircle,
                        size: 14,
                        color: _selectedOptionId == q.correctOptionId
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isBn
                            ? (_selectedOptionId == q.correctOptionId
                                ? 'আপনার উত্তর সঠিক!'
                                : 'আপনার উত্তর ভুল')
                            : (_selectedOptionId == q.correctOptionId
                                ? 'Correct Answer!'
                                : 'Wrong Answer'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _selectedOptionId == q.correctOptionId
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // 5. Detailed Explanation Drawer
          if (_isRevealed && q.explanation.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryBgDark.withValues(alpha: 0.3)
                    : AppColors.primaryBgLight.withValues(alpha: 0.6),
                border: Border(
                  top: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.lightbulb,
                          size: 16, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        isBn
                            ? 'বিস্তারিত ব্যাখ্যা ও সমাধান:'
                            : 'Detailed Explanation & Solution:',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  KaTexMathText(
                    text: q.explanation,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 6. Footer (Tags, Copy Button, Practice Single)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              children: [
                // Tags
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: q.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Practice Single
                if (widget.showPracticeSingle &&
                    widget.onPracticeSingle != null) ...[
                  OutlinedButton.icon(
                    onPressed: widget.onPracticeSingle,
                    icon: const Icon(LucideIcons.sparkles,
                        size: 12, color: AppColors.primary),
                    label: Text(
                      isBn ? 'অনুশীলন' : 'Practice Single',
                      style: const TextStyle(fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Copy Button
                InkWell(
                  onTap: _copyQuestionToClipboard,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          _copied ? LucideIcons.check : LucideIcons.copy,
                          size: 13,
                          color: _copied
                              ? AppColors.success
                              : (isDark ? Colors.white54 : Colors.black45),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isBn
                              ? (_copied ? 'কপি হয়েছে!' : 'কপি')
                              : (_copied ? 'Copied!' : 'Copy'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _copied
                                ? AppColors.success
                                : (isDark ? Colors.white54 : Colors.black45),
                          ),
                        ),
                      ],
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

  Widget _buildDifficultyBadge(String difficulty, bool isDark, bool isBn) {
    Color bg;
    Color fg;
    String label;
    if (difficulty == 'easy') {
      bg = isDark ? AppColors.successDark : AppColors.successLight;
      fg = AppColors.success;
      label = isBn ? 'সহজ' : 'Easy';
    } else if (difficulty == 'medium') {
      bg = isDark ? AppColors.warningDark : AppColors.warningLight;
      fg = AppColors.warning;
      label = isBn ? 'মধ্যম' : 'Medium';
    } else {
      bg = isDark ? AppColors.errorDark : AppColors.errorLight;
      fg = AppColors.error;
      label = isBn ? 'কঠিন' : 'Hard';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildAnswerComparisonBanner({
    required bool isDark,
    required bool isBn,
    required String correctLetter,
    required String correctText,
    String? userLetter,
    String? userText,
  }) {
    if (userLetter != null) {
      final isUserCorrect = _selectedOptionId == widget.question.correctOptionId;
      if (isUserCorrect) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.successDark.withValues(alpha: 0.4)
                : AppColors.successLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.checkCircle2,
                  size: 16, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: isBn
                            ? 'আপনার উত্তর সঠিক! '
                            : 'Your Answer is Correct! ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success),
                      ),
                      TextSpan(
                        text: '($correctLetter) $correctText',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      } else {
        return Column(
          children: [
            // User's Wrong Answer
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.errorDark.withValues(alpha: 0.4)
                    : AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.xCircle,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: isBn ? 'আপনার উত্তর: ' : 'Your Answer: ',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error),
                          ),
                          TextSpan(
                            text: '($userLetter) ${userText ?? ''}',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Correct Answer
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.successDark.withValues(alpha: 0.4)
                    : AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle2,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: isBn ? 'সঠিক উত্তর: ' : 'Correct Answer: ',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success),
                          ),
                          TextSpan(
                            text: '($correctLetter) $correctText',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    } else {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.successDark.withValues(alpha: 0.3)
              : AppColors.successLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.checkCircle2,
                size: 16, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: isBn ? 'সঠিক উত্তর: ' : 'Correct Answer: ',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success),
                    ),
                    TextSpan(
                      text: '($correctLetter) $correctText',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildOptionTile({
    required bool isDark,
    required bool isBn,
    required String letter,
    required String text,
    required bool isCorrect,
    required bool isSelected,
    required bool isRevealed,
    required VoidCallback onTap,
  }) {
    Color borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    Color bgColor = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.black.withValues(alpha: 0.02);
    Color badgeBg =
        isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06);
    Color badgeFg = isDark ? Colors.white70 : Colors.black87;

    if (isRevealed) {
      if (isCorrect) {
        borderColor = AppColors.success;
        bgColor = isDark
            ? AppColors.successDark.withValues(alpha: 0.35)
            : AppColors.successLight;
        badgeBg = AppColors.success;
        badgeFg = Colors.white;
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.error;
        bgColor = isDark
            ? AppColors.errorDark.withValues(alpha: 0.35)
            : AppColors.errorLight;
        badgeBg = AppColors.error;
        badgeFg = Colors.white;
      } else {
        bgColor = Colors.transparent;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: borderColor,
                width: isRevealed && (isCorrect || isSelected) ? 1.5 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Option Letter Circle
              Container(
                height: 22,
                width: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeBg,
                  shape: BoxShape.circle,
                ),
                child: isRevealed && isCorrect
                    ? const Icon(LucideIcons.check,
                        size: 14, color: Colors.white)
                    : isRevealed && isSelected && !isCorrect
                        ? const Icon(LucideIcons.x,
                            size: 14, color: Colors.white)
                        : Text(
                            letter,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: badgeFg,
                            ),
                          ),
              ),
              const SizedBox(width: 10),

              // Option Text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: KaTexMathText(
                    text: text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: isRevealed && (isCorrect || isSelected)
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),

              // Status Tag Badge
              if (isRevealed) ...[
                if (isSelected && isCorrect)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      isBn
                          ? 'আপনার উত্তর (সঠিক) ✓'
                          : 'Your Answer (Correct) ✓',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success),
                    ),
                  )
                else if (isSelected && !isCorrect)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      isBn ? 'আপনার উত্তর ✗' : 'Your Answer ✗',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error),
                    ),
                  )
                else if (!isSelected && isCorrect)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      isBn ? 'সঠিক উত্তর ✓' : 'Correct Answer ✓',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
