import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medhavi_mobile/core/components/google_sign_in_button.dart';
import 'package:medhavi_mobile/core/utils/bengali_numeral_converter.dart';
import 'package:medhavi_mobile/core/localization/app_strings.dart';
import 'package:medhavi_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:medhavi_mobile/features/live_quiz/presentation/controllers/live_quiz_controller.dart';
import 'package:medhavi_mobile/features/question_bank/domain/entities/question_entity.dart';

void main() {
  group('BengaliNumeralConverter Tests', () {
    test('converts English digits to Bengali digits', () {
      expect(BengaliNumeralConverter.toBengaliNumber(0), '০');
      expect(BengaliNumeralConverter.toBengaliNumber(46), '৪৬');
      expect(BengaliNumeralConverter.toBengaliNumber(50), '৫০');
      expect(BengaliNumeralConverter.toBengaliNumber(5423), '৫,৪২৩');
    });

    test('converts BCS source tags to clean Bengali titles', () {
      expect(
        BengaliNumeralConverter.toBengaliBcsTitle('50th-bcs'),
        '৫০তম বিসিএস',
      );
      expect(
        BengaliNumeralConverter.toBengaliBcsTitle('46th-bcs'),
        '৪৬তম বিসিএস',
      );
      expect(
        BengaliNumeralConverter.toBengaliBcsTitle('42nd-bcs'),
        '৪২তম বিসিএস',
      );
      expect(
        BengaliNumeralConverter.toBengaliBcsTitle('39th-bcs-special'),
        '৩৯তম বিসিএস',
      );
    });
  });

  group('QuestionEntity Deserialization Tests', () {
    test('correctly deserializes Firestore document map', () {
      final mockData = {
        'text': r'যদি $a + b = 5$ এবং $a - b = 3$ হয়, তবে $a^2 - b^2$ এর মান কত?',
        'examId': 'exam_bcs',
        'subjectId': 'bcs_math',
        'difficulty': 'medium',
        'correctOptionId': 'opt_2',
        'explanation': r'আমরা জানি, $a^2 - b^2 = (a+b)(a-b) = 5 \times 3 = 15$',
        'source': '46th-bcs',
        'options': [
          {'id': 'opt_1', 'text': '10'},
          {'id': 'opt_2', 'text': '15'},
          {'id': 'opt_3', 'text': '20'},
          {'id': 'opt_4', 'text': '25'},
        ],
        'tags': ['46th-bcs', 'algebra'],
      };

      final q = QuestionEntity.fromFirestore('q_test_1', mockData);

      expect(q.id, 'q_test_1');
      expect(q.text, contains(r'$a + b = 5$'));
      expect(q.correctOptionId, 'opt_2');
      expect(q.options.length, 4);
      expect(q.options[1].id, 'opt_2');
      expect(q.source, '46th-bcs');
    });
  });

  group('AuthResult Tests', () {
    test('creates successful and failed AuthResult instances', () {
      const successResult = AuthResult(success: true);
      expect(successResult.success, isTrue);
      expect(successResult.error, isNull);

      const errorResult = AuthResult(
        success: false,
        error: 'ইমেইল বা পাসওয়ার্ড সঠিক নয়।',
      );
      expect(errorResult.success, isFalse);
      expect(errorResult.error, 'ইমেইল বা পাসওয়ার্ড সঠিক নয়।');
    });
  });

  group('AppStrings Localization Tests', () {
    test('correctly looks up Bengali and English strings', () {
      expect(AppStrings.get('bn', 'app_name'), 'মেধাবী');
      expect(AppStrings.get('en', 'app_name'), 'Medhavi');
      expect(AppStrings.get('bn', 'nav_leaderboard'), 'লিডারবোর্ড');
      expect(AppStrings.get('en', 'nav_leaderboard'), 'Leaderboard');
      expect(AppStrings.get('bn', 'nav_analytics'), 'অ্যানালিটিক্স');
      expect(AppStrings.get('en', 'nav_analytics'), 'Analytics');
      expect(AppStrings.get('bn', 'nav_live_quiz'), 'লাইভ কুইজ');
      expect(AppStrings.get('en', 'nav_live_quiz'), 'Live Quiz');
      expect(AppStrings.get('bn', 'continue_with_google'), 'Google দিয়ে চালিয়ে যান');
      expect(AppStrings.get('en', 'continue_with_google'), 'Continue with Google');
      expect(AppStrings.get('bn', 'sign_up_google'), 'Google দিয়ে সাইন-আপ করুন');
      expect(AppStrings.get('en', 'sign_up_google'), 'Sign up with Google');
    });
  });

  group('LiveQuiz Scoring Tests', () {
    test('calculates score with -0.50 negative marking', () {
      const q1 = QuestionEntity(
        id: 'q1',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_bangla',
        question: 'প্রশ্ন ১',
        options: [
          QuestionOption(id: 'a', text: 'অপশন ক'),
          QuestionOption(id: 'b', text: 'অপশন খ'),
        ],
        correctOptionId: 'a',
        explanation: 'ব্যাখ্যা',
      );
      const q2 = QuestionEntity(
        id: 'q2',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_bangla',
        question: 'প্রশ্ন ২',
        options: [
          QuestionOption(id: 'a', text: 'অপশন ক'),
          QuestionOption(id: 'b', text: 'অপশন খ'),
        ],
        correctOptionId: 'a',
        explanation: 'ব্যাখ্যা',
      );

      // User answered q1 correctly ('a') and q2 wrongly ('b')
      const state = LiveQuizState(
        questions: [q1, q2],
        selectedAnswers: {'q1': 'a', 'q2': 'b'},
        timeRemainingSeconds: 200,
        totalTimeSeconds: 300,
      );

      expect(state.correctCount, 1);
      expect(state.incorrectCount, 1);
      expect(state.unattemptedCount, 0);
      // 1 correct (+1) - 1 wrong (-0.50) = 0.50 marks
      expect(state.totalScore, 0.50);
    });
  });

  group('GoogleSignInButton Widget Tests', () {
    testWidgets('renders button with localized text and triggers callback',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GoogleSignInButton(
                onPressed: () => tapped = true,
                customText: 'Google দিয়ে চালিয়ে যান',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Google দিয়ে চালিয়ে যান'), findsOneWidget);
      await tester.tap(find.byType(GoogleSignInButton));
      expect(tapped, isTrue);
    });

    testWidgets('displays CircularProgressIndicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GoogleSignInButton(
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
