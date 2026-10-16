import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/bengali_numeral_converter.dart';
import '../../../../core/components/study_question_card.dart';
import '../controllers/question_bank_controller.dart';

// BCS Batches list sorted newest to oldest
const List<Map<String, String>> kBcsBatches = [
  {'id': '', 'label': 'সব বিসিএস ব্যাচ (All Batches)'},
  {'id': '50th-bcs', 'label': '৫০তম বিসিএস (50th BCS)'},
  {'id': '49th-bcs', 'label': '৪৯তম বিসিএস (49th BCS)'},
  {'id': '48th-bcs', 'label': '৪৮তম বিসিএস (48th BCS)'},
  {'id': '47th-bcs', 'label': '৪৭তম বিসিএস (47th BCS)'},
  {'id': '46th-bcs', 'label': '৪৬তম বিসিএস (46th BCS)'},
  {'id': '45th-bcs', 'label': '৪৫তম বিসিএস (45th BCS)'},
  {'id': '44th-bcs', 'label': '৪৪তম বিসিএস (44th BCS)'},
  {'id': '43rd-bcs', 'label': '৪৩তম বিসিএস (43rd BCS)'},
  {'id': '42nd-bcs', 'label': '৪২তম বিসিএস বিশেষ (42nd BCS Special)'},
  {'id': '41st-bcs', 'label': '৪১তম বিসিএস (41st BCS)'},
  {'id': '40th-bcs', 'label': '৪০তম বিসিএস (40th BCS)'},
  {'id': '39th-bcs', 'label': '৩৯তম বিসিএস বিশেষ (39th BCS Special)'},
  {'id': '38th-bcs', 'label': '৩৮তম বিসিএস (38th BCS)'},
  {'id': '37th-bcs', 'label': '৩৭তম বিসিএস (37th BCS)'},
  {'id': '36th-bcs', 'label': '৩৬তম বিসিএস (36th BCS)'},
  {'id': '35th-bcs', 'label': '৩৫তম বিসিএস (35th BCS)'},
  {'id': '34th-bcs', 'label': '৩৪তম বিসিএস (34th BCS)'},
  {'id': '33rd-bcs', 'label': '৩৩তম বিসিএস (33rd BCS)'},
  {'id': '32nd-bcs', 'label': '৩২তম বিসিএস (32nd BCS)'},
  {'id': '31st-bcs', 'label': '৩১তম বিসিএস (31st BCS)'},
  {'id': '30th-bcs', 'label': '৩০তম বিসিএস (30th BCS)'},
  {'id': '29th-bcs', 'label': '২৯তম বিসিএস (29th BCS)'},
  {'id': '28th-bcs', 'label': '২৮তম বিসিএস (28th BCS)'},
  {'id': '27th-bcs', 'label': '২৭তম বিসিএস (27th BCS)'},
  {'id': '26th-bcs', 'label': '২৬তম বিসিএস (26th BCS)'},
  {'id': '25th-bcs', 'label': '২৫তম বিসিএস (25th BCS)'},
  {'id': '24th-bcs', 'label': '২৪তম বিসিএস (24th BCS)'},
  {'id': '23rd-bcs', 'label': '২৩তম বিসিএস (23rd BCS)'},
  {'id': '22nd-bcs', 'label': '২২তম বিসিএস (22nd BCS)'},
  {'id': '21st-bcs', 'label': '২১তম বিসিএস (21st BCS)'},
  {'id': '20th-bcs', 'label': '২০তম বিসিএস (20th BCS)'},
  {'id': '19th-bcs', 'label': '১৯তম বিসিএস (19th BCS)'},
  {'id': '18th-bcs', 'label': '১৮তম বিসিএস (18th BCS)'},
  {'id': '17th-bcs', 'label': '১৭তম বিসিএস (17th BCS)'},
  {'id': '16th-bcs', 'label': '১৬তম বিসিএস (16th BCS)'},
  {'id': '15th-bcs', 'label': '১৫তম বিসিএস (15th BCS)'},
  {'id': '14th-bcs', 'label': '১৪তম বিসিএস (14th BCS)'},
  {'id': '13th-bcs', 'label': '১৩তম বিসিএস (13th BCS)'},
  {'id': '12th-bcs', 'label': '১২তম বিসিএস (12th BCS)'},
  {'id': '11th-bcs', 'label': '১১তম বিসিএস (11th BCS)'},
  {'id': '10th-bcs', 'label': '১০ম বিসিএস (10th BCS)'},
];

