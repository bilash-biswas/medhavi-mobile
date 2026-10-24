import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medhavi_mobile/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:medhavi_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:medhavi_mobile/features/analytics/presentation/controllers/analytics_controller.dart';

enum LeaderboardTimeframe { weekly, monthly, allTime }

class LeaderboardState {
  final LeaderboardTimeframe timeframe;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry userEntry;
  final bool isLoading;

  const LeaderboardState({
    required this.timeframe,
    required this.entries,
    required this.userEntry,
    this.isLoading = false,
  });

  LeaderboardState copyWith({
    LeaderboardTimeframe? timeframe,
    List<LeaderboardEntry>? entries,
    LeaderboardEntry? userEntry,
    bool? isLoading,
  }) {
    return LeaderboardState(
      timeframe: timeframe ?? this.timeframe,
      entries: entries ?? this.entries,
      userEntry: userEntry ?? this.userEntry,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LeaderboardController extends Notifier<LeaderboardState> {
  @override
  LeaderboardState build() {
    final user = ref.watch(currentUserProvider);
    final analytics = ref.watch(analyticsControllerProvider);
    final userName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : 'আপনি (You)';

    final realSolved = analytics.totalSolved;
    final realScore =
        (analytics.totalCorrect * 10) + (analytics.streakDays * 20);
    final baseEntries = _getEntriesFor(LeaderboardTimeframe.weekly);
    int computedRank = baseEntries.length + 1;
    for (int i = 0; i < baseEntries.length; i++) {
      if (realScore >= baseEntries[i].score) {
        computedRank = i + 1;
        break;
      }
    }

    return LeaderboardState(
      timeframe: LeaderboardTimeframe.weekly,
      entries: baseEntries,
      userEntry: LeaderboardEntry(
        rank: computedRank,
        userId: user?.uid ?? 'current_user',
        name: userName,
        targetBatch: '৪৭তম বিসিএস ক্যাডার',
        solvedCount: realSolved,
        score: realScore,
        streakDays: analytics.streakDays,
        isCurrentUser: true,
      ),
    );
  }

  void setTimeframe(LeaderboardTimeframe timeframe) {
    state = state.copyWith(
      timeframe: timeframe,
      entries: _getEntriesFor(timeframe),
    );
  }

  List<LeaderboardEntry> _getEntriesFor(LeaderboardTimeframe timeframe) {
    switch (timeframe) {
      case LeaderboardTimeframe.weekly:
        return const [
          LeaderboardEntry(
            rank: 1,
            userId: 'u1',
            name: 'আরিফুল ইসলাম',
            targetBatch: '৪৭তম বিসিএস (প্রশাসন)',
            solvedCount: 520,
            score: 5200,
            streakDays: 14,
          ),
          LeaderboardEntry(
            rank: 2,
            userId: 'u2',
            name: 'তানজিলা রহমান',
            targetBatch: '৪৭তম বিসিএস (পররাষ্ট্র)',
            solvedCount: 495,
            score: 4950,
            streakDays: 12,
          ),
          LeaderboardEntry(
            rank: 3,
            userId: 'u3',
            name: 'সোহাগ মাহমুদ',
            targetBatch: '৪৮তম বিসিএস (পুলিশ)',
            solvedCount: 460,
            score: 4600,
            streakDays: 9,
          ),
          LeaderboardEntry(
            rank: 4,
            userId: 'u4',
            name: 'ফারজানা ইয়াসমিন',
            targetBatch: '৪৭তম বিসিএস (সাধারণ)',
            solvedCount: 430,
            score: 4300,
            streakDays: 11,
          ),
          LeaderboardEntry(
            rank: 5,
            userId: 'u5',
            name: 'মেহেদী হাসান',
            targetBatch: '৪৭তম বিসিএস (কর)',
            solvedCount: 410,
            score: 4100,
            streakDays: 8,
          ),
          LeaderboardEntry(
            rank: 6,
            userId: 'u6',
            name: 'নুসরাত জাহান',
            targetBatch: '৪৮তম বিসিএস (শিক্ষা)',
            solvedCount: 395,
            score: 3950,
            streakDays: 6,
          ),
        ];
      case LeaderboardTimeframe.monthly:
        return const [
          LeaderboardEntry(
            rank: 1,
            userId: 'u2',
            name: 'তানজিলা রহমান',
            targetBatch: '৪৭তম বিসিএস (পররাষ্ট্র)',
            solvedCount: 1840,
            score: 18400,
            streakDays: 28,
          ),
          LeaderboardEntry(
            rank: 2,
            userId: 'u1',
            name: 'আরিফুল ইসলাম',
            targetBatch: '৪৭তম বিসিএস (প্রশাসন)',
            solvedCount: 1790,
            score: 17900,
            streakDays: 25,
          ),
          LeaderboardEntry(
            rank: 3,
            userId: 'u7',
            name: 'কামরুল হাসান',
            targetBatch: '৪৭তম বিসিএস (কাস্টমস)',
            solvedCount: 1620,
            score: 16200,
            streakDays: 21,
          ),
        ];
      case LeaderboardTimeframe.allTime:
        return const [
          LeaderboardEntry(
            rank: 1,
            userId: 'u8',
            name: 'বিসিএস মাস্টার',
            targetBatch: '৪৬তম বিসিএস উত্তীর্ণ',
            solvedCount: 5420,
            score: 54200,
            streakDays: 65,
          ),
          LeaderboardEntry(
            rank: 2,
            userId: 'u1',
            name: 'আরিফুল ইসলাম',
            targetBatch: '৪৭তম বিসিএস (প্রশাসন)',
            solvedCount: 4980,
            score: 49800,
            streakDays: 52,
          ),
          LeaderboardEntry(
            rank: 3,
            userId: 'u2',
            name: 'তানজিলা রহমান',
            targetBatch: '৪৭তম বিসিএস (পররাষ্ট্র)',
            solvedCount: 4760,
            score: 47600,
            streakDays: 48,
          ),
        ];
    }
  }
}

final leaderboardControllerProvider =
    NotifierProvider<LeaderboardController, LeaderboardState>(
        LeaderboardController.new);
