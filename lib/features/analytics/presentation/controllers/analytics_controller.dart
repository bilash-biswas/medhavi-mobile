import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubjectPerformance {
  final String subjectId;
  final String name;
  final int solved;
  final int correct;
  final double accuracy; // 0.0 to 1.0

  const SubjectPerformance({
    required this.subjectId,
    required this.name,
    required this.solved,
    required this.correct,
    required this.accuracy,
  });
}

class AnalyticsState {
  final int totalSolved;
  final int totalCorrect;
  final int totalIncorrect;
  final int mistakesRectified;
  final int streakDays;
  final double overallAccuracy;
  final List<int> weeklyTrend; // Mon - Sun
  final List<SubjectPerformance> subjects;

  const AnalyticsState({
    required this.totalSolved,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.mistakesRectified,
    required this.streakDays,
    required this.overallAccuracy,
    required this.weeklyTrend,
    required this.subjects,
  });
}

class AnalyticsController extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    const total = 520;
    const correct = 405;
    const incorrect = 115;
    const rectified = 48;

    return const AnalyticsState(
      totalSolved: total,
      totalCorrect: correct,
      totalIncorrect: incorrect,
      mistakesRectified: rectified,
      streakDays: 7,
      overallAccuracy: correct / total,
      weeklyTrend: [45, 60, 80, 50, 95, 110, 80],
      subjects: [
        SubjectPerformance(
          subjectId: 'sub_bcs_mental_ability',
          name: 'মানসিক দক্ষতা',
          solved: 65,
          correct: 56,
          accuracy: 0.86,
        ),
        SubjectPerformance(
          subjectId: 'sub_bcs_bangla',
          name: 'বাংলা ভাষা ও সাহিত্য',
          solved: 110,
          correct: 90,
          accuracy: 0.81,
        ),
        SubjectPerformance(
          subjectId: 'sub_bcs_ethics',
          name: 'নৈতিকতা, মূল্যবোধ ও সুশাসন',
          solved: 40,
          correct: 32,
          accuracy: 0.80,
        ),
        SubjectPerformance(
          subjectId: 'sub_bcs_bd_affairs',
          name: 'বাংলাদেশ বিষয়াবলী',
          solved: 95,
          correct: 73,
          accuracy: 0.77,
        ),
        SubjectPerformance(
          subjectId: 'sub_bcs_math',
          name: 'গাণিতিক যুক্তি',
          solved: 55,
          correct: 41,
          accuracy: 0.75,
        ),
        SubjectPerformance(
          subjectId: 'sub_bcs_ict',
          name: 'কম্পিউটার ও তথ্যপ্রযুক্তি',
          solved: 45,
          correct: 32,
          accuracy: 0.71,
        ),
        SubjectPerformance(
          subjectId: 'sub_bcs_intl_affairs',
          name: 'আন্তর্জাতিক বিষয়াবলী',
          solved: 50,
          correct: 35,
          accuracy: 0.70,
        ),
        SubjectPerformance(
          subjectId: 'sub_bcs_english',
          name: 'ইংরেজি ভাষা ও সাহিত্য',
          solved: 35,
          correct: 23,
          accuracy: 0.65,
        ),
        SubjectPerformance(
          subjectId: 'sub_bcs_geography',
          name: 'ভূগোল, পরিবেশ ও দুর্যোগ',
          solved: 15,
          correct: 9,
          accuracy: 0.60,
        ),
        SubjectPerformance(
          subjectId: 'sub_bcs_science',
          name: 'সাধারণ বিজ্ঞান',
          solved: 10,
          correct: 5,
          accuracy: 0.50,
        ),
      ],
    );
  }
}

final analyticsControllerProvider =
    NotifierProvider<AnalyticsController, AnalyticsState>(
        AnalyticsController.new);
