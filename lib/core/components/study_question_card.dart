import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/core/utils/bengali_numeral_converter.dart';
import 'package:medhavi_mobile/core/components/katex_math_text.dart';
import 'package:medhavi_mobile/features/question_bank/domain/entities/question_entity.dart';

/// Minimal Component-Based Question Card for Medhavi.
/// Reusable across:
/// 1. Question Bank Study Screen (/question-bank)
/// 2. Bookmarks Screen (/bookmarks)
/// 3. Mistake Bank Screen (/mistakes)
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
  bool _bookmarkLoading = false;

  final List<String> _enOptionLetters = ['A', 'B', 'C', 'D', 'E'];
  final List<String> _bnOptionLetters = ['ক', 'খ', 'গ', 'ঘ', 'ঙ'];

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = Localizations.localeOf(context).languageCode != 'en';
    final q = widget.question;

    // Dynamic Option Letters based on language
    final optionLetters = isBn ? _bnOptionLetters : _enOptionLetters;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
          // 1. Quiet Header (Metadata & Top-Right Actions)
          Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Question Index Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white10
                            : const Color(0xFFF1F5F9),
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

                    // Source / Batch
                    if (q.source != null && q.source!.isNotEmpty) ...[
                      Text('•',
                          style: TextStyle(
                              color: Colors.grey.withValues(alpha: 0.5),
                              fontSize: 10)),
                      Text(
                        isBn
                            ? BengaliNumeralConverter.toBengaliBcsTitle(
                                q.source!)
                            : q.source!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],

                    // Subject
                    if (widget.subjectName != null) ...[
                      Text('•',
                          style: TextStyle(
                              color: Colors.grey.withValues(alpha: 0.5),
                              fontSize: 10)),
                      Text(
                        widget.subjectName!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],

                    // Verified Badge
                    if (q.adminVerified) ...[
                      Text('•',
                          style: TextStyle(
                              color: Colors.grey.withValues(alpha: 0.5),
                              fontSize: 10)),
                      Icon(
                        LucideIcons.badgeCheck,
                        size: 13,
                        color: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // Actions: Remove & Bookmark
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onRemove != null) ...[
                    IconButton(
                      onPressed: widget.onRemove,
                      tooltip: widget.removeTooltip,
                      icon: const Icon(LucideIcons.trash2, size: 16),
                      color: Colors.redAccent,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 30, minHeight: 30),
                    ),
                    const SizedBox(width: 2),
                  ],
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
                        const BoxConstraints(minWidth: 30, minHeight: 30),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 2. Question Prompt
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

          const SizedBox(height: 12),

          // 3. Clean Option Tiles
          Column(
            children: List.generate(q.options.length, (optIdx) {
              final opt = q.options[optIdx];
              final letter = optIdx < optionLetters.length
                  ? optionLetters[optIdx]
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

          const SizedBox(height: 4),

          // 4. Seamless Inline Reveal & Explanation
          if (!_isRevealed) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _toggleReveal,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.eye,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          isBn
                              ? 'উত্তর ও ব্যাখ্যা দেখুন'
                              : 'Reveal Answer & Explanation',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.showPracticeSingle &&
                    widget.onPracticeSingle != null) ...[
                  InkWell(
                    onTap: widget.onPracticeSingle,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.sparkles,
                              size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            isBn ? 'একক অনুশীলন' : 'Practice Single',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ] else ...[
            // Header row inside revealed state (Toggle & Result status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _toggleReveal,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.eyeOff,
                            size: 13,
                            color: isDark ? Colors.white60 : Colors.black54),
                        const SizedBox(width: 5),
                        Text(
                          isBn ? 'লুকান' : 'Hide',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedOptionId != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedOptionId == q.correctOptionId
                            ? LucideIcons.checkCircle2
                            : LucideIcons.xCircle,
                        size: 13,
                        color: _selectedOptionId == q.correctOptionId
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isBn
                            ? (_selectedOptionId == q.correctOptionId
                                ? 'সঠিক উত্তর!'
                                : 'ভুল উত্তর')
                            : (_selectedOptionId == q.correctOptionId
                                ? 'Correct!'
                                : 'Incorrect'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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

            // Explanation Box
            if (q.explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryBgDark.withValues(alpha: 0.25)
                      : AppColors.primaryBgLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.lightbulb,
                            size: 14, color: Colors.amber),
                        const SizedBox(width: 5),
                        Text(
                          isBn ? 'ব্যাখ্যা:' : 'Explanation:',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    KaTexMathText(
                      text: q.explanation,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
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
            ? AppColors.successDark.withValues(alpha: 0.25)
            : AppColors.successLight;
        badgeBg = AppColors.success;
        badgeFg = Colors.white;
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.error;
        bgColor = isDark
            ? AppColors.errorDark.withValues(alpha: 0.25)
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: isRevealed && (isCorrect || isSelected) ? 1.5 : 1,
            ),
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
                        size: 13, color: Colors.white)
                    : isRevealed && isSelected && !isCorrect
                        ? const Icon(LucideIcons.x,
                            size: 13, color: Colors.white)
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

              // Minimal Trailing Indicator (✓ or ✗)
              if (isRevealed) ...[
                if (isCorrect)
                  const Padding(
                    padding: EdgeInsets.only(top: 2, left: 4),
                    child: Text(
                      '✓',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  )
                else if (isSelected && !isCorrect)
                  const Padding(
                    padding: EdgeInsets.only(top: 2, left: 4),
                    child: Text(
                      '✗',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
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
