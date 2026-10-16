class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final String targetBatch;
  final int solvedCount;
  final int score;
  final int streakDays;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.targetBatch,
    required this.solvedCount,
    required this.score,
    required this.streakDays,
    this.isCurrentUser = false,
  });
}
