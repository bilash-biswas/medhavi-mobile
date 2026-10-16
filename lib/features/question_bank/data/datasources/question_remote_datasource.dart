import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/question_entity.dart';

class PaginatedQuestionsResult {
  final List<QuestionEntity> questions;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  const PaginatedQuestionsResult({
    required this.questions,
    this.lastDoc,
    required this.hasMore,
  });
}

class QuestionFilterParams {
  final String? examId;
  final String? subjectId;
  final String? difficulty;
  final String? tag;
  final String? searchQuery;

  const QuestionFilterParams({
    this.examId = 'exam_bcs',
    this.subjectId,
    this.difficulty,
    this.tag,
    this.searchQuery,
  });
}

abstract class QuestionRemoteDataSource {
  Future<PaginatedQuestionsResult> getQuestions({
    QuestionFilterParams filters = const QuestionFilterParams(),
    int pageSize = 20,
    DocumentSnapshot? lastDocSnap,
  });

  Future<List<QuestionEntity>> getQuestionsByIds(List<String> ids);
  Future<List<Map<String, dynamic>>> getSubjects({String examId = 'exam_bcs'});
}

class QuestionRemoteDataSourceImpl implements QuestionRemoteDataSource {
  final FirebaseFirestore _firestore;

  QuestionRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _questionsCol =>
      _firestore.collection('questions');

  @override
  Future<PaginatedQuestionsResult> getQuestions({
    QuestionFilterParams filters = const QuestionFilterParams(),
    int pageSize = 20,
    DocumentSnapshot? lastDocSnap,
  }) async {
    Query<Map<String, dynamic>> q = _questionsCol;

    if (filters.examId != null && filters.examId!.isNotEmpty) {
      q = q.where('examId', isEqualTo: filters.examId);
    }

    if (filters.subjectId != null &&
        filters.subjectId!.isNotEmpty &&
        filters.subjectId != 'all') {
      q = q.where('subjectId', isEqualTo: filters.subjectId);
    }

    if (filters.difficulty != null &&
        filters.difficulty!.isNotEmpty &&
        filters.difficulty != 'all') {
      q = q.where('difficulty', isEqualTo: filters.difficulty);
    }

    if (filters.tag != null && filters.tag!.isNotEmpty) {
      q = q.where('tags', arrayContains: filters.tag!.toLowerCase().trim());
    }

    // Default status to published
    q = q.where('status', isEqualTo: 'published');

    q = q.orderBy('createdAt', descending: true);

    if (lastDocSnap != null) {
      q = q.startAfterDocument(lastDocSnap);
    }

    // Limit by pageSize + 1 to check if there is a next page
    q = q.limit(pageSize + 1);

    final snapshot = await q.get();
    final docs = snapshot.docs;

    final hasMore = docs.length > pageSize;
    final contentDocs = hasMore ? docs.sublist(0, pageSize) : docs;
    final lastDoc = contentDocs.isNotEmpty ? contentDocs.last : null;

    final questions = contentDocs
        .map((docSnap) => QuestionEntity.fromFirestore(docSnap.id, docSnap.data()))
        .toList();

    return PaginatedQuestionsResult(
      questions: questions,
      lastDoc: lastDoc,
      hasMore: hasMore,
    );
  }

  @override
  Future<List<QuestionEntity>> getQuestionsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final List<QuestionEntity> results = [];
    // Firestore whereIn supports maximum 30 items per batch
    const int batchSize = 30;

    for (int i = 0; i < ids.length; i += batchSize) {
      final end = (i + batchSize < ids.length) ? i + batchSize : ids.length;
      final chunk = ids.sublist(i, end);

      final snapshot = await _questionsCol
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        results.add(QuestionEntity.fromFirestore(doc.id, doc.data()));
      }
    }

    // Preserve the original ordering
    final idMap = {for (final q in results) q.id: q};
    return ids.where((id) => idMap.containsKey(id)).map((id) => idMap[id]!).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getSubjects({String examId = 'exam_bcs'}) async {
    final snapshot = await _firestore
        .collection('subjects')
        .where('examId', isEqualTo: examId)
        .get();

    return snapshot.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'name': data['name'] ?? '',
        'nameEn': data['nameEn'] ?? '',
        'slug': data['slug'] ?? '',
        'order': data['order'] ?? 0,
      };
    }).toList()
      ..sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
  }
}
