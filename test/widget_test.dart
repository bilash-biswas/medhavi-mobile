import 'package:flutter_test/flutter_test.dart';
import 'package:medhavi_mobile/core/utils/bengali_numeral_converter.dart';
import 'package:medhavi_mobile/features/question_bank/domain/entities/question_entity.dart';

void main() {
  group('BengaliNumeralConverter Tests', () {
    test('converts English digits to Bengali digits', () {
      expect(BengaliNumeralConverter.toBengaliNumber(0), '০');
      expect(BengaliNumeralConverter.toBengaliNumber(46), '৪৬');
      expect(BengaliNumeralConverter.toBengaliNumber(5423), '৫,৪২৩');
    });

    test('converts BCS source tags to clean Bengali titles', () {
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
}
