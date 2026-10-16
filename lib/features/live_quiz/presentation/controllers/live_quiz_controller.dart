import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medhavi_mobile/features/question_bank/domain/entities/question_entity.dart';

class LiveQuizState {
  final List<QuestionEntity> questions;
  final int currentIndex;
  final Map<String, String> selectedAnswers; // questionId -> optionId
  final int timeRemainingSeconds;
  final int totalTimeSeconds;
  final bool isCompleted;
  final bool isSubmitting;

  const LiveQuizState({
    required this.questions,
    this.currentIndex = 0,
    this.selectedAnswers = const {},
    required this.timeRemainingSeconds,
    required this.totalTimeSeconds,
    this.isCompleted = false,
    this.isSubmitting = false,
  });

  QuestionEntity? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

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

  int get unattemptedCount => questions.length - selectedAnswers.length;

  /// Score with -0.50 negative marking per wrong answer
  double get totalScore {
    final raw = (correctCount * 1.0) - (incorrectCount * 0.50);
    return raw < 0 ? 0 : raw;
  }

  LiveQuizState copyWith({
    List<QuestionEntity>? questions,
    int currentIndex = -1,
    Map<String, String>? selectedAnswers,
    int? timeRemainingSeconds,
    int? totalTimeSeconds,
    bool? isCompleted,
    bool? isSubmitting,
  }) {
    return LiveQuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex >= 0 ? currentIndex : this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      timeRemainingSeconds:
          timeRemainingSeconds ?? this.timeRemainingSeconds,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class LiveQuizController extends Notifier<LiveQuizState> {
  Timer? _timer;

  @override
  LiveQuizState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final defaultQuestions = _getSampleQuizQuestions();
    const duration = 300; // 5 minutes

    return LiveQuizState(
      questions: defaultQuestions,
      timeRemainingSeconds: duration,
      totalTimeSeconds: duration,
    );
  }

  void startQuiz({List<QuestionEntity>? customQuestions, int durationSeconds = 300}) {
    _timer?.cancel();
    final qList = customQuestions ?? _getSampleQuizQuestions();

    state = LiveQuizState(
      questions: qList,
      timeRemainingSeconds: durationSeconds,
      totalTimeSeconds: durationSeconds,
      currentIndex: 0,
      selectedAnswers: {},
      isCompleted: false,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemainingSeconds > 0) {
        state = state.copyWith(
          timeRemainingSeconds: state.timeRemainingSeconds - 1,
        );
      } else {
        submitQuiz();
      }
    });
  }

  void selectOption(String questionId, String optionId) {
    if (state.isCompleted) return;
    final updated = Map<String, String>.from(state.selectedAnswers);
    updated[questionId] = optionId;
    state = state.copyWith(selectedAnswers: updated);
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void prevQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void submitQuiz() {
    _timer?.cancel();
    state = state.copyWith(isCompleted: true);
  }

  static List<QuestionEntity> _getSampleQuizQuestions() {
    return const [
      QuestionEntity(
        id: 'lq_1',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_bangla',
        question: 'চর্যাপদ কত সালে আবিষ্কৃত হয়?',
        options: [
          QuestionOption(id: 'a', text: '১৯০৭ সালে'),
          QuestionOption(id: 'b', text: '১৯০৯ সালে'),
          QuestionOption(id: 'c', text: '১৯১৬ সালে'),
          QuestionOption(id: 'd', text: '১৯২৩ সালে'),
        ],
        correctOptionId: 'a',
        explanation: 'মহামহোপাধ্যায় হরপ্রসাদ শাস্ত্রী ১৯০৭ সালে নেপালের রাজদরবারের রয়েল লাইব্রেরি থেকে চর্যাপদের মূল পুঁথি আবিষ্কার করেন।',
        source: '46th-bcs',
        tags: ['46th-bcs', 'bangla'],
      ),
      QuestionEntity(
        id: 'lq_2',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_math',
        question: r'যদি $a + b = 7$ এবং $ab = 10$ হয়, তবে $a^2 + b^2$ এর মান কত?',
        options: [
          QuestionOption(id: 'a', text: '29'),
          QuestionOption(id: 'b', text: '39'),
          QuestionOption(id: 'c', text: '49'),
          QuestionOption(id: 'd', text: '19'),
        ],
        correctOptionId: 'a',
        explanation: r'আমরা জানি, $a^2 + b^2 = (a+b)^2 - 2ab = (7)^2 - 2(10) = 49 - 20 = 29$',
        source: '45th-bcs',
        tags: ['45th-bcs', 'math'],
      ),
      QuestionEntity(
        id: 'lq_3',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_english',
        question: 'Who is the author of "A Passage to India"?',
        options: [
          QuestionOption(id: 'a', text: 'E. M. Forster'),
          QuestionOption(id: 'b', text: 'George Orwell'),
          QuestionOption(id: 'c', text: 'Rudyard Kipling'),
          QuestionOption(id: 'd', text: 'Virginia Woolf'),
        ],
        correctOptionId: 'a',
        explanation: '"A Passage to India" is a famous novel by English author E. M. Forster published in 1924.',
        source: '44th-bcs',
        tags: ['44th-bcs', 'english'],
      ),
      QuestionEntity(
        id: 'lq_4',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_bd_affairs',
        question: 'বাংলাদেশের সংবিধানের কত অনুচ্ছেদে মৌলিক অধিকারের নিশ্চয়তা দেওয়া হয়েছে?',
        options: [
          QuestionOption(id: 'a', text: '২৭ থেকে ৪৪ অনুচ্ছেদ'),
          QuestionOption(id: 'b', text: '৮ থেকে ২৫ অনুচ্ছেদ'),
          QuestionOption(id: 'c', text: '৪৫ থেকে ৬০ অনুচ্ছেদ'),
          QuestionOption(id: 'd', text: '১ থেকে ৭ অনুচ্ছেদ'),
        ],
        correctOptionId: 'a',
        explanation: 'বাংলাদেশ সংবিধানের তৃতীয় ভাগে ২৭ থেকে ৪৪ নম্বর অনুচ্ছেদে নাগরিকদের ১৮টি মৌলিক অধিকারের নিশ্চয়তা প্রদান করা হয়েছে।',
        source: '46th-bcs',
        tags: ['46th-bcs', 'bangladesh'],
      ),
      QuestionEntity(
        id: 'lq_5',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_science',
        question: 'কোন রঙের আলোর বিচ্যুতি সবচেয়ে কম?',
        options: [
          QuestionOption(id: 'a', text: 'লাল'),
          QuestionOption(id: 'b', text: 'বেগুনি'),
          QuestionOption(id: 'c', text: 'হলুদ'),
          QuestionOption(id: 'd', text: 'সবুজ'),
        ],
        correctOptionId: 'a',
        explanation: 'লাল আলোর তরঙ্গদৈর্ঘ্য সবচেয়ে বেশি হওয়ায় প্রিজমের মধ্য দিয়ে প্রতিসরণের সময় লাল আলোর বিচ্যুতি সবচেয়ে কম হয়।',
        source: '43rd-bcs',
        tags: ['43rd-bcs', 'science'],
      ),
    ];
  }
}

final liveQuizControllerProvider =
    NotifierProvider<LiveQuizController, LiveQuizState>(LiveQuizController.new);
