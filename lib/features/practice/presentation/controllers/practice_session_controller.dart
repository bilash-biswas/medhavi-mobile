import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medhavi_mobile/features/question_bank/data/datasources/question_remote_datasource.dart';
import 'package:medhavi_mobile/features/question_bank/domain/entities/question_entity.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/controllers/question_bank_controller.dart';
import 'package:medhavi_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum PracticeMode {
  instant, // Reveals answer and explanation immediately upon selection
  exam, // Timed simulation; reveals scorecard upon submission
}

class PracticeSessionState {
  final String title;
  final String subtitle;
  final List<QuestionEntity> questions;
  final int currentIndex;
  final Map<String, String> selectedAnswers; // questionId -> optionId
  final Map<String, bool> revealedMap; // questionId -> bool (for instant mode)
  final PracticeMode mode;
  final int timeRemainingSeconds;
  final int totalTimeSeconds;
  final bool isLoading;
  final bool isCompleted;
  final String? errorMessage;

  const PracticeSessionState({
    this.title = 'অনুশীলন সেশন',
    this.subtitle = '',
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswers = const {},
    this.revealedMap = const {},
    this.mode = PracticeMode.instant,
    this.timeRemainingSeconds = 600,
    this.totalTimeSeconds = 600,
    this.isLoading = false,
    this.isCompleted = false,
    this.errorMessage,
  });

  QuestionEntity? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  int get totalQuestions => questions.length;

  int get correctCount {
    int count = 0;
    for (final q in questions) {
      if (selectedAnswers[q.id] == q.correctOptionId) {
        count++;
      }
    }
    return count;
  }

  int get incorrectCount {
    int count = 0;
    for (final q in questions) {
      final selected = selectedAnswers[q.id];
      if (selected != null && selected != q.correctOptionId) {
        count++;
      }
    }
    return count;
  }

  int get unattemptedCount => totalQuestions - selectedAnswers.length;

  int get accuracyPercentage {
    if (selectedAnswers.isEmpty) return 0;
    return ((correctCount / selectedAnswers.length) * 100).toInt();
  }

  /// BCS Preliminary scoring: +1.0 per correct, -0.50 per wrong answer
  double get totalScore {
    final raw = (correctCount * 1.0) - (incorrectCount * 0.50);
    return raw < 0 ? 0.0 : raw;
  }

  PracticeSessionState copyWith({
    String? title,
    String? subtitle,
    List<QuestionEntity>? questions,
    int? currentIndex,
    Map<String, String>? selectedAnswers,
    Map<String, bool>? revealedMap,
    PracticeMode? mode,
    int? timeRemainingSeconds,
    int? totalTimeSeconds,
    bool? isLoading,
    bool? isCompleted,
    String? errorMessage,
  }) {
    return PracticeSessionState(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      revealedMap: revealedMap ?? this.revealedMap,
      mode: mode ?? this.mode,
      timeRemainingSeconds:
          timeRemainingSeconds ?? this.timeRemainingSeconds,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: errorMessage,
    );
  }
}

class PracticeSessionController extends Notifier<PracticeSessionState> {
  Timer? _timer;

  QuestionRemoteDataSource get _questionDataSource =>
      ref.read(questionRemoteDataSourceProvider);

