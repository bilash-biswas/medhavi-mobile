import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medhavi_mobile/features/question_bank/data/datasources/question_remote_datasource.dart';
import 'package:medhavi_mobile/features/question_bank/domain/entities/question_entity.dart';
import 'package:medhavi_mobile/features/bookmarks/data/datasources/bookmarks_remote_datasource.dart';
import 'package:medhavi_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/controllers/question_bank_controller.dart';

class BookmarksState {
  final List<QuestionEntity> questions;
  final Set<String> bookmarkedIds;
  final Map<String, String> userAnswersMap;
  final bool isLoading;
  final String searchQuery;
  final String selectedSubjectId;
  final bool globalRevealed;
  final String? errorMessage;

  const BookmarksState({
    this.questions = const [],
    this.bookmarkedIds = const {},
    this.userAnswersMap = const {},
    this.isLoading = true,
    this.searchQuery = '',
    this.selectedSubjectId = 'all',
    this.globalRevealed = true,
    this.errorMessage,
  });

  BookmarksState copyWith({
    List<QuestionEntity>? questions,
    Set<String>? bookmarkedIds,
    Map<String, String>? userAnswersMap,
    bool? isLoading,
    String? searchQuery,
    String? selectedSubjectId,
    bool? globalRevealed,
    String? errorMessage,
  }) {
    return BookmarksState(
      questions: questions ?? this.questions,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      userAnswersMap: userAnswersMap ?? this.userAnswersMap,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
      globalRevealed: globalRevealed ?? this.globalRevealed,
      errorMessage: errorMessage,
    );
  }

  List<QuestionEntity> get filteredQuestions {
    return questions.where((q) {
      if (selectedSubjectId != 'all' && q.subjectId != selectedSubjectId) {
        return false;
      }
      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchesText = q.question.toLowerCase().contains(query);
        final matchesBangla = q.textEn?.toLowerCase().contains(query) ?? false;
        final matchesOptions = q.options.any((o) => o.text.toLowerCase().contains(query));
        return matchesText || matchesBangla || matchesOptions;
      }
      return true;
    }).toList();
  }
}

class BookmarksController extends Notifier<BookmarksState> {
  QuestionRemoteDataSource get _questionDataSource => ref.read(questionRemoteDataSourceProvider);
  BookmarksRemoteDataSource get _bookmarksDataSource => ref.read(bookmarksRemoteDataSourceProvider);

  @override
  BookmarksState build() {
    Future.microtask(() => loadBookmarks());
    return const BookmarksState();
  }

  Future<void> loadBookmarks() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(isLoading: false, questions: []);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final bookmarkIds = await _bookmarksDataSource.getBookmarkIds(user.uid);
      final answersMap = await _bookmarksDataSource.getUserRecordedAnswers(user.uid);

      if (bookmarkIds.isEmpty) {
        state = state.copyWith(
          questions: [],
          bookmarkedIds: {},
          userAnswersMap: answersMap,
          isLoading: false,
        );
        return;
      }

      final questions = await _questionDataSource.getQuestionsByIds(bookmarkIds.toList());

      state = state.copyWith(
        questions: questions,
        bookmarkedIds: bookmarkIds,
        userAnswersMap: answersMap,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSubject(String subjectId) {
    state = state.copyWith(selectedSubjectId: subjectId);
  }

  void toggleGlobalRevealed() {
    state = state.copyWith(globalRevealed: !state.globalRevealed);
  }

  Future<void> removeBookmark(String questionId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Optimistic removal from bookmarks state
    final updatedList = state.questions.where((q) => q.id != questionId).toList();
    final updatedIds = Set<String>.from(state.bookmarkedIds)..remove(questionId);

    state = state.copyWith(
      questions: updatedList,
      bookmarkedIds: updatedIds,
    );

    // Also update QuestionBankController state if active
    ref.read(questionBankControllerProvider.notifier).toggleBookmark(questionId);

    try {
      await _bookmarksDataSource.toggleBookmark(user.uid, questionId);
    } catch (e) {
      // Reload on failure
      loadBookmarks();
    }
  }

  Future<void> recordAnswer(String questionId, String optionId) async {
    final updatedAnswers = Map<String, String>.from(state.userAnswersMap);
    updatedAnswers[questionId] = optionId;
    state = state.copyWith(userAnswersMap: updatedAnswers);

    final user = ref.read(currentUserProvider);
    if (user != null) {
      await _bookmarksDataSource.saveBookmarkAnswer(user.uid, questionId, optionId);
    }
  }
}

final bookmarksControllerProvider =
    NotifierProvider<BookmarksController, BookmarksState>(BookmarksController.new);
