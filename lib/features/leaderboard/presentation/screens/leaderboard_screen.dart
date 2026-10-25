import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/bengali_numeral_converter.dart';
import '../controllers/leaderboard_controller.dart';
import 'package:medhavi_mobile/features/leaderboard/domain/entities/leaderboard_entry.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderboardControllerProvider);
    final notifier = ref.read(leaderboardControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final top3 = state.entries.take(3).toList();
    final remaining = state.entries.skip(3).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          AppStrings.tr(ref, 'leaderboard_title'),
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.t(ref, 'নিয়মাবলী', 'Scoring Rules'),
            icon: const Icon(LucideIcons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    AppStrings.t(
                        ref, 'লিডারবোর্ড স্কোরিং নিয়ম', 'Leaderboard Scoring Rules'),
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    AppStrings.t(
                      ref,
                      '১. প্রতিটি সঠিক উত্তরে ১০ পয়েন্ট যোগ হয়।\n'
                      '২. ধারাবাহিক স্ট্রিকের প্রতি দিনের জন্য ২০ পয়েন্ট বোনাস।\n'
                      '৩. একদিন অনুশীলন মিস করলেই স্ট্রিক ০ হয়ে যাবে।\n'
                      '৪. ভুল প্রশ্ন পুনরায় সমাধান করলে অতিরিক্ত পয়েন্ট অর্জিত হয়।',
                      '1. Earn 10 points for every correct answer.\n'
                      '2. Earn +20 bonus points per active streak day.\n'
                      '3. Missing 1 full calendar day resets your streak to 0.\n'
                      '4. Rectifying mistakes boosts your overall mastery.',
                    ),
                    style: GoogleFonts.hindSiliguri(height: 1.5),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(AppStrings.t(ref, 'বুঝেছি', 'Got It')),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Timeframe Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _TimeframeTab(
                    label: AppStrings.tr(ref, 'tab_weekly'),
                    isSelected: state.timeframe == LeaderboardTimeframe.weekly,
                    onTap: () => notifier.setTimeframe(LeaderboardTimeframe.weekly),
                  ),
                  _TimeframeTab(
                    label: AppStrings.tr(ref, 'tab_monthly'),
                    isSelected: state.timeframe == LeaderboardTimeframe.monthly,
                    onTap: () => notifier.setTimeframe(LeaderboardTimeframe.monthly),
                  ),
                  _TimeframeTab(
                    label: AppStrings.tr(ref, 'tab_all_time'),
                    isSelected: state.timeframe == LeaderboardTimeframe.allTime,
                    onTap: () => notifier.setTimeframe(LeaderboardTimeframe.allTime),
                  ),
                ],
              ),
            ),
          ),

          // 2. Scrollable Body: Podium + Ranked List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await notifier.refresh();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Top 3 Podium
                    if (top3.length >= 3)
                      _Top3Podium(top3: top3, isDark: isDark),
                    const SizedBox(height: 16),

                    // 4th and beyond
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: remaining.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = remaining[index];
                        return _RankCard(entry: item, isDark: isDark);
                      },
                    ),
                    const SizedBox(height: 80), // Padding for sticky bottom
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 3. Pinned User Rank Bar
      bottomSheet: _UserRankStickyBar(
        entry: state.userEntry,
        isDark: isDark,
      ),
    );
  }
}

class _TimeframeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeframeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _Top3Podium extends StatelessWidget {
  final List<LeaderboardEntry> top3;
  final bool isDark;

  const _Top3Podium({required this.top3, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final first = top3[0];
    final second = top3[1];
    final third = top3[2];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), const Color(0xFFF1F5F9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Left)
          _PodiumItem(
            entry: second,
            rank: 2,
            ringColor: const Color(0xFF94A3B8), // Silver
            height: 100,
            isDark: isDark,
          ),

          // 1st Place (Center - Highest)
          _PodiumItem(
            entry: first,
            rank: 1,
            ringColor: const Color(0xFFF59E0B), // Gold
            height: 130,
            isFirst: true,
            isDark: isDark,
          ),

          // 3rd Place (Right)
          _PodiumItem(
            entry: third,
            rank: 3,
            ringColor: const Color(0xFFD97706), // Bronze
            height: 80,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final Color ringColor;
  final double height;
  final bool isFirst;
  final bool isDark;

  const _PodiumItem({
    required this.entry,
    required this.rank,
    required this.ringColor,
    required this.height,
    this.isFirst = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst)
          const Icon(LucideIcons.crown, color: Color(0xFFF59E0B), size: 24),
        const SizedBox(height: 4),

        // Avatar
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 2.5),
              ),
              child: CircleAvatar(
                radius: isFirst ? 28 : 22,
                backgroundColor: ringColor.withValues(alpha: 0.2),
                child: Text(
                  entry.name.isNotEmpty ? entry.name[0] : 'U',
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: isFirst ? 20 : 16,
                    color: ringColor,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ringColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Name
        SizedBox(
          width: 90,
          child: Text(
            entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),

        // Score
        Text(
          '${BengaliNumeralConverter.toBengaliNumber(entry.score)} pts',
          style: GoogleFonts.hindSiliguri(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),

        // Pillar block
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: ringColor.withValues(alpha: isDark ? 0.25 : 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: ringColor.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: ringColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isDark;

  const _RankCard({required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          SizedBox(
            width: 32,
            child: Text(
              '#${BengaliNumeralConverter.toBengaliNumber(entry.rank)}',
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              entry.name.isNotEmpty ? entry.name[0] : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  entry.targetBatch,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Streak & Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${BengaliNumeralConverter.toBengaliNumber(entry.score)} pts',
                style: GoogleFonts.hindSiliguri(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 2),
                  Text(
                    '${BengaliNumeralConverter.toBengaliNumber(entry.streakDays)} দিন',
                    style: const TextStyle(fontSize: 10, color: Colors.orange),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserRankStickyBar extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isDark;

  const _UserRankStickyBar({required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode != 'en';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isBn
                    ? '#${BengaliNumeralConverter.toBengaliNumber(entry.rank)}'
                    : '#${entry.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'আপনার বর্তমান র‍্যাংক' : 'Your Current Rank',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    entry.name,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isBn
                      ? '${BengaliNumeralConverter.toBengaliNumber(entry.score)} pts'
                      : '${entry.score} pts',
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  isBn
                      ? '🔥 ${BengaliNumeralConverter.toBengaliNumber(entry.streakDays)} দিন স্ট্রিক'
                      : '🔥 ${entry.streakDays}d Streak',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
