import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medhavi_mobile/features/question_bank/domain/entities/question_entity.dart';

final dailyChallengeRemoteDataSourceProvider =
    Provider<DailyChallengeRemoteDataSource>((ref) {
  return DailyChallengeRemoteDataSourceImpl(FirebaseFirestore.instance);
});

abstract class DailyChallengeRemoteDataSource {
  Future<List<QuestionEntity>> getTodayDailyQuestions(String dateStr);
  Future<bool> hasUserCompletedDailyToday(String userId, String dateStr);
  Future<Map<String, dynamic>> recordDailyAttempt({
    required String userId,
    required String dateStr,
    required int score,
    required int totalQuestions,
    required int durationSeconds,
    required List<Map<String, dynamic>> answers,
  });
}

class DailyChallengeRemoteDataSourceImpl
    implements DailyChallengeRemoteDataSource {
  final FirebaseFirestore _firestore;

  DailyChallengeRemoteDataSourceImpl(this._firestore);

  /// Deterministic hash matching Web implementation
  int _getDateSeed(String dateStr) {
    int hash = 0;
    for (int i = 0; i < dateStr.length; i++) {
      hash = (hash << 5) - hash + dateStr.codeUnitAt(i);
      hash |= 0;
    }
    return hash.abs();
  }

  /// 5 Core BPSC Subject Pillars matching Web
  List<String> _getDailySubjectPillars(String dateStr) {
    final seed = _getDateSeed(dateStr);
    final p1 = seed % 2 == 0 ? 'sub_bcs_bangla' : 'sub_bcs_english';
    final p2 = 'sub_bcs_bd_affairs';
    final p3 = (seed >> 2) % 2 == 0 ? 'sub_bcs_intl_affairs' : 'sub_bcs_geography';
    final p4 = (seed >> 4) % 2 == 0 ? 'sub_bcs_math' : 'sub_bcs_science';

    const appliedPool = [
      'sub_bcs_ict',
      'sub_bcs_mental_ability',
      'sub_bcs_ethics',
    ];
    final p5 = appliedPool[(seed >> 6) % appliedPool.length];

    return [p1, p2, p3, p4, p5];
  }

  @override
  Future<List<QuestionEntity>> getTodayDailyQuestions(String dateStr) async {
    final challengeDocRef = _firestore.collection('daily_challenges').doc(dateStr);
    final docSnap = await challengeDocRef.get();

    // 1. If daily challenge already exists in Firestore (created on web or by earlier candidate)
    if (docSnap.exists && docSnap.data() != null) {
      final data = docSnap.data()!;
      final questionIds = (data['questionIds'] as List<dynamic>? ?? [])
          .map((id) => id.toString())
          .toList();

      if (questionIds.isNotEmpty) {
        final fetched = <QuestionEntity>[];
        for (final qId in questionIds) {
          try {
            final qDoc = await _firestore.collection('questions').doc(qId).get();
            if (qDoc.exists && qDoc.data() != null) {
              fetched.add(QuestionEntity.fromFirestore(qDoc.id, qDoc.data()!));
            }
          } catch (_) {
            // ignore individual doc errors
          }
        }
        if (fetched.isNotEmpty) {
          return fetched;
        }
      }
    }

    // 2. Generate deterministically across 5 pillars
    final pillars = _getDailySubjectPillars(dateStr);
    final seed = _getDateSeed(dateStr);
    final selectedQuestions = <QuestionEntity>[];

    for (int i = 0; i < pillars.length; i++) {
      final subjectId = pillars[i];
      try {
        final snap = await _firestore
            .collection('questions')
            .where('status', isEqualTo: 'published')
            .where('subjectId', isEqualTo: subjectId)
            .limit(25)
            .get();

        if (snap.docs.isEmpty) continue;

        final docs = snap.docs
            .map((d) => QuestionEntity.fromFirestore(d.id, d.data()))
            .toList();

        final verified = docs.where((q) => q.adminVerified).toList();
        final pool = verified.isNotEmpty ? verified : docs;

        final pickIndex = (seed + i * 13) % pool.length;
        selectedQuestions.add(pool[pickIndex]);
      } catch (err) {
        // Fallback gracefully
      }
    }

    // Fallback if less than 5 questions
    if (selectedQuestions.length < 5) {
      try {
        final fallbackSnap = await _firestore
            .collection('questions')
            .where('status', isEqualTo: 'published')
            .limit(15)
            .get();

        final existingIds = selectedQuestions.map((q) => q.id).toSet();
        for (final d in fallbackSnap.docs) {
          if (!existingIds.contains(d.id)) {
            selectedQuestions.add(QuestionEntity.fromFirestore(d.id, d.data()));
            if (selectedQuestions.length >= 5) break;
          }
        }
      } catch (_) {}
    }

    // Save to Firestore daily_challenges collection for other candidates (and web sync)
    if (selectedQuestions.isNotEmpty) {
      try {
        await challengeDocRef.set({
          'id': dateStr,
          'date': dateStr,
          'questionIds': selectedQuestions.map((q) => q.id).toList(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        // non-blocking if offline/permission
      }
    }

    return selectedQuestions;
  }

  @override
  Future<bool> hasUserCompletedDailyToday(String userId, String dateStr) async {
    try {
      final snap = await _firestore
          .collection('attempts')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'daily')
          .where('date', isEqualTo: dateStr)
          .limit(1)
          .get();

      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> recordDailyAttempt({
    required String userId,
    required String dateStr,
    required int score,
    required int totalQuestions,
    required int durationSeconds,
    required List<Map<String, dynamic>> answers,
  }) async {
    // 1. Record Attempt in Firestore
    final attemptRef = _firestore.collection('attempts').doc();
    await attemptRef.set({
      'userId': userId,
      'type': 'daily',
      'date': dateStr,
      'score': score,
      'totalQuestions': totalQuestions,
      'durationSeconds': durationSeconds,
      'answers': answers,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Update Streak on users/{uid}
    int newStreak = 1;
    int longestStreak = 1;

    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userSnap = await userRef.get();
      final userData = userSnap.data() ?? {};

      final storedCurrent = (userData['currentStreak'] as num?)?.toInt() ?? 0;
      final storedLongest = (userData['longestStreak'] as num?)?.toInt() ?? 0;
      final lastPracticeDate = userData['lastPracticeDate'] as String?;

      if (lastPracticeDate != null && lastPracticeDate.trim().isNotEmpty) {
        if (lastPracticeDate.trim() == dateStr) {
          newStreak = storedCurrent < 1 ? 1 : storedCurrent;
        } else {
          final parsedLast = DateTime.tryParse('${lastPracticeDate.trim()}T00:00:00Z');
          final todayParsed = DateTime.tryParse('${dateStr.trim()}T00:00:00Z');
          if (parsedLast != null && todayParsed != null) {
            final diffDays = todayParsed.difference(parsedLast).inDays;
            if (diffDays == 1) {
              newStreak = storedCurrent + 1;
            } else {
              newStreak = 1;
            }
          }
        }
      }

      longestStreak = newStreak > storedLongest ? newStreak : storedLongest;

      await userRef.set({
        'currentStreak': newStreak,
        'longestStreak': longestStreak,
        'lastPracticeDate': dateStr,
        'lastActiveDate': dateStr,
        'totalDailyCompleted': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (_) {
      // non-blocking
    }

    return {
      'attemptId': attemptRef.id,
      'currentStreak': newStreak,
      'longestStreak': longestStreak,
    };
  }
}
