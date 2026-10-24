import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/auto_hide_app_bar.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/components/study_question_card.dart';
import '../controllers/question_bank_controller.dart';

// BCS Batches list sorted newest to oldest
const List<Map<String, String>> kBcsBatches = [
  {
    'id': '',
    'label': 'সব বিসিএস ব্যাচ (All Batches)',
    'labelBn': 'সব বিসিএস ব্যাচ',
    'labelEn': 'All BCS Batches',
  },
  {'id': '50th-bcs', 'label': '৫০তম বিসিএস (50th BCS)', 'labelBn': '৫০তম বিসিএস', 'labelEn': '50th BCS'},
  {'id': '49th-bcs', 'label': '৪৯তম বিসিএস (49th BCS)', 'labelBn': '৪৯তম বিসিএস', 'labelEn': '49th BCS'},
  {'id': '48th-bcs', 'label': '৪৮তম বিসিএস (48th BCS)', 'labelBn': '৪৮তম বিসিএস', 'labelEn': '48th BCS'},
  {'id': '47th-bcs', 'label': '৪৭তম বিসিএস (47th BCS)', 'labelBn': '৪৭তম বিসিএস', 'labelEn': '47th BCS'},
  {'id': '46th-bcs', 'label': '৪৬তম বিসিএস (46th BCS)', 'labelBn': '৪৬তম বিসিএস', 'labelEn': '46th BCS'},
  {'id': '45th-bcs', 'label': '৪৫তম বিসিএস (45th BCS)', 'labelBn': '৪৫তম বিসিএস', 'labelEn': '45th BCS'},
  {'id': '44th-bcs', 'label': '৪৪তম বিসিএস (44th BCS)', 'labelBn': '৪৪তম বিসিএস', 'labelEn': '44th BCS'},
  {'id': '43rd-bcs', 'label': '৪৩তম বিসিএস (43rd BCS)', 'labelBn': '৪৩তম বিসিএস', 'labelEn': '43rd BCS'},
  {'id': '42nd-bcs', 'label': '৪২তম বিসিএস বিশেষ (42nd BCS Special)', 'labelBn': '৪২তম বিসিএস (বিশেষ)', 'labelEn': '42nd BCS (Special)'},
  {'id': '41st-bcs', 'label': '৪১তম বিসিএস (41st BCS)', 'labelBn': '৪১তম বিসিএস', 'labelEn': '41st BCS'},
  {'id': '40th-bcs', 'label': '৪০তম বিসিএস (40th BCS)', 'labelBn': '৪০তম বিসিএস', 'labelEn': '40th BCS'},
  {'id': '39th-bcs', 'label': '৩৯তম বিসিএস বিশেষ (39th BCS Special)', 'labelBn': '৩৯তম বিসিএস (বিশেষ)', 'labelEn': '39th BCS (Special)'},
  {'id': '38th-bcs', 'label': '৩৮তম বিসিএস (38th BCS)', 'labelBn': '৩৮তম বিসিএস', 'labelEn': '38th BCS'},
  {'id': '37th-bcs', 'label': '৩৭তম বিসিএস (37th BCS)', 'labelBn': '৩৭তম বিসিএস', 'labelEn': '37th BCS'},
  {'id': '36th-bcs', 'label': '৩৬তম বিসিএস (36th BCS)', 'labelBn': '৩৬তম বিসিএস', 'labelEn': '36th BCS'},
  {'id': '35th-bcs', 'label': '৩৫তম বিসিএস (35th BCS)', 'labelBn': '৩৫তম বিসিএস', 'labelEn': '35th BCS'},
  {'id': '34th-bcs', 'label': '৩৪তম বিসিএস (34th BCS)', 'labelBn': '৩৪তম বিসিএস', 'labelEn': '34th BCS'},
  {'id': '33rd-bcs', 'label': '৩৩তম বিসিএস (33rd BCS)', 'labelBn': '৩৩তম বিসিএস', 'labelEn': '33rd BCS'},
  {'id': '32nd-bcs', 'label': '৩২তম বিসিএস (32nd BCS)', 'labelBn': '৩২তম বিসিএস', 'labelEn': '32nd BCS'},
  {'id': '31st-bcs', 'label': '৩১তম বিসিএস (31st BCS)', 'labelBn': '৩১তম বিসিএস', 'labelEn': '31st BCS'},
  {'id': '30th-bcs', 'label': '৩০তম বিসিএস (30th BCS)', 'labelBn': '৩০তম বিসিএস', 'labelEn': '30th BCS'},
  {'id': '29th-bcs', 'label': '২৯তম বিসিএস (29th BCS)', 'labelBn': '২৯তম বিসিএস', 'labelEn': '29th BCS'},
  {'id': '28th-bcs', 'label': '২৮তম বিসিএস (28th BCS)', 'labelBn': '২৮তম বিসিএস', 'labelEn': '28th BCS'},
  {'id': '27th-bcs', 'label': '২৭তম বিসিএস (27th BCS)', 'labelBn': '২৭তম বিসিএস', 'labelEn': '27th BCS'},
  {'id': '26th-bcs', 'label': '২৬তম বিসিএস (26th BCS)', 'labelBn': '২৬তম বিসিএস', 'labelEn': '26th BCS'},
  {'id': '25th-bcs', 'label': '২৫তম বিসিএস (25th BCS)', 'labelBn': '২৫তম বিসিএস', 'labelEn': '25th BCS'},
  {'id': '24th-bcs', 'label': '২৪তম বিসিএস (24th BCS)', 'labelBn': '২৪তম বিসিএস', 'labelEn': '24th BCS'},
  {'id': '23rd-bcs', 'label': '২৩তম বিসিএস (23rd BCS)', 'labelBn': '২৩তম বিসিএস', 'labelEn': '23rd BCS'},
  {'id': '22nd-bcs', 'label': '২২তম বিসিএস (22nd BCS)', 'labelBn': '২২তম বিসিএস', 'labelEn': '22nd BCS'},
  {'id': '21st-bcs', 'label': '২১তম বিসিএস (21st BCS)', 'labelBn': '২১তম বিসিএস', 'labelEn': '21st BCS'},
  {'id': '20th-bcs', 'label': '২০তম বিসিএস (20th BCS)', 'labelBn': '২০তম বিসিএস', 'labelEn': '20th BCS'},
  {'id': '19th-bcs', 'label': '১৯তম বিসিএস (19th BCS)', 'labelBn': '১৯তম বিসিএস', 'labelEn': '19th BCS'},
  {'id': '18th-bcs', 'label': '১৮তম বিসিএস (18th BCS)', 'labelBn': '১৮তম বিসিএস', 'labelEn': '18th BCS'},
  {'id': '17th-bcs', 'label': '১৭তম বিসিএস (17th BCS)', 'labelBn': '১৭তম বিসিএস', 'labelEn': '17th BCS'},
  {'id': '16th-bcs', 'label': '১৬তম বিসিএস (16th BCS)', 'labelBn': '১৬তম বিসিএস', 'labelEn': '16th BCS'},
  {'id': '15th-bcs', 'label': '১৫তম বিসিএস (15th BCS)', 'labelBn': '১৫তম বিসিএস', 'labelEn': '15th BCS'},
  {'id': '14th-bcs', 'label': '১৪তম বিসিএস (14th BCS)', 'labelBn': '১৪তম বিসিএস', 'labelEn': '14th BCS'},
  {'id': '13th-bcs', 'label': '১৩তম বিসিএস (13th BCS)', 'labelBn': '১৩তম বিসিএস', 'labelEn': '13th BCS'},
  {'id': '12th-bcs', 'label': '১২তম বিসিএস (12th BCS)', 'labelBn': '১২তম বিসিএস', 'labelEn': '12th BCS'},
  {'id': '11th-bcs', 'label': '১১তম বিসিএস (11th BCS)', 'labelBn': '১১তম বিসিএস', 'labelEn': '11th BCS'},
  {'id': '10th-bcs', 'label': '১০ম বিসিএস (10th BCS)', 'labelBn': '১০ম বিসিএস', 'labelEn': '10th BCS'},
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

  void _openBatchSelector(BuildContext context, String currentTag, bool isBn) {
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
                      Text(
                        isBn
                            ? 'বিসিএস ব্যাচ নির্বাচন করুন'
                            : 'Select BCS Batch',
                        style: const TextStyle(
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
                      final label = isBn
                          ? (batch['labelBn'] ?? batch['label']!)
                          : (batch['labelEn'] ?? batch['label']!);
                      return ListTile(
                        title: Text(
                          label,
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
    final isBn = AppStrings.isBn(ref);

    final filteredList = state.filteredQuestions;

    // Find current batch label
    final currentBatch = kBcsBatches.firstWhere(
      (b) => b['id'] == state.selectedBatchTag,
      orElse: () => kBcsBatches.first,
    );
    final currentBatchLabel = isBn
        ? (currentBatch['labelBn'] ?? currentBatch['label']!)
        : (currentBatch['labelEn'] ?? currentBatch['label']!);

    final allQuestionsCount = state.subjectCounts['all'] ?? 0;

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
                child: const Icon(LucideIcons.bookOpen,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t(
                          ref, 'প্রশ্ন ব্যাংক (Question Bank)', 'Question Bank'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppStrings.t(
                        ref,
                        '১০ম থেকে ৫০তম বিসিএস প্রিলিমিনারি প্রশ্ন ও ব্যাখ্যা',
                        '10th to 50th BCS Preliminary MCQs & Explanations',
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
                        onTap: () => _openBatchSelector(
                            context, state.selectedBatchTag, isBn),
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
                                  currentBatchLabel,
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
                        state.selectedDifficulty != 'all' ||
                        state.searchQuery.isNotEmpty) ...[
                      IconButton(
                        tooltip: AppStrings.t(
                            ref, 'ফিল্টার রিসেট করুন', 'Reset Filters'),
                        icon: const Icon(LucideIcons.rotateCcw, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                          notifier.setBatch('');
                          notifier.setSubject('');
                          notifier.setDifficulty('all');
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
                    hintText: AppStrings.t(
                      ref,
                      'প্রশ্ন, ট্যাগ বা বিষয় অনুসন্ধান করুন...',
                      'Search questions, tags, or topics...',
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

          // 2. Horizontal Subject Pills with Live Question Counts
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(vertical: 5),
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
                    label: Text(
                      allQuestionsCount > 0
                          ? '${AppStrings.t(ref, 'সব বিষয়', 'All Subjects')} (${AppStrings.num(ref, allQuestionsCount)})'
                          : AppStrings.t(ref, 'সব বিষয়', 'All Subjects'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    onSelected: (_) => notifier.setSubject(''),
                  ),
                ),
                ...state.subjects.map((sub) {
                  final subId = sub['id'] as String? ?? '';
                  final isSelected = state.selectedSubjectId == subId;
                  final subName = isBn
                      ? (sub['name'] as String? ?? '')
                      : ((sub['nameEn'] as String?)?.isNotEmpty == true
                          ? sub['nameEn'] as String
                          : (sub['name'] as String? ?? ''));
                  final count = state.subjectCounts[subId] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        count > 0
                            ? '$subName (${AppStrings.num(ref, count)})'
                            : subName,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onSelected: (_) => notifier.setSubject(subId),
                    ),
                  );
                }),
              ],
            ),
          ),

          // 3. Difficulty Filter Row + Stats & Auto-Reveal Toggle Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Column(
              children: [
                // Difficulty Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDifficultyFilterPill(
                        ref: ref,
                        isDark: isDark,
                        value: 'all',
                        selectedValue: state.selectedDifficulty,
                        label: AppStrings.t(ref, 'সব মান', 'All Levels'),
                        activeColor: AppColors.primary,
                        onTap: () => notifier.setDifficulty('all'),
                      ),
                      const SizedBox(width: 6),
                      _buildDifficultyFilterPill(
                        ref: ref,
                        isDark: isDark,
                        value: 'easy',
                        selectedValue: state.selectedDifficulty,
                        label: AppStrings.t(ref, 'সহজ', 'Easy'),
                        activeColor: AppColors.success,
                        onTap: () => notifier.setDifficulty('easy'),
                      ),
                      const SizedBox(width: 6),
                      _buildDifficultyFilterPill(
                        ref: ref,
                        isDark: isDark,
                        value: 'medium',
                        selectedValue: state.selectedDifficulty,
                        label: AppStrings.t(ref, 'মধ্যম', 'Medium'),
                        activeColor: AppColors.warning,
                        onTap: () => notifier.setDifficulty('medium'),
                      ),
                      const SizedBox(width: 6),
                      _buildDifficultyFilterPill(
                        ref: ref,
                        isDark: isDark,
                        value: 'hard',
                        selectedValue: state.selectedDifficulty,
                        label: AppStrings.t(ref, 'কঠিন', 'Hard'),
                        activeColor: AppColors.error,
                        onTap: () => notifier.setDifficulty('hard'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.sparkles,
                            size: 15, color: AppColors.amber),
                        const SizedBox(width: 6),
                        Text(
                          state.totalMatchingCount > 0 &&
                                  state.searchQuery.trim().isEmpty
                              ? (isBn
                                  ? '${AppStrings.num(ref, filteredList.length)} / ${AppStrings.num(ref, state.totalMatchingCount)}টি প্রশ্ন প্রদর্শিত'
                                  : 'Showing ${filteredList.length} of ${state.totalMatchingCount} questions')
                              : (isBn
                                  ? '${AppStrings.num(ref, filteredList.length)}টি প্রশ্ন প্রদর্শিত'
                                  : '${filteredList.length} questions shown'),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: state.autoRevealAll
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : (isDark
                                  ? AppColors.cardDark
                                  : AppColors.cardLight),
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
                                  ? AppStrings.t(
                                      ref, 'সব উত্তর দৃশ্যমান', 'Answers Visible')
                                  : AppStrings.t(
                                      ref, 'সব উত্তর লুকানো', 'Answers Hidden'),
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
              ],
            ),
          ),

          // 4. Questions List
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : state.errorMessage != null && filteredList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.alertTriangle,
                                  size: 48, color: Colors.amber),
                              const SizedBox(height: 12),
                              Text(
                                AppStrings.t(ref, 'প্রশ্ন লোড করতে সমস্যা হয়েছে',
                                    'Failed to load questions'),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  notifier.loadInitialQuestions();
                                },
                                icon:
                                    const Icon(LucideIcons.refreshCw, size: 16),
                                label: Text(AppStrings.t(
                                    ref, 'পুনরায় চেষ্টা করুন', 'Retry')),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filteredList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.helpCircle,
                                    size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  AppStrings.t(ref, 'কোনো প্রশ্ন পাওয়া যায়নি',
                                      'No questions found'),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppStrings.t(
                                    ref,
                                    'অনুসন্ধান শব্দ বা ফিল্টার পরিবর্তন করে আবার চেষ্টা করুন।',
                                    'Try changing your search query or filters.',
                                  ),
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    notifier.setSearchQuery('');
                                    notifier.setBatch('');
                                    notifier.setSubject('');
                                    notifier.setDifficulty('all');
                                  },
                                  child: Text(AppStrings.t(
                                      ref, 'সব ফিল্টার মুছুন', 'Clear All Filters')),
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
                                  orElse: () => {
                                    'name': question.subjectId,
                                    'nameEn': question.subjectId,
                                  },
                                );
                                final subjectDisplay = isBn
                                    ? (subject['name'] as String?)
                                    : ((subject['nameEn'] as String?)
                                                ?.isNotEmpty ==
                                            true
                                        ? subject['nameEn'] as String?
                                        : subject['name'] as String?);

                                return StudyQuestionCard(
                                  key: ValueKey(question.id),
                                  question: question,
                                  index: index,
                                  subjectName: subjectDisplay,
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

  Widget _buildDifficultyFilterPill({
    required WidgetRef ref,
    required bool isDark,
    required String value,
    required String selectedValue,
    required String label,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedValue == value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.14)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? activeColor
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}