  @override
  PracticeSessionState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const PracticeSessionState();
  }

  /// Start a practice session with real questions from Firestore
  Future<void> startPractice({
    required String title,
    String subtitle = '',
    String? subjectId,
    String? batchTag,
    PracticeMode mode = PracticeMode.instant,
    int questionCount = 20,
    List<QuestionEntity>? preloadedQuestions,
  }) async {
    _timer?.cancel();

    state = PracticeSessionState(
      title: title,
      subtitle: subtitle,
      mode: mode,
      isLoading: true,
      questions: preloadedQuestions ?? [],
    );

    if (preloadedQuestions != null && preloadedQuestions.isNotEmpty) {
      _initSessionQuestions(preloadedQuestions, mode);
      return;
    }

    try {
      final fetchLimit = questionCount > 25 ? questionCount * 2 : 50;
      final result = await _questionDataSource.getQuestions(
        filters: QuestionFilterParams(
          examId: 'exam_bcs',
          subjectId: (subjectId != null && subjectId.isNotEmpty) ? subjectId : null,
          tag: (batchTag != null && batchTag.isNotEmpty) ? batchTag : null,
        ),
        pageSize: fetchLimit,
      );

      var fetched = List<QuestionEntity>.from(result.questions);
      if (fetched.isEmpty) {
        final fallback = await _questionDataSource.getQuestions(
          filters: QuestionFilterParams(
            examId: null,
            subjectId: (subjectId != null && subjectId.isNotEmpty) ? subjectId : null,
            tag: (batchTag != null && batchTag.isNotEmpty) ? batchTag : null,
          ),
          pageSize: fetchLimit,
        );
        fetched = List<QuestionEntity>.from(fallback.questions);
      }

      // Shuffle for dynamic practice variety
      fetched.shuffle();
      final finalQuestions =
          fetched.length > questionCount ? fetched.sublist(0, questionCount) : fetched;

      if (finalQuestions.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'এই বিষয়ের কোনো প্রশ্ন পাওয়া যায়নি। অন্য বিষয় নির্বাচন করুন।',
        );
        return;
      }

      _initSessionQuestions(finalQuestions, mode);
    } catch (e) {
      debugPrint('Error starting practice session: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'প্রশ্ন লোড করতে সমস্যা হয়েছে: $e',
      );
    }
  }

  void _initSessionQuestions(List<QuestionEntity> questions, PracticeMode mode) {
    // 60 seconds per question for exam mode
    final durationSeconds = questions.length * 60;

    state = state.copyWith(
      questions: questions,
      currentIndex: 0,
      selectedAnswers: {},
      revealedMap: {},
      timeRemainingSeconds: durationSeconds,
      totalTimeSeconds: durationSeconds,
      isLoading: false,
      isCompleted: false,
      errorMessage: null,
    );

    if (mode == PracticeMode.exam) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemainingSeconds <= 1) {
        timer.cancel();
        submitPractice();
      } else {
        state = state.copyWith(
          timeRemainingSeconds: state.timeRemainingSeconds - 1,
        );
      }
    });
  }

  /// Select an option for current question
  void selectOption(String optionId) {
    if (state.isCompleted || state.currentQuestion == null) return;
    final qId = state.currentQuestion!.id;

    // In instant mode, do not change once answered to ensure learning
    if (state.mode == PracticeMode.instant && state.selectedAnswers.containsKey(qId)) {
      return;
    }

    final newAnswers = Map<String, String>.from(state.selectedAnswers);
    newAnswers[qId] = optionId;

    final newRevealed = Map<String, bool>.from(state.revealedMap);
    if (state.mode == PracticeMode.instant) {
      newRevealed[qId] = true;
      _logAnswerStats(qId, optionId, state.currentQuestion!.correctOptionId);
    }

    state = state.copyWith(
      selectedAnswers: newAnswers,
      revealedMap: newRevealed,
    );
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  /// Complete & Submit Practice Session
  Future<void> submitPractice() async {
    _timer?.cancel();

    // In exam mode, log all answers to Firestore questionStats
    if (state.mode == PracticeMode.exam) {
      for (final q in state.questions) {
        final selected = state.selectedAnswers[q.id];
        if (selected != null) {
          _logAnswerStats(q.id, selected, q.correctOptionId);
        }
      }
    }

    state = state.copyWith(isCompleted: true);
    _updateUserStreakAndStats();
  }

  /// Updates user's continuous practice streak & counters in Firestore
  Future<void> _updateUserStreakAndStats() async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.isAnonymous) return;

    final answeredCount = state.selectedAnswers.length;
    if (answeredCount == 0) return;

    int correctCount = 0;
    for (final q in state.questions) {
      final selected = state.selectedAnswers[q.id];
      if (selected != null && selected == q.correctOptionId) {
        correctCount++;
      }
    }

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snap = await userRef.get();
      final data = snap.data() ?? {};

      final now = DateTime.now();
      final todayStr =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final rawCurrent = data['currentStreak'] ?? data['streak'] ?? 0;
      final storedCurrent =
          rawCurrent is num ? rawCurrent.toInt() : int.tryParse('$rawCurrent') ?? 0;

      final rawLongest = data['longestStreak'] ?? 0;
      final storedLongest =
          rawLongest is num ? rawLongest.toInt() : int.tryParse('$rawLongest') ?? 0;

      final lastPracticeDate = data['lastPracticeDate'] as String?;

      int nextStreak = 1;
      if (lastPracticeDate != null && lastPracticeDate.trim().isNotEmpty) {
        if (lastPracticeDate.trim() == todayStr) {
          nextStreak = storedCurrent < 1 ? 1 : storedCurrent;
        } else {
          final parsedLast =
              DateTime.tryParse('${lastPracticeDate.trim()}T00:00:00Z');
          if (parsedLast != null) {
            final todayUtc = DateTime.utc(now.year, now.month, now.day);
            final diffDays = todayUtc.difference(parsedLast).inDays;
            if (diffDays == 1) {
              nextStreak = (storedCurrent < 0 ? 0 : storedCurrent) + 1;
            } else {
              // Gap of 2+ days -> streak had dropped to 0, starts fresh at 1 today
              nextStreak = 1;
            }
          }
        }
      }

      final nextLongest = nextStreak > storedLongest ? nextStreak : storedLongest;

      await userRef.set({
        'currentStreak': nextStreak,
        'longestStreak': nextLongest,
        'lastPracticeDate': todayStr,
        'totalAttempts': FieldValue.increment(1),
        'totalQuestionsAnswered': FieldValue.increment(answeredCount),
        'totalCorrect': FieldValue.increment(correctCount),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Notice: Could not update user streak in Firestore: $e');
    }
  }

  /// Restart current session
  void restartPractice() {
    _initSessionQuestions(state.questions, state.mode);
  }

  /// Background async logging to Firestore for mistakes & analytics
  void _logAnswerStats(String questionId, String selectedOptionId, String correctOptionId) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final isCorrect = selectedOptionId == correctOptionId;
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('questionStats')
          .doc(questionId)
          .set({
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
        'isCorrect': isCorrect,
        'incorrectCount': isCorrect ? 0 : FieldValue.increment(1),
        'lastAttemptedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Notice: Error saving questionStats: $e');
    }
  }
}

final practiceSessionControllerProvider =
    NotifierProvider<PracticeSessionController, PracticeSessionState>(
  PracticeSessionController.new,
);
