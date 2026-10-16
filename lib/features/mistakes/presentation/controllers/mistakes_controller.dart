import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medhavi_mobile/features/question_bank/data/datasources/question_remote_datasource.dart';
import 'package:medhavi_mobile/features/question_bank/domain/entities/question_entity.dart';
import 'package:medhavi_mobile/features/bookmarks/data/datasources/bookmarks_remote_datasource.dart';
import 'package:medhavi_mobile/features/mistakes/data/datasources/mistakes_remote_datasource.dart';
import 'package:medhavi_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/controllers/question_bank_controller.dart';

final mistakesRemoteDataSourceProvider = Provider<MistakesRemoteDataSource>((ref) {
  return MistakesRemoteDataSourceImpl();
});

class MistakesState {
  final List<QuestionEntity> questions;
  final Set<String> bookmarkedIds;
  final Map<String, String> userAnswersMap;
  final bool isLoading;
  final String searchQuery;
  final String selectedDifficulty;
  final bool globalRevealed;
  final String? errorMessage;

  const MistakesState({
    this.questions = const [],
    this.bookmarkedIds = const {},
    this.userAnswersMap = const {},
    this.isLoading = true,
    this.searchQuery = '',
    this.selectedDifficulty = 'all',
    this.globalRevealed = true,
    this.errorMessage,
  });

  MistakesState copyWith({
    List<QuestionEntity>? questions,
    Set<String>? bookmarkedIds,
    Map<String, String>? userAnswersMap,
    bool? isLoading,
    String? searchQuery,
    String? selectedDifficulty,
    bool? globalRevealed,
    String? errorMessage,
  }) {
    return MistakesState(
      questions: questions ?? this.questions,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      userAnswersMap: userAnswersMap ?? this.userAnswersMap,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      globalRevealed: globalRevealed ?? this.globalRevealed,
      errorMessage: errorMessage,
    );
  }

  List<QuestionEntity> get filteredQuestions {
    return questions.where((q) {
      if (selectedDifficulty != 'all' && q.difficulty != selectedDifficulty) {
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

class MistakesController extends Notifier<MistakesState> {
  QuestionRemoteDataSource get _questionDataSource => ref.read(questionRemoteDataSourceProvider);
  MistakesRemoteDataSource get _mistakesDataSource => ref.read(mistakesRemoteDataSourceProvider);
  BookmarksRemoteDataSource get _bookmarksDataSource => ref.read(bookmarksRemoteDataSourceProvider);

  @override
  MistakesState build() {
    Future.microtask(() => loadMistakes());
    return const MistakesState();
  }

  Future<void> loadMistakes() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(isLoading: false, questions: []);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final mistakeIds = await _mistakesDataSource.getMistakeQuestionIds(user.uid);
      final bookmarkIds = await _bookmarksDataSource.getBookmarkIds(user.uid);
      final answersMap = await _bookmarksDataSource.getUserRecordedAnswers(user.uid);

      if (mistakeIds.isEmpty) {
        state = state.copyWith(
          questions: [],
          bookmarkedIds: bookmarkIds,
          userAnswersMap: answersMap,
          isLoading: false,
        );
        return;
      }

      final questions = await _questionDataSource.getQuestionsByIds(mistakeIds);

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

  void setDifficulty(String difficulty) {
    state = state.copyWith(selectedDifficulty: difficulty);
  }

  void toggleGlobalRevealed() {
    state = state.copyWith(globalRevealed: !state.globalRevealed);
  }

  Future<void> removeMistake(String questionId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Optimistic removal
    final updatedList = state.questions.where((q) => q.id != questionId).toList();
    state = state.copyWith(questions: updatedList);

    try {
      await _mistakesDataSource.removeMistake(user.uid, questionId);
    } catch (e) {
      // Reload on failure
      loadMistakes();
    }
  }

  Future<void> toggleBookmark(String questionId) async {
    await ref.read(questionBankControllerProvider.notifier).toggleBookmark(questionId);
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final bookmarkIds = await _bookmarksDataSource.getBookmarkIds(user.uid);
      state = state.copyWith(bookmarkedIds: bookmarkIds);
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

final mistakesControllerProvider =
    NotifierProvider<MistakesController, MistakesState>(MistakesController.new);
