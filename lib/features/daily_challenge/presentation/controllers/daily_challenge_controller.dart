import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medhavi_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:medhavi_mobile/features/question_bank/domain/entities/question_entity.dart';
import 'package:medhavi_mobile/features/daily_challenge/data/datasources/daily_challenge_remote_datasource.dart';

class DailyChallengeState {
  final bool isLoading;
  final String? errorMessage;
  final List<QuestionEntity> questions;
  final int currentIndex;
  final Map<String, String> selectedAnswers; // questionId -> optionId
  final bool isCompleted;
  final bool alreadyCompletedToday;
  final int durationSeconds;
  final int currentStreak;
  final int longestStreak;
  final String dateStr;

  const DailyChallengeState({
    this.isLoading = true,
    this.errorMessage,
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswers = const {},
    this.isCompleted = false,
    this.alreadyCompletedToday = false,
    this.durationSeconds = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.dateStr = '',
  });

  QuestionEntity? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  int get score {
    int total = 0;
    for (final q in questions) {
      if (selectedAnswers[q.id] == q.correctOptionId) {
        total++;
      }
    }
    return total;
  }

  DailyChallengeState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<QuestionEntity>? questions,
    int? currentIndex,
    Map<String, String>? selectedAnswers,
    bool? isCompleted,
    bool? alreadyCompletedToday,
    int? durationSeconds,
    int? currentStreak,
    int? longestStreak,
    String? dateStr,
  }) {
    return DailyChallengeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
      alreadyCompletedToday:
          alreadyCompletedToday ?? this.alreadyCompletedToday,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      dateStr: dateStr ?? this.dateStr,
    );
  }
}

final dailyChallengeControllerProvider =
    NotifierProvider<DailyChallengeController, DailyChallengeState>(
        DailyChallengeController.new);

class DailyChallengeController extends Notifier<DailyChallengeState> {
  Timer? _timer;

  DailyChallengeRemoteDataSource get _dataSource =>
      ref.read(dailyChallengeRemoteDataSourceProvider);

  String? get _userId => ref.read(currentUserProvider)?.uid;

  @override
  DailyChallengeState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    Future.microtask(() => init());
    return const DailyChallengeState();
  }

  String _getTodayDateStr() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> init() async {
    final dateStr = _getTodayDateStr();
    state = state.copyWith(isLoading: true, dateStr: dateStr);

    try {
      bool isDone = false;
      final uid = _userId;
      if (uid != null) {
        isDone = await _dataSource.hasUserCompletedDailyToday(uid, dateStr);
      }

      final qs = await _dataSource.getTodayDailyQuestions(dateStr);

      state = state.copyWith(
        isLoading: false,
        questions: qs,
        errorMessage: null,
        alreadyCompletedToday: isDone,
        isCompleted: isDone,
      );

      if (!isDone && qs.isNotEmpty) {
        _startTimer();
      }
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'আজকের দৈনিক চ্যালেঞ্জ লোড করা সম্ভব হয়নি। আবার চেষ্টা করুন।',
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isCompleted) {
        state = state.copyWith(durationSeconds: state.durationSeconds + 1);
      }
    });
  }

  void selectAnswer(String questionId, String optionId) {
    if (state.selectedAnswers.containsKey(questionId)) return; // already answered
    HapticFeedback.lightImpact();

    final nextAnswers = Map<String, String>.from(state.selectedAnswers);
    nextAnswers[questionId] = optionId;
    state = state.copyWith(selectedAnswers: nextAnswers);
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      HapticFeedback.selectionClick();
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      HapticFeedback.selectionClick();
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  Future<void> finishChallenge() async {
    _timer?.cancel();
    state = state.copyWith(isCompleted: true);
    HapticFeedback.mediumImpact();

    final uid = _userId;
    if (uid == null) {
      return;
    }

    final answersList = state.questions.map((q) {
      final selected = state.selectedAnswers[q.id];
      final isCorrect = selected == q.correctOptionId;
      return {
        'questionId': q.id,
        'selectedOptionId': selected,
        'correctOptionId': q.correctOptionId,
        'isCorrect': isCorrect,
      };
    }).toList();

    try {
      final res = await _dataSource.recordDailyAttempt(
        userId: uid,
        dateStr: state.dateStr,
        score: state.score,
        totalQuestions: state.questions.length,
        durationSeconds: state.durationSeconds,
        answers: answersList,
      );

      state = state.copyWith(
        currentStreak: (res['currentStreak'] as num?)?.toInt() ?? 1,
        longestStreak: (res['longestStreak'] as num?)?.toInt() ?? 1,
      );
    } catch (_) {
      // non-blocking
    }
  }
}