class QuestionBankScreen extends ConsumerStatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  ConsumerState<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends ConsumerState<QuestionBankScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(questionBankControllerProvider.notifier).loadNextPage();
    }
  }

  void _openBatchSelector(BuildContext context, String currentTag) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'বিসিএস ব্যাচ নির্বাচন করুন',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: kBcsBatches.length,
                    itemBuilder: (_, index) {
                      final batch = kBcsBatches[index];
                      final isSelected = batch['id'] == currentTag;
                      return ListTile(
                        title: Text(
                          batch['label']!,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(LucideIcons.check,
                                color: AppColors.primary, size: 20)
                            : null,
                        onTap: () {
                          ref
                              .read(questionBankControllerProvider.notifier)
                              .setBatch(batch['id']!);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionBankControllerProvider);
    final notifier = ref.read(questionBankControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredList = state.filteredQuestions;

    // Find current batch label
    final currentBatch = kBcsBatches.firstWhere(
      (b) => b['id'] == state.selectedBatchTag,
      orElse: () => kBcsBatches.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.bookOpen,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'প্রশ্ন ব্যাংক (Question Bank)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '১০ম থেকে ৫০তম বিসিএস প্রিলিমিনারি প্রশ্ন ও ব্যাখ্যা',
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
      body: Column(
        children: [
          // 1. Top Filter Controls (Batch & Search Bar)
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
            child: Column(
              children: [
                Row(
                  children: [
                    // BCS Batch Selector Button
                    Expanded(
                      flex: 6,
                      child: InkWell(
                        onTap: () =>
                            _openBatchSelector(context, state.selectedBatchTag),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.backgroundDark
                                : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  currentBatch['label']!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                              const Icon(LucideIcons.chevronDown, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Reset button if filters active
                    if (state.selectedSubjectId.isNotEmpty ||
                        state.selectedBatchTag.isNotEmpty ||
                        state.searchQuery.isNotEmpty) ...[
                      IconButton(
                        tooltip: 'ফিল্টার রিসেট করুন',
                        icon: const Icon(LucideIcons.rotateCcw, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                          notifier.setBatch('');
                          notifier.setSubject('');
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Search Box
                TextField(
                  controller: _searchController,
                  onChanged: notifier.setSearchQuery,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'প্রশ্ন, ট্যাগ বা বিষয় অনুসন্ধান করুন...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    prefixIcon:
                        const Icon(LucideIcons.search, size: 18, color: Colors.grey),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
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
              ],
            ),
          ),

          // 2. Horizontal Subject Pills
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // 'All Subjects' Chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: state.selectedSubjectId.isEmpty,
                    label: const Text('সব বিষয় (All Subjects)'),
                    onSelected: (_) => notifier.setSubject(''),
                  ),
                ),
                ...state.subjects.map((sub) {
                  final isSelected = state.selectedSubjectId == sub['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(sub['name'] ?? ''),
                      onSelected: (_) => notifier.setSubject(sub['id'] ?? ''),
                    ),
                  );
                }),
              ],
            ),
          ),

          // 3. Stats & Master Auto-Reveal Toggle Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.sparkles,
                        size: 15, color: AppColors.amber),
                    const SizedBox(width: 6),
                    Text(
                      '${BengaliNumeralConverter.toBengaliNumber(filteredList.length)}টি প্রশ্ন প্রদর্শিত',
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

                // Auto Reveal Master Switch
                InkWell(
                  onTap: notifier.toggleAutoRevealAll,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: state.autoRevealAll
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : (isDark ? AppColors.cardDark : AppColors.cardLight),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: state.autoRevealAll
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
                          state.autoRevealAll
                              ? LucideIcons.eye
                              : LucideIcons.eyeOff,
                          size: 14,
                          color: state.autoRevealAll
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.autoRevealAll
                              ? 'সব উত্তর দৃশ্যমান'
                              : 'সব উত্তর লুকানো',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: state.autoRevealAll
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

          // 4. Questions List
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.helpCircle,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text(
                              'কোনো প্রশ্ন পাওয়া যায়নি',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'অনুসন্ধান শব্দ বা ফিল্টার পরিবর্তন করে আবার চেষ্টা করুন।',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                                notifier.setSearchQuery('');
                                notifier.setBatch('');
                                notifier.setSubject('');
                              },
                              child: const Text('সব ফিল্টার মুছুন'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: notifier.loadInitialQuestions,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          itemCount: filteredList.length +
                              (state.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            if (index == filteredList.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final question = filteredList[index];
                            final isBookmarked =
                                state.bookmarkedIds.contains(question.id);
                            final recordedAnswer =
                                state.userAnswers[question.id];

                            // Find subject name
                            final subject = state.subjects.firstWhere(
                              (s) => s['id'] == question.subjectId,
                              orElse: () => {'name': question.subjectId},
                            );

                            return StudyQuestionCard(
                              key: ValueKey(question.id),
                              question: question,
                              index: index,
                              subjectName: subject['name'] as String?,
                              isBookmarked: isBookmarked,
                              initialSelectedOptionId: recordedAnswer,
                              defaultRevealed: state.autoRevealAll,
                              onToggleBookmark: () =>
                                  notifier.toggleBookmark(question.id),
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
