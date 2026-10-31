import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
  Future<int> getQuestionCount(QuestionFilterParams filters);
  Future<Map<String, int>> getSubjectQuestionCounts({String examId = 'exam_bcs'});
}

class QuestionRemoteDataSourceImpl implements QuestionRemoteDataSource {
  final FirebaseFirestore _firestore;

  QuestionRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _questionsCol =>
      _firestore.collection('questions');

  static const List<Map<String, dynamic>> _defaultBcsSubjects = [
    {
      'id': 'sub_bcs_bangla',
      'name': 'বাংলা ভাষা ও সাহিত্য',
      'nameEn': 'Bengali Language & Literature',
      'slug': 'bangla',
      'order': 1,
    },
    {
      'id': 'sub_bcs_english',
      'name': 'English Language & Literature',
      'nameEn': 'English Language & Literature',
      'slug': 'english',
      'order': 2,
    },
    {
      'id': 'sub_bcs_math',
      'name': 'গাণিতিক যুক্তি (Mathematics)',
      'nameEn': 'Mathematical Reasoning',
      'slug': 'math',
      'order': 3,
    },
    {
      'id': 'sub_bcs_bd_affairs',
      'name': 'বাংলাদেশ বিষয়াবলি',
      'nameEn': 'Bangladesh Affairs',
      'slug': 'bangladesh-affairs',
      'order': 4,
    },
    {
      'id': 'sub_bcs_intl_affairs',
      'name': 'আন্তর্জাতিক বিষয়াবলি',
      'nameEn': 'International Affairs',
      'slug': 'international-affairs',
      'order': 5,
    },
    {
      'id': 'sub_bcs_science',
      'name': 'সাধারণ বিজ্ঞান',
      'nameEn': 'General Science',
      'slug': 'general-science',
      'order': 6,
    },
    {
      'id': 'sub_bcs_ict',
      'name': 'তথ্য ও যোগাযোগ প্রযুক্তি (ICT)',
      'nameEn': 'Computer & ICT',
      'slug': 'ict',
      'order': 7,
    },
    {
      'id': 'sub_bcs_mental_ability',
      'name': 'মানসিক দক্ষতা',
      'nameEn': 'Mental Ability',
      'slug': 'mental-ability',
      'order': 8,
    },
    {
      'id': 'sub_bcs_geography',
      'name': 'ভূগোল, পরিবেশ ও দুর্যোগ ব্যবস্থাপনা',
      'nameEn': 'Geography & Environment',
      'slug': 'geography',
      'order': 9,
    },
    {
      'id': 'sub_bcs_ethics',
      'name': 'নৈতিকতা, মূল্যবোধ ও সুশাসন',
      'nameEn': 'Ethics, Values & Governance',
      'slug': 'ethics',
      'order': 10,
    },
  ];

  /// Normalizes batch and subject tags to match all Firestore tag variations
  /// e.g. "42nd-bcs" -> ["42nd-bcs", "42ndbcs", "42ndbcs-bcs", "#42nd-bcs", "#42ndbcs", "#42ndbcs-bcs"]
  static List<String> getTagVariants(String rawTag) {
    final tag = rawTag.toLowerCase().trim();
    final match = RegExp(r'^#?(\d+(?:st|nd|rd|th))-?bcs$').firstMatch(tag);
    if (match != null) {
      final prefix = match.group(1)!;
      return [
        '$prefix-bcs',
        '${prefix}bcs',
        '${prefix}bcs-bcs',
        '#$prefix-bcs',
        '#${prefix}bcs',
        '#${prefix}bcs-bcs',
      ];
    }
    return [tag, '#$tag'];
  }

  /// Legacy helper for unit tests and backwards compatibility
  static String? normalizeTag(String? rawTag) {
    if (rawTag == null || rawTag.trim().isEmpty) return null;
    final tag = rawTag.toLowerCase().trim();
    final match = RegExp(r'^(\d+(?:st|nd|rd|th))-bcs$').firstMatch(tag);
    if (match != null) {
      return '${match.group(1)}bcs-bcs';
    }
    return tag;
  }

