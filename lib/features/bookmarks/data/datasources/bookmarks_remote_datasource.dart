import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BookmarksRemoteDataSource {
  Future<Set<String>> getBookmarkIds(String uid);
  Future<Map<String, String>> getUserRecordedAnswers(String uid);
  Future<bool> toggleBookmark(String uid, String questionId);
  Future<void> saveBookmarkAnswer(String uid, String questionId, String optionId);
}

class BookmarksRemoteDataSourceImpl implements BookmarksRemoteDataSource {
  final FirebaseFirestore _firestore;

  BookmarksRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Set<String>> getBookmarkIds(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .get();

    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  @override
  Future<Map<String, String>> getUserRecordedAnswers(String uid) async {
    final Map<String, String> answers = {};

    // 1. Fetch from questionStats (where practice/exam recorded responses are saved)
    final statsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('questionStats')
        .get();

    for (final doc in statsSnapshot.docs) {
      final data = doc.data();
      final selected = data['selectedOptionId'] as String?;
      if (selected != null && selected.isNotEmpty) {
        answers[doc.id] = selected;
      }
    }

    // 2. Fetch from bookmarks (where quick card answers are saved)
    final bookmarksSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .get();

    for (final doc in bookmarksSnapshot.docs) {
      final data = doc.data();
      final selected = data['selectedOptionId'] as String?;
      if (selected != null && selected.isNotEmpty) {
        answers[doc.id] = selected;
      }
    }

    return answers;
  }

  @override
  Future<bool> toggleBookmark(String uid, String questionId) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(questionId);

    final docSnap = await docRef.get();
    if (docSnap.exists) {
      await docRef.delete();
      return false; // unbookmarked
    } else {
      await docRef.set({
        'questionId': questionId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true; // bookmarked
    }
  }

  @override
  Future<void> saveBookmarkAnswer(String uid, String questionId, String optionId) async {
    // 1. Save to bookmarks subcollection if present
    final bookmarkDoc = _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(questionId);

    await bookmarkDoc.set({
      'questionId': questionId,
      'selectedOptionId': optionId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Also record to questionStats so analytics and mistake bank track it
    final statDoc = _firestore
        .collection('users')
        .doc(uid)
        .collection('questionStats')
        .doc(questionId);

    await statDoc.set({
      'selectedOptionId': optionId,
      'lastAttemptedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
