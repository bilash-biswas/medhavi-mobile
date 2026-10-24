import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/auto_hide_app_bar.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/components/study_question_card.dart';
import '../../../practice/presentation/controllers/practice_session_controller.dart';
import '../controllers/mistakes_controller.dart';

class MistakeBankScreen extends ConsumerStatefulWidget {
  const MistakeBankScreen({super.key});

  @override
  ConsumerState<MistakeBankScreen> createState() => _MistakeBankScreenState();
}

class _MistakeBankScreenState extends ConsumerState<MistakeBankScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mistakesControllerProvider);
    final notifier = ref.read(mistakesControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = AppStrings.isBn(ref);

    final filteredList = state.filteredQuestions;

    return Scaffold(
      appBar: AutoHideAppBar(
        child: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.rose.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.alertTriangle,
                    color: AppColors.rose, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t(
                          ref, 'ভুল ব্যাংক (Mistake Bank)', 'Mistake Bank'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppStrings.t(
                        ref,
                        'ভুল হওয়া প্রশ্নসমূহ সংশোধন করুন',
                        'Review & master your wrong answers',
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
          actions: [
            if (filteredList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rose,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(LucideIcons.play, size: 13),
                  label: Text(
                    AppStrings.t(ref, 'ড্রিল করুন', 'Practice All'),
                    style: const TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    ref
                        .read(practiceSessionControllerProvider.notifier)
                        .startPractice(
                          title: AppStrings.t(ref, 'ভুল প্রশ্ন সংশোধন ড্রিল',
                              'Mistake Recovery Drill'),
                          preloadedQuestions: filteredList,
                          mode: PracticeMode.instant,
                        );
                    context.push('/practice/session');
                  },
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Search Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: notifier.setSearchQuery,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: AppStrings.t(
                  ref,
                  'ভুল হওয়া প্রশ্ন অনুসন্ধান করুন...',
                  'Search mistakes...',
                ),
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                prefixIcon: const Icon(LucideIcons.search,
                    size: 18, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
            ),
          ),

          // 2. Stats & Master Auto-Reveal Toggle Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color:
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.alertCircle,
                        size: 15, color: AppColors.rose),
                    const SizedBox(width: 6),
                    Text(
                      isBn
                          ? '${AppStrings.num(ref, filteredList.length)}টি ভুল প্রশ্ন তালিকাভুক্ত'
                          : '${filteredList.length} mistakes listed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),

                // Auto Reveal Switch
                InkWell(
                  onTap: notifier.toggleGlobalRevealed,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: state.globalRevealed
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : (isDark ? AppColors.cardDark : AppColors.cardLight),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: state.globalRevealed
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.globalRevealed
                              ? LucideIcons.eye
                              : LucideIcons.eyeOff,
                          size: 14,
                          color: state.globalRevealed
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.globalRevealed
                              ? AppStrings.t(
                                  ref, 'সব উত্তর দৃশ্যমান', 'Answers Visible')
                              : AppStrings.t(
                                  ref, 'সব উত্তর লুকানো', 'Answers Hidden'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: state.globalRevealed
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Mistakes List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.emerald.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.checkCircle2,
                                    size: 40, color: AppColors.emerald),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.t(
                                  ref,
                                  'দারুণ! আপনার কোনো ভুল প্রশ্ন জমা নেই',
                                  'Great job! No pending mistakes',
                                ),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.t(
                                  ref,
                                  'অনুশীলন বা মক টেস্টে ভুল উত্তর দিলে তা এখানে স্বয়ংক্রিয়ভাবে জমা হবে।',
                                  'Wrong answers from practice sessions automatically appear here for review.',
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: notifier.loadMistakes,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final question = filteredList[index];
                            final isBookmarked =
                                state.bookmarkedIds.contains(question.id);
                            final recordedWrongAnswer =
                                state.userAnswersMap[question.id];

                            return StudyQuestionCard(
                              key: ValueKey(question.id),
                              question: question,
                              index: index,
                              isBookmarked: isBookmarked,
                              initialSelectedOptionId: recordedWrongAnswer,
                              defaultRevealed: state.globalRevealed,
                              removeTooltip: AppStrings.t(
                                  ref, 'তালিকা থেকে সরান', 'Remove from list'),
                              onToggleBookmark: () =>
                                  notifier.toggleBookmark(question.id),
                              onRemove: () =>
                                  notifier.removeMistake(question.id),
                              onAnswerSelect: (optId) =>
                                  notifier.recordAnswer(question.id, optId),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
