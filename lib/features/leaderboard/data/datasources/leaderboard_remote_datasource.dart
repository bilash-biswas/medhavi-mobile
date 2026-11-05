import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medhavi_mobile/features/leaderboard/domain/entities/leaderboard_entry.dart';

enum LeaderboardTimeframe { weekly, monthly, allTime }

final leaderboardRemoteDataSourceProvider =
    Provider<LeaderboardRemoteDataSource>((ref) {
  return LeaderboardRemoteDataSourceImpl(FirebaseFirestore.instance);
});

abstract class LeaderboardRemoteDataSource {
  Future<List<LeaderboardEntry>> getLeaderboard({
    required LeaderboardTimeframe timeframe,
    String? currentUserId,
    String? currentUserName,
  });

  Future<void> recordScore({
    required String userId,
    required String displayName,
    required int scoreToAdd,
    required int questionsAttempted,
    int? streakDays,
    String? targetBatch,
  });
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final FirebaseFirestore _firestore;

  LeaderboardRemoteDataSourceImpl(this._firestore);

  /// Standard ISO 8601 week key (e.g. "2026-W45") matching Web
  static String getWeeklyPeriodKey([DateTime? d]) {
    final date = d ?? DateTime.now();
    final utc = DateTime.utc(date.year, date.month, date.day);
    final dayNum = utc.weekday; // 1 (Mon) - 7 (Sun)
    final thursday = utc.add(Duration(days: 4 - dayNum));
    final yearStart = DateTime.utc(thursday.year, 1, 1);
    final weekNo = ((thursday.difference(yearStart).inDays) / 7).floor() + 1;
    return '${thursday.year}-W${weekNo.toString().padLeft(2, '0')}';
  }

  /// Month key (e.g. "2026-11")
  static String getMonthlyPeriodKey([DateTime? d]) {
    final date = d ?? DateTime.now();
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Date key (e.g. "2026-11-05")
  static String getDailyPeriodKey([DateTime? d]) {
    final date = d ?? DateTime.now();
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({
    required LeaderboardTimeframe timeframe,
    String? currentUserId,
    String? currentUserName,
  }) async {
    String period;
    String periodKey;

    switch (timeframe) {
      case LeaderboardTimeframe.weekly:
        period = 'weekly';
        periodKey = getWeeklyPeriodKey();
        break;
      case LeaderboardTimeframe.monthly:
        period = 'monthly';
        periodKey = getMonthlyPeriodKey();
        break;
      case LeaderboardTimeframe.allTime:
        period = 'allTime';
        periodKey = 'all';
        break;
    }

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await _firestore
            .collection('leaderboardScores')
            .where('period', isEqualTo: period)
            .where('periodKey', isEqualTo: periodKey)
            .orderBy('score', descending: true)
            .limit(30)
            .get();
      } catch (indexError) {
        debugPrint('Index not ready, running fallback query for leaderboard: $indexError');
        snapshot = await _firestore
            .collection('leaderboardScores')
            .where('period', isEqualTo: period)
            .where('periodKey', isEqualTo: periodKey)
            .limit(50)
            .get();
      }

      final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snapshot.docs);
      // Sort in memory by score desc
      docs.sort((a, b) {
        final sA = (a.data()['score'] as num?)?.toInt() ?? 0;
        final sB = (b.data()['score'] as num?)?.toInt() ?? 0;
        return sB.compareTo(sA);
      });

      final entries = <LeaderboardEntry>[];
      for (int i = 0; i < docs.length; i++) {
        final data = docs[i].data();
        final uid = data['userId']?.toString() ?? docs[i].id;
        final isMe = uid == currentUserId;

        var name = (data['displayName'] as String?)?.trim();
        if (name == null || name.isEmpty || name == 'Candidate') {
          name = isMe && currentUserName != null && currentUserName.isNotEmpty
              ? currentUserName
              : 'বিসিএস পরীক্ষার্থী';
        }

        final score = (data['score'] as num?)?.toInt() ?? 0;
        final solved = (data['questionsAttempted'] as num?)?.toInt() ?? 0;
        final streak = (data['streakDays'] as num?)?.toInt() ?? 0;
        final targetBatch = (data['targetBatch'] as String?) ?? '৪৭তম বিসিএস ক্যাডার';

        entries.add(
          LeaderboardEntry(
            rank: i + 1,
            userId: uid,
            name: name,
            targetBatch: targetBatch,
            solvedCount: solved,
            score: score,
            streakDays: streak,
            isCurrentUser: isMe,
          ),
        );
      }

      return entries;
    } catch (e) {
      debugPrint('Notice: Error loading leaderboard from Firestore: $e');
      return [];
    }
  }

  @override
  Future<void> recordScore({
    required String userId,
    required String displayName,
    required int scoreToAdd,
    required int questionsAttempted,
    int? streakDays,
    String? targetBatch,
  }) async {
    if (userId.isEmpty) return;

    final now = DateTime.now();
    final today = getDailyPeriodKey(now);
    final week = getWeeklyPeriodKey(now);
    final month = getMonthlyPeriodKey(now);

    final entries = [
      {'period': 'daily', 'periodKey': today, 'id': 'daily_${today}_$userId'},
      {'period': 'weekly', 'periodKey': week, 'id': 'weekly_${week}_$userId'},
      {'period': 'monthly', 'periodKey': month, 'id': 'monthly_${month}_$userId'},
      {'period': 'allTime', 'periodKey': 'all', 'id': 'allTime_all_$userId'},
    ];

    try {
      final batch = _firestore.batch();
      for (final e in entries) {
        final docRef =
            _firestore.collection('leaderboardScores').doc(e['id'] as String);
        final mapData = <String, dynamic>{
          'userId': userId,
          'displayName': displayName.isNotEmpty ? displayName : 'প্রার্থী',
          'period': e['period'],
          'periodKey': e['periodKey'],
          'score': FieldValue.increment(scoreToAdd),
          'questionsAttempted': FieldValue.increment(questionsAttempted),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (streakDays != null && streakDays > 0) {
          mapData['streakDays'] = streakDays;
        }
        if (targetBatch != null && targetBatch.isNotEmpty) {
          mapData['targetBatch'] = targetBatch;
        }

        batch.set(docRef, mapData, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Notice: Error recording leaderboard score: $e');
    }
  }
}
