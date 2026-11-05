import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medhavi_mobile/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:medhavi_mobile/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:medhavi_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:medhavi_mobile/features/analytics/presentation/controllers/analytics_controller.dart';

export 'package:medhavi_mobile/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart'
    show LeaderboardTimeframe;

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
  LeaderboardRemoteDataSource get _dataSource =>
      ref.read(leaderboardRemoteDataSourceProvider);

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

    final initialUserEntry = LeaderboardEntry(
      rank: 1,
      userId: user?.uid ?? 'current_user',
      name: userName,
      targetBatch: '৪৭তম বিসিএস ক্যাডার',
      solvedCount: realSolved,
      score: realScore,
      streakDays: analytics.streakDays,
      isCurrentUser: true,
    );

    Future.microtask(() => loadLeaderboard());

    return LeaderboardState(
      timeframe: LeaderboardTimeframe.weekly,
      entries: const [],
      userEntry: initialUserEntry,
      isLoading: true,
    );
  }

  Future<void> loadLeaderboard() async {
    state = state.copyWith(isLoading: true);
    final user = ref.read(currentUserProvider);
    final analytics = ref.read(analyticsControllerProvider);
    final userName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : 'আপনি (You)';

    final realSolved = analytics.totalSolved;
    final realScore =
        (analytics.totalCorrect * 10) + (analytics.streakDays * 20);

    try {
      final realEntries = await _dataSource.getLeaderboard(
        timeframe: state.timeframe,
        currentUserId: user?.uid,
        currentUserName: userName,
      );

      LeaderboardEntry? resolvedUserEntry;
      for (final e in realEntries) {
        if (e.isCurrentUser || (user != null && e.userId == user.uid)) {
          resolvedUserEntry = e;
          break;
        }
      }

      if (resolvedUserEntry == null) {
        int computedRank = realEntries.length + 1;
        for (int i = 0; i < realEntries.length; i++) {
          if (realScore > realEntries[i].score) {
            computedRank = i + 1;
            break;
          }
        }

        resolvedUserEntry = LeaderboardEntry(
          rank: computedRank,
          userId: user?.uid ?? 'current_user',
          name: userName,
          targetBatch: '৪৭তম বিসিএস ক্যাডার',
          solvedCount: realSolved,
          score: realScore,
          streakDays: analytics.streakDays,
          isCurrentUser: true,
        );
      }

      state = state.copyWith(
        entries: realEntries,
        userEntry: resolvedUserEntry,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setTimeframe(LeaderboardTimeframe timeframe) {
    if (state.timeframe == timeframe) return;
    state = state.copyWith(timeframe: timeframe);
    loadLeaderboard();
  }

  /// Pull-to-refresh handler: refreshes user analytics and real leaderboard from Firestore
  Future<void> refresh() async {
    await ref.read(analyticsControllerProvider.notifier).refreshStats();
    await loadLeaderboard();
  }
}

final leaderboardControllerProvider =
    NotifierProvider<LeaderboardController, LeaderboardState>(
  LeaderboardController.new,
);
