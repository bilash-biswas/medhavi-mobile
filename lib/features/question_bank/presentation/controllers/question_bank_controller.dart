import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/question_remote_datasource.dart';
import '../../domain/entities/question_entity.dart';
import '../../../bookmarks/data/datasources/bookmarks_remote_datasource.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

final questionRemoteDataSourceProvider = Provider<QuestionRemoteDataSource>((ref) {
  return QuestionRemoteDataSourceImpl();
});

final bookmarksRemoteDataSourceProvider = Provider<BookmarksRemoteDataSource>((ref) {
  return BookmarksRemoteDataSourceImpl();
});

class QuestionBankState {
  final List<QuestionEntity> questions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;
  final String selectedExamId;
  final String selectedSubjectId;
  final String selectedBatchTag;
  final String selectedDifficulty;
  final String searchQuery;
  final bool autoRevealAll;
  final List<Map<String, dynamic>> subjects;
  final Set<String> bookmarkedIds;
  final Map<String, String> userAnswers;
  final String? errorMessage;

  const QuestionBankState({
    this.questions = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.lastDoc,
    this.selectedExamId = 'exam_bcs',
    this.selectedSubjectId = '',
    this.selectedBatchTag = '',
    this.selectedDifficulty = 'all',
    this.searchQuery = '',
    this.autoRevealAll = false,
    this.subjects = const [],
    this.bookmarkedIds = const {},
    this.userAnswers = const {},
    this.errorMessage,
  });

  QuestionBankState copyWith({
    List<QuestionEntity>? questions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    DocumentSnapshot? lastDoc,
    String? selectedExamId,
    String? selectedSubjectId,
    String? selectedBatchTag,
    String? selectedDifficulty,
    String? searchQuery,
    bool? autoRevealAll,
    List<Map<String, dynamic>>? subjects,
    Set<String>? bookmarkedIds,
    Map<String, String>? userAnswers,
    String? errorMessage,
  }) {
    return QuestionBankState(
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      lastDoc: lastDoc ?? this.lastDoc,
      selectedExamId: selectedExamId ?? this.selectedExamId,
      selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
      selectedBatchTag: selectedBatchTag ?? this.selectedBatchTag,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      searchQuery: searchQuery ?? this.searchQuery,
      autoRevealAll: autoRevealAll ?? this.autoRevealAll,
      subjects: subjects ?? this.subjects,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      userAnswers: userAnswers ?? this.userAnswers,
      errorMessage: errorMessage,
    );
  }

  /// Filtered questions based on client-side search query
  List<QuestionEntity> get filteredQuestions {
    if (searchQuery.trim().isEmpty) {
      return questions;
    }
    final query = searchQuery.trim().toLowerCase();
    return questions.where((q) {
      final matchesText = q.question.toLowerCase().contains(query);
      final matchesBangla = q.textEn?.toLowerCase().contains(query) ?? false;
      final matchesTag = q.tags.any((t) => t.toLowerCase().contains(query));
      final matchesOptions = q.options.any((o) => o.text.toLowerCase().contains(query));
      return matchesText || matchesBangla || matchesTag || matchesOptions;
    }).toList();
  }
}

class QuestionBankController extends Notifier<QuestionBankState> {
  QuestionRemoteDataSource get _dataSource => ref.read(questionRemoteDataSourceProvider);
  BookmarksRemoteDataSource get _bookmarksDataSource => ref.read(bookmarksRemoteDataSourceProvider);

  @override
  QuestionBankState build() {
    Future.microtask(() => init());
    return const QuestionBankState();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // 1. Fetch BCS subjects
      final subjects = await _dataSource.getSubjects(examId: state.selectedExamId);

      // 2. Fetch bookmarks and recorded answers if user is logged in
      final user = ref.read(currentUserProvider);
      Set<String> bookmarks = {};
      Map<String, String> answers = {};

      if (user != null) {
        bookmarks = await _bookmarksDataSource.getBookmarkIds(user.uid);
        answers = await _bookmarksDataSource.getUserRecordedAnswers(user.uid);
      }

      state = state.copyWith(
        subjects: subjects,
        bookmarkedIds: bookmarks,
        userAnswers: answers,
      );

      // 3. Fetch first page of questions
      await loadInitialQuestions();
    } catch (e, st) {
      debugPrint('QuestionBank init error: $e\n$st');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadInitialQuestions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _dataSource.getQuestions(
        filters: QuestionFilterParams(
          examId: state.selectedExamId,
          subjectId: state.selectedSubjectId,
          tag: state.selectedBatchTag,
          difficulty: state.selectedDifficulty,
        ),
        pageSize: 20,
      );

      debugPrint(
          'Loaded ${result.questions.length} questions (hasMore: ${result.hasMore})');

      state = state.copyWith(
        questions: result.questions,
        lastDoc: result.lastDoc,
        hasMore: result.hasMore,
        isLoading: false,
      );
    } catch (e, st) {
      debugPrint('QuestionBank loadInitialQuestions error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _dataSource.getQuestions(
        filters: QuestionFilterParams(
          examId: state.selectedExamId,
          subjectId: state.selectedSubjectId,
          tag: state.selectedBatchTag,
          difficulty: state.selectedDifficulty,
        ),
        pageSize: 20,
        lastDocSnap: state.lastDoc,
      );

      state = state.copyWith(
        questions: [...state.questions, ...result.questions],
        lastDoc: result.lastDoc,
        hasMore: result.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSubject(String subjectId) {
    if (state.selectedSubjectId == subjectId) return;
    state = state.copyWith(selectedSubjectId: subjectId);
    loadInitialQuestions();
  }

  void setBatch(String batchTag) {
    if (state.selectedBatchTag == batchTag) return;
    state = state.copyWith(selectedBatchTag: batchTag);
    loadInitialQuestions();
  }

  void setDifficulty(String difficulty) {
    if (state.selectedDifficulty == difficulty) return;
    state = state.copyWith(selectedDifficulty: difficulty);
    loadInitialQuestions();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleAutoRevealAll() {
    state = state.copyWith(autoRevealAll: !state.autoRevealAll);
  }

  Future<void> toggleBookmark(String questionId) async {
    var user = ref.read(currentUserProvider);
    if (user == null) {
      user = await ref.read(authControllerProvider.notifier).ensureAuthenticated();
      if (user == null) return;
    }

    final isCurrentlyBookmarked = state.bookmarkedIds.contains(questionId);
    final updatedBookmarks = Set<String>.from(state.bookmarkedIds);

    if (isCurrentlyBookmarked) {
      updatedBookmarks.remove(questionId);
    } else {
      updatedBookmarks.add(questionId);
    }

    state = state.copyWith(bookmarkedIds: updatedBookmarks);

    try {
      await _bookmarksDataSource.toggleBookmark(user.uid, questionId);
    } catch (e) {
      // Revert if error
      state = state.copyWith(bookmarkedIds: state.bookmarkedIds);
    }
  }

  Future<void> recordAnswer(String questionId, String optionId) async {
    final updatedAnswers = Map<String, String>.from(state.userAnswers);
    updatedAnswers[questionId] = optionId;
    state = state.copyWith(userAnswers: updatedAnswers);

    var user = ref.read(currentUserProvider);
    user ??= await ref.read(authControllerProvider.notifier).ensureAuthenticated();
    if (user != null) {
      await _bookmarksDataSource.saveBookmarkAnswer(user.uid, questionId, optionId);
    }
  }
}

final questionBankControllerProvider =
    NotifierProvider<QuestionBankController, QuestionBankState>(
        QuestionBankController.new);
