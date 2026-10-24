import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/auto_hide_app_bar.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/components/study_question_card.dart';
import '../../../practice/presentation/controllers/practice_session_controller.dart';
import '../controllers/bookmarks_controller.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookmarksControllerProvider);
    final notifier = ref.read(bookmarksControllerProvider.notifier);
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
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.bookmark,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t(
                          ref, 'বুকমার্কসমূহ (Bookmarks)', 'Bookmarks'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppStrings.t(
                        ref,
                        'সংরক্ষিত গুরুত্বপূর্ণ প্রশ্নসমূহ',
                        'Your saved important questions',
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
                    backgroundColor: AppColors.primary,
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
                          title: AppStrings.t(
                              ref,
                              'বুকমার্ক করা প্রশ্ন অনুশীলন',
                              'Bookmarked Questions Drill'),
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
                  'সংরক্ষিত প্রশ্ন অনুসন্ধান করুন...',
                  'Search bookmarked questions...',
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
                    const Icon(LucideIcons.sparkles,
                        size: 15, color: AppColors.amber),
                    const SizedBox(width: 6),
                    Text(
                      isBn
                          ? '${AppStrings.num(ref, filteredList.length)}টি প্রশ্ন সংরক্ষিত'
                          : '${filteredList.length} questions saved',
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

          // 3. Bookmarked Questions List
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
                                      AppColors.primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.bookmark,
                                    size: 40, color: AppColors.primary),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.t(ref, 'কোনো বুকমার্ক করা প্রশ্ন নেই',
                                    'No bookmarked questions yet'),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.t(
                                  ref,
                                  'প্রশ্ন ব্যাংকে পড়ার সময় বুকমার্ক আইকনে চাপ দিয়ে সংরক্ষণ করুন।',
                                  'Tap the bookmark icon on any question card to save it here.',
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
                        onRefresh: notifier.loadBookmarks,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final question = filteredList[index];
                            final recordedAnswer =
                                state.userAnswersMap[question.id];

                            return StudyQuestionCard(
                              key: ValueKey(question.id),
                              question: question,
                              index: index,
                              isBookmarked: true,
                              initialSelectedOptionId: recordedAnswer,
                              defaultRevealed: state.globalRevealed,
                              onToggleBookmark: () =>
                                  notifier.removeBookmark(question.id),
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