  @override
  Future<PaginatedQuestionsResult> getQuestions({
    QuestionFilterParams filters = const QuestionFilterParams(),
    int pageSize = 20,
    DocumentSnapshot? lastDocSnap,
  }) async {
    Query<Map<String, dynamic>> buildBaseQuery({required bool includeOrderBy}) {
      Query<Map<String, dynamic>> q = _questionsCol;

      if (filters.examId != null && filters.examId!.isNotEmpty) {
        q = q.where('examId', isEqualTo: filters.examId);
      }

      if (filters.subjectId != null &&
          filters.subjectId!.isNotEmpty &&
          filters.subjectId != 'all') {
        if (filters.subjectId!.startsWith('sub_bcs_') ||
            filters.subjectId!.startsWith('subj_bcs_')) {
          final coreSlug =
              filters.subjectId!.replaceFirst(RegExp(r'^subj?_bcs_'), '');
          q = q.where('subjectId',
              whereIn: ['sub_bcs_$coreSlug', 'subj_bcs_$coreSlug']);
        } else {
          q = q.where('subjectId', isEqualTo: filters.subjectId);
        }
      }

      if (filters.difficulty != null &&
          filters.difficulty!.isNotEmpty &&
          filters.difficulty != 'all') {
        q = q.where('difficulty', isEqualTo: filters.difficulty);
      }

      if (filters.tag != null && filters.tag!.isNotEmpty) {
        final variants = getTagVariants(filters.tag!);
        q = q.where('tags', arrayContainsAny: variants);
      }

      // Default status to published and strictly show only verified questions
      q = q.where('status', isEqualTo: 'published');
      q = q.where('adminVerified', isEqualTo: true);

      if (includeOrderBy) {
        q = q.orderBy('createdAt', descending: true);
      }

      if (lastDocSnap != null) {
        q = q.startAfterDocument(lastDocSnap);
      }

      q = q.limit(pageSize + 1);
      return q;
    }

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await buildBaseQuery(includeOrderBy: true).get();
    } catch (e) {
      debugPrint(
          'Notice: Composite index not ready or missing ($e), using resilient query fallback.');
      snapshot = await buildBaseQuery(includeOrderBy: false).get();
    }

    final docs = snapshot.docs;
    final hasMore = docs.length > pageSize;
    final contentDocs = hasMore ? docs.sublist(0, pageSize) : docs;
    final lastDoc = contentDocs.isNotEmpty ? contentDocs.last : null;

    final questions = contentDocs
        .map((docSnap) =>
            QuestionEntity.fromFirestore(docSnap.id, docSnap.data()))
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

    final idMap = {for (final q in results) q.id: q};
    return ids
        .where((id) => idMap.containsKey(id) && idMap[id]!.adminVerified)
        .map((id) => idMap[id]!)
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getSubjects(
      {String examId = 'exam_bcs'}) async {
    try {
      final snapshot = await _firestore
          .collection('subjects')
          .where('examId', isEqualTo: examId)
          .get();

      final list = snapshot.docs.map((d) {
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

      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('Notice: Error loading subjects from Firestore: $e');
    }

    return _defaultBcsSubjects;
  }

  Query<Map<String, dynamic>> _buildCountQuery(QuestionFilterParams filters) {
    Query<Map<String, dynamic>> q = _questionsCol;

    if (filters.examId != null && filters.examId!.isNotEmpty) {
      q = q.where('examId', isEqualTo: filters.examId);
    }

    if (filters.subjectId != null &&
        filters.subjectId!.isNotEmpty &&
        filters.subjectId != 'all') {
      if (filters.subjectId!.startsWith('sub_bcs_') ||
          filters.subjectId!.startsWith('subj_bcs_')) {
        final coreSlug =
            filters.subjectId!.replaceFirst(RegExp(r'^subj?_bcs_'), '');
        q = q.where('subjectId',
            whereIn: ['sub_bcs_$coreSlug', 'subj_bcs_$coreSlug']);
      } else {
        q = q.where('subjectId', isEqualTo: filters.subjectId);
      }
    }

    if (filters.difficulty != null &&
        filters.difficulty!.isNotEmpty &&
        filters.difficulty != 'all') {
      q = q.where('difficulty', isEqualTo: filters.difficulty);
    }

    if (filters.tag != null && filters.tag!.isNotEmpty) {
      final variants = getTagVariants(filters.tag!);
      q = q.where('tags', arrayContainsAny: variants);
    }

    q = q.where('status', isEqualTo: 'published');
    q = q.where('adminVerified', isEqualTo: true);
    return q;
  }

  @override
  Future<int> getQuestionCount(QuestionFilterParams filters) async {
    try {
      final agg = await _buildCountQuery(filters).count().get();
      return agg.count ?? 0;
    } catch (e) {
      debugPrint('Notice: Error counting questions: $e');
      return 0;
    }
  }

  @override
  Future<Map<String, int>> getSubjectQuestionCounts(
      {String examId = 'exam_bcs'}) async {
    final Map<String, int> counts = {};
    try {
      final subjects = await getSubjects(examId: examId);
      final futures = <Future<void>>[];

      // Total across all subjects
      futures.add(() async {
        final total =
            await getQuestionCount(QuestionFilterParams(examId: examId));
        counts['all'] = total;
      }());

      for (final sub in subjects) {
        final subId = sub['id'] as String? ?? '';
        if (subId.isEmpty) continue;
        futures.add(() async {
          final c = await getQuestionCount(
            QuestionFilterParams(examId: examId, subjectId: subId),
          );
          counts[subId] = c;
        }());
      }

      await Future.wait(futures);
    } catch (e) {
      debugPrint('Notice: Error loading subject counts: $e');
    }
    return counts;
  }
}
