import 'package:cloud_firestore/cloud_firestore.dart';

abstract class MistakesRemoteDataSource {
  Future<List<String>> getMistakeQuestionIds(String uid);
  Future<void> removeMistake(String uid, String questionId);
}

class MistakesRemoteDataSourceImpl implements MistakesRemoteDataSource {
  final FirebaseFirestore _firestore;

  MistakesRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<String>> getMistakeQuestionIds(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('questionStats')
        .get();

    final List<Map<String, dynamic>> mistakes = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final incorrectCount = (data['incorrectCount'] as num?)?.toInt() ?? 0;
      final isCorrect = data['isCorrect'] as bool?;

      if (incorrectCount > 0 || isCorrect == false) {
        mistakes.add({
          'id': doc.id,
          'lastAttemptedAt': data['lastAttemptedAt'],
        });
      }
    }

    // Sort newest attempted first
    mistakes.sort((a, b) {
      final aTime = a['lastAttemptedAt'];
      final bTime = b['lastAttemptedAt'];
      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }
      return 0;
    });

    return mistakes.map((m) => m['id'] as String).toList();
  }

  @override
  Future<void> removeMistake(String uid, String questionId) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('questionStats')
        .doc(questionId);

    // Mark as resolved / cleared
    await docRef.set({
      'incorrectCount': 0,
      'isCorrect': true,
      'resolvedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
