import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isSearchOpen = false;
  bool _isCompactView = false;

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

  int _calculateActiveFilters(QuestionBankState state) {
    int count = 0;
    if (state.selectedBatchTag.isNotEmpty) count++;
    if (state.selectedSubjectId.isNotEmpty) count++;
    if (state.selectedDifficulty != 'all') count++;
    if (state.searchQuery.isNotEmpty) count++;
    return count;
  }

  void _openFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(questionBankControllerProvider);
            final notifier = ref.read(questionBankControllerProvider.notifier);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final isBn = AppStrings.isBn(ref);

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.92,
              minChildSize: 0.45,
              builder: (_, sheetScrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.slidersHorizontal,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.t(ref, 'ফিল্টার ও বাছাই', 'Filter Questions'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (_calculateActiveFilters(state) > 0)
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    notifier.resetAllFilters();
                                    Navigator.pop(ctx);
                                  },
                                  child: Text(
                                    AppStrings.t(ref, 'রিসেট', 'Reset'),
                                    style: const TextStyle(color: AppColors.error),
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(LucideIcons.x, size: 20),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        controller: sheetScrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        children: [
                          // 1. BCS Batch Section
                          Text(
                            AppStrings.t(ref, 'বিসিএস ব্যাচ (১০ম - ৫০তম)', 'BCS Batch (10th - 50th)'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: kBcsBatches.take(15).map((batch) {
                              final isSelected = batch['id'] == state.selectedBatchTag;
                              final label = isBn
                                  ? (batch['labelBn'] ?? batch['label']!)
                                  : (batch['labelEn'] ?? batch['label']!);
                              return ChoiceChip(
                                selected: isSelected,
                                label: Text(label, style: const TextStyle(fontSize: 12)),
                                onSelected: (_) {
                                  notifier.setBatch(batch['id']!);
                                },
                              );
                            }).toList(),
                          ),
                          if (kBcsBatches.length > 15) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                _openBatchFullSelector(context, state.selectedBatchTag, isBn);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      AppStrings.t(ref, 'সব ৪১টি বিসিএস ব্যাচ দেখুন ➔', 'View all 41 BCS Batches ➔'),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          // 2. Difficulty Section
                          Text(
                            AppStrings.t(ref, 'কঠিনতার মান', 'Difficulty Level'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildModalDifficultyChip(
                                ref: ref,
                                label: AppStrings.t(ref, 'সব মান', 'All Levels'),
                                value: 'all',
                                isSelected: state.selectedDifficulty == 'all',
                                color: AppColors.primary,
                                onSelected: () => notifier.setDifficulty('all'),
                              ),
                              const SizedBox(width: 8),
                              _buildModalDifficultyChip(
                                ref: ref,
                                label: AppStrings.t(ref, 'সহজ', 'Easy'),
                                value: 'easy',
                                isSelected: state.selectedDifficulty == 'easy',
                                color: AppColors.success,
                                onSelected: () => notifier.setDifficulty('easy'),
                              ),
                              const SizedBox(width: 8),
                              _buildModalDifficultyChip(
                                ref: ref,
                                label: AppStrings.t(ref, 'মধ্যম', 'Medium'),
                                value: 'medium',
                                isSelected: state.selectedDifficulty == 'medium',
                                color: AppColors.warning,
                                onSelected: () => notifier.setDifficulty('medium'),
                              ),
                              const SizedBox(width: 8),
                              _buildModalDifficultyChip(
                                ref: ref,
                                label: AppStrings.t(ref, 'কঠিন', 'Hard'),
                                value: 'hard',
                                isSelected: state.selectedDifficulty == 'hard',
                                color: AppColors.error,
                                onSelected: () => notifier.setDifficulty('hard'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 3. Subject Section
                          Text(
                            AppStrings.t(ref, 'বিষয়ভিত্তিক বাছাই', 'Subjects'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                selected: state.selectedSubjectId.isEmpty,
                                label: Text(
                                  AppStrings.t(ref, 'সব বিষয়', 'All Subjects'),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onSelected: (_) => notifier.setSubject(''),
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
                                return ChoiceChip(
                                  selected: isSelected,
                                  label: Text(
                                    count > 0 ? '$subName ($count)' : subName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onSelected: (_) => notifier.setSubject(subId),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    // Bottom Apply Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            state.totalMatchingCount > 0
                                ? '${AppStrings.t(ref, 'প্রয়োগ করুন', 'Apply')} (${AppStrings.num(ref, state.totalMatchingCount)}টি প্রশ্ন)'
                                : AppStrings.t(ref, 'প্রয়োগ করুন', 'Apply Filters'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _openBatchFullSelector(BuildContext context, String currentTag, bool isBn) {
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
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          minChildSize: 0.45,
          builder: (_, controller) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
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
                        isBn ? 'বিসিএস ব্যাচ নির্বাচন করুন' : 'Select BCS Batch',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(LucideIcons.check, color: AppColors.primary, size: 18)
                            : null,
                        onTap: () {
                          ref.read(questionBankControllerProvider.notifier).setBatch(batch['id']!);
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

  Widget _buildModalDifficultyChip({
    required WidgetRef ref,
    required String label,
    required String value,
    required bool isSelected,
    required Color color,
    required VoidCallback onSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionBankControllerProvider);
    final notifier = ref.read(questionBankControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = AppStrings.isBn(ref);

    final filteredList = state.filteredQuestions;
    final activeFiltersCount = _calculateActiveFilters(state);

    // Current batch label
    final currentBatch = kBcsBatches.firstWhere(
      (b) => b['id'] == state.selectedBatchTag,
      orElse: () => kBcsBatches.first,
    );
    final currentBatchLabel = isBn
        ? (currentBatch['labelBn'] ?? currentBatch['label']!)
        : (currentBatch['labelEn'] ?? currentBatch['label']!);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AutoHideAppBar(
        child: AppBar(
          elevation: 0,
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          titleSpacing: 16,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.bookOpen, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.t(ref, 'প্রশ্ন ব্যাংক', 'Question Bank'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              if (state.totalMatchingCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    AppStrings.num(ref, state.totalMatchingCount),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            // Search Toggle Icon
            IconButton(
              tooltip: AppStrings.t(ref, 'অনুসন্ধান', 'Search'),
              icon: Icon(
                _isSearchOpen ? LucideIcons.searchX : LucideIcons.search,
                size: 20,
                color: _isSearchOpen || state.searchQuery.isNotEmpty
                    ? AppColors.primary
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              onPressed: () {
                setState(() {
                  _isSearchOpen = !_isSearchOpen;
                  if (!_isSearchOpen && state.searchQuery.isNotEmpty) {
                    _searchController.clear();
                    notifier.setSearchQuery('');
                  }
                });
              },
            ),

            // Density View Toggle Icon (Compact vs Detailed)
            IconButton(
              tooltip: _isCompactView
                  ? AppStrings.t(ref, 'বিস্তারিত ভিউ', 'Detailed View')
                  : AppStrings.t(ref, 'কমপ্যাক্ট ভিউ', 'Compact View'),
              icon: Icon(
                _isCompactView ? LucideIcons.layoutList : LucideIcons.rows,
                size: 20,
                color: _isCompactView
                    ? AppColors.primary
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _isCompactView = !_isCompactView);
              },
            ),

            // Auto Reveal Eye Toggle Icon
            IconButton(
              tooltip: state.autoRevealAll
                  ? AppStrings.t(ref, 'সব উত্তর দৃশ্যমান', 'Answers Visible')
                  : AppStrings.t(ref, 'সব উত্তর লুকানো', 'Answers Hidden'),
              icon: Icon(
                state.autoRevealAll ? LucideIcons.eye : LucideIcons.eyeOff,
                size: 20,
                color: state.autoRevealAll
                    ? AppColors.primary
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
              onPressed: notifier.toggleAutoRevealAll,
            ),

            // Filter Button with Badge
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: AppStrings.t(ref, 'ফিল্টার', 'Filters'),
                  icon: Icon(
                    LucideIcons.slidersHorizontal,
                    size: 20,
                    color: activeFiltersCount > 0
                        ? AppColors.primary
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  onPressed: () => _openFilterBottomSheet(context),
                ),
                if (activeFiltersCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$activeFiltersCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Slim Animated Search Bar (only appears when search icon tapped)
          if (_isSearchOpen)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              color: isDark ? AppColors.cardDark : Colors.white,
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: notifier.setSearchQuery,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: AppStrings.t(
                      ref,
                      'প্রশ্ন বা টপিক দিয়ে খুঁজুন...',
                      'Search question text or topic...',
                    ),
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    prefixIcon: const Icon(LucideIcons.search, size: 16, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 14),
                            onPressed: () {
                              _searchController.clear();
                              notifier.setSearchQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    filled: true,
                    fillColor: isDark ? AppColors.backgroundDark : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

          // 2. Single Slim 38px Quick-Filter Strip
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  width: 0.8,
                ),
              ),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                // Batch Chip (e.g. "৫০তম বিসিএস ▾" or "সব ব্যাচ ▾")
                InkWell(
                  onTap: () => _openBatchFullSelector(context, state.selectedBatchTag, isBn),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: state.selectedBatchTag.isNotEmpty
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: state.selectedBatchTag.isNotEmpty
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 13,
                          color: state.selectedBatchTag.isNotEmpty
                              ? AppColors.primary
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentBatchLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: state.selectedBatchTag.isNotEmpty
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: state.selectedBatchTag.isNotEmpty
                                ? AppColors.primary
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          LucideIcons.chevronDown,
                          size: 13,
                          color: state.selectedBatchTag.isNotEmpty
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                // Reset Chip (only if filters are active)
                if (activeFiltersCount > 0)
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      notifier.resetAllFilters();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.rotateCcw, size: 12, color: AppColors.error),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.t(ref, 'রিসেট', 'Reset'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // All Subjects Chip
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: state.selectedSubjectId.isEmpty,
                    label: Text(
                      AppStrings.t(ref, 'সব বিষয়', 'All Subjects'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    onSelected: (_) => notifier.setSubject(''),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),

                // Horizontal Subject Pills
                ...state.subjects.map((sub) {
                  final subId = sub['id'] as String? ?? '';
                  final isSelected = state.selectedSubjectId == subId;
                  final subName = isBn
                      ? (sub['name'] as String? ?? '')
                      : ((sub['nameEn'] as String?)?.isNotEmpty == true
                          ? sub['nameEn'] as String
                          : (sub['name'] as String? ?? ''));
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(subName, style: const TextStyle(fontSize: 12)),
                      onSelected: (_) => notifier.setSubject(subId),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
              ],
            ),
          ),

          // 3. Question Feed with Pull-to-Refresh
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await notifier.loadInitialQuestions();
              },
              child: state.isLoading && filteredList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.errorMessage != null && filteredList.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24.0),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.55,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(LucideIcons.alertTriangle,
                                        size: 40, color: Colors.amber),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppStrings.t(
                                          ref,
                                          'প্রশ্ন লোড করতে সমস্যা হয়েছে',
                                          'Failed to load questions'),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      state.errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: notifier.loadInitialQuestions,
                                      icon: const Icon(LucideIcons.refreshCw,
                                          size: 16),
                                      label: Text(AppStrings.t(
                                          ref, 'পুনরায় চেষ্টা করুন', 'Retry')),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : filteredList.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(32.0),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.55,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white10
                                                : const Color(0xFFF1F5F9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(LucideIcons.searchX,
                                              size: 36, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          AppStrings.t(
                                              ref,
                                              'কোনো প্রশ্ন পাওয়া যায়নি',
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
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            notifier.resetAllFilters();
                                          },
                                          child: Text(AppStrings.t(ref,
                                              'সব ফিল্টার মুছুন',
                                              'Clear Filters')),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: _scrollController,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 80),
                              itemCount: filteredList.length +
                                  (state.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == filteredList.length) {
                                  return const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  );
                                }

                                final question = filteredList[index];
                                final isBookmarked =
                                    state.bookmarkedIds.contains(question.id);
                                final recordedAnswer =
                                    state.userAnswers[question.id];

                                return StudyQuestionCard(
                                  key: ValueKey(question.id),
                                  index: index,
                                  question: question,
                                  isBookmarked: isBookmarked,
                                  defaultRevealed: state.autoRevealAll,
                                  initialSelectedOptionId: recordedAnswer,
                                  onAnswerSelect: (optId) {
                                    notifier.recordAnswer(question.id, optId);
                                  },
                                  onToggleBookmark: () async {
                                    await notifier.toggleBookmark(question.id);
                                  },
                                  isCompact: _isCompactView,
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
