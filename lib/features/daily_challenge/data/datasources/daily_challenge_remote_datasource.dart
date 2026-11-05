import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medhavi_mobile/features/question_bank/domain/entities/question_entity.dart';

final dailyChallengeRemoteDataSourceProvider =
    Provider<DailyChallengeRemoteDataSource>((ref) {
  return DailyChallengeRemoteDataSourceImpl(FirebaseFirestore.instance);
});

abstract class DailyChallengeRemoteDataSource {
  Future<List<QuestionEntity>> getTodayDailyQuestions(String dateStr);
  Future<bool> hasUserCompletedDailyToday(String userId, String dateStr);
  Future<Map<String, dynamic>> recordDailyAttempt({
    required String userId,
    required String dateStr,
    required int score,
    required int totalQuestions,
    required int durationSeconds,
    required List<Map<String, dynamic>> answers,
  });
}

class DailyChallengeRemoteDataSourceImpl
    implements DailyChallengeRemoteDataSource {
  final FirebaseFirestore _firestore;

  DailyChallengeRemoteDataSourceImpl(this._firestore);

  /// Deterministic hash matching Web implementation
  int _getDateSeed(String dateStr) {
    int hash = 0;
    for (int i = 0; i < dateStr.length; i++) {
      hash = (hash << 5) - hash + dateStr.codeUnitAt(i);
      hash |= 0;
    }
    return hash.abs();
  }

  /// 5 Core BPSC Subject Pillars matching Web
  List<String> _getDailySubjectPillars(String dateStr) {
    final seed = _getDateSeed(dateStr);
    final p1 = seed % 2 == 0 ? 'sub_bcs_bangla' : 'sub_bcs_english';
    final p2 = 'sub_bcs_bd_affairs';
    final p3 = (seed >> 2) % 2 == 0 ? 'sub_bcs_intl_affairs' : 'sub_bcs_geography';
    final p4 = (seed >> 4) % 2 == 0 ? 'sub_bcs_math' : 'sub_bcs_science';

    const appliedPool = [
      'sub_bcs_ict',
      'sub_bcs_mental_ability',
      'sub_bcs_ethics',
    ];
    final p5 = appliedPool[(seed >> 6) % appliedPool.length];

    return [p1, p2, p3, p4, p5];
  }

  @override
  Future<List<QuestionEntity>> getTodayDailyQuestions(String dateStr) async {
    // 1. Try reading from Firestore (check both dailyChallenges and legacy daily_challenges)
    try {
      DocumentSnapshot<Map<String, dynamic>>? docSnap;
      try {
        docSnap = await _firestore.collection('dailyChallenges').doc(dateStr).get();
        if (!docSnap.exists) {
          docSnap = await _firestore.collection('daily_challenges').doc(dateStr).get();
        }
      } catch (e) {
        debugPrint('Notice: Error reading dailyChallenge doc from Firestore ($e).');
      }

      if (docSnap != null && docSnap.exists && docSnap.data() != null) {
        final data = docSnap.data()!;
        final questionIds = (data['questionIds'] as List<dynamic>? ?? [])
            .map((id) => id.toString())
            .toList();

        if (questionIds.isNotEmpty) {
          final fetched = <QuestionEntity>[];
          for (final qId in questionIds) {
            try {
              final qDoc = await _firestore.collection('questions').doc(qId).get();
              if (qDoc.exists && qDoc.data() != null) {
                fetched.add(QuestionEntity.fromFirestore(qDoc.id, qDoc.data()!));
              }
            } catch (_) {}
          }
          if (fetched.length >= 5) {
            return fetched;
          }
        }
      }
    } catch (_) {}

    // 2. Generate deterministically across 5 pillars from Firestore if quota/network permits
    final pillars = _getDailySubjectPillars(dateStr);
    final seed = _getDateSeed(dateStr);
    final selectedQuestions = <QuestionEntity>[];

    try {
      for (int i = 0; i < pillars.length; i++) {
        final subjectId = pillars[i];
        try {
          final snap = await _firestore
              .collection('questions')
              .where('status', isEqualTo: 'published')
              .where('subjectId', isEqualTo: subjectId)
              .limit(25)
              .get();

          if (snap.docs.isEmpty) continue;

          final docs = snap.docs
              .map((d) => QuestionEntity.fromFirestore(d.id, d.data()))
              .toList();

          final verified = docs.where((q) => q.adminVerified).toList();
          final pool = verified.isNotEmpty ? verified : docs;

          final pickIndex = (seed + i * 13) % pool.length;
          selectedQuestions.add(pool[pickIndex]);
        } catch (_) {}
      }

      // Fallback if less than 5 questions from pillars
      if (selectedQuestions.length < 5) {
        try {
          final fallbackSnap = await _firestore
              .collection('questions')
              .where('status', isEqualTo: 'published')
              .limit(15)
              .get();

          final existingIds = selectedQuestions.map((q) => q.id).toSet();
          for (final d in fallbackSnap.docs) {
            if (!existingIds.contains(d.id)) {
              selectedQuestions.add(QuestionEntity.fromFirestore(d.id, d.data()));
              if (selectedQuestions.length >= 5) break;
            }
          }
        } catch (_) {}
      }

      // If successfully fetched 5 questions, try saving to Firestore for web/mobile sync
      if (selectedQuestions.length >= 5) {
        try {
          await _firestore.collection('dailyChallenges').doc(dateStr).set({
            'id': dateStr,
            'date': dateStr,
            'questionIds': selectedQuestions.map((q) => q.id).toList(),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}
        return selectedQuestions;
      }
    } catch (_) {}

    // 3. Resilient Guaranteed Fallback: Deterministic offline verified BCS questions
    // This guarantees the candidate is NEVER blocked by Firestore quota, offline state, or permission errors.
    final offlinePool = _getFallbackDailyQuestions(dateStr);
    if (selectedQuestions.isNotEmpty) {
      final combined = [...selectedQuestions];
      for (final q in offlinePool) {
        if (combined.length >= 5) break;
        if (!combined.any((item) => item.id == q.id)) {
          combined.add(q);
        }
      }
      return combined;
    }

    return offlinePool;
  }

  /// Curated, verified offline fallback questions for zero-failure Daily Challenge
  static List<QuestionEntity> _getFallbackDailyQuestions(String dateStr) {
    int seed = 0;
    for (int i = 0; i < dateStr.length; i++) {
      seed = (seed << 5) - seed + dateStr.codeUnitAt(i);
      seed |= 0;
    }
    final s = seed.abs();

    const poolBangla = [
      QuestionEntity(
        id: 'dc_fb_bn_1',
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
        explanation:
            'মহামহোপাধ্যায় হরপ্রসাদ শাস্ত্রী ১৯০৭ সালে নেপালের রাজদরবারের রয়েল লাইব্রেরি থেকে চর্যাপদের মূল পুঁথি আবিষ্কার করেন। ১৯১৬ সালে বঙ্গীয় সাহিত্য পরিষদ থেকে তা প্রকাশিত হয়।',
        source: '46th-bcs',
        tags: ['46th-bcs', 'bangla'],
        adminVerified: true,
      ),
      QuestionEntity(
        id: 'dc_fb_bn_2',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_bangla',
        question: 'কোন বানানটি শুদ্ধ?',
        options: [
          QuestionOption(id: 'a', text: 'মুহূর্মুহু'),
          QuestionOption(id: 'b', text: 'মুহুর্মুহ'),
          QuestionOption(id: 'c', text: 'মুহূর্মূহু'),
          QuestionOption(id: 'd', text: 'মুহুর্মূহু'),
        ],
        correctOptionId: 'a',
        explanation: 'শুদ্ধ বানান হলো "মুহূর্মুহু" (ম + ু + হ + ূ + র + ্ম + ু + হ + ু)। অর্থ: বারংবার বা ঘনঘন।',
        source: '43rd-bcs',
        tags: ['43rd-bcs', 'bangla'],
        adminVerified: true,
      ),
      QuestionEntity(
        id: 'dc_fb_bn_3',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_bangla',
        question: 'কাজী নজরুল ইসলামের প্রথম প্রকাশিত গ্রন্থ কোনটি?',
        options: [
          QuestionOption(id: 'a', text: 'ব্যথার দান'),
          QuestionOption(id: 'b', text: 'অগ্নি-বীণা'),
          QuestionOption(id: 'c', text: 'রিক্তের বেদন'),
          QuestionOption(id: 'd', text: 'বিষের বাঁশী'),
        ],
        correctOptionId: 'a',
        explanation:
            'নজরুলের প্রথম প্রকাশিত গ্রন্থ গল্পগ্রন্থ "ব্যথার দান" (ফেব্রুয়ারি ১৯২২)। তাঁর প্রথম কাব্যগ্রন্থ "অগ্নি-বীণা" প্রকাশিত হয় অক্টোবর ১৯২২ সালে।',
        source: '44th-bcs',
        tags: ['44th-bcs', 'bangla'],
        adminVerified: true,
      ),
    ];

    const poolEnglish = [
      QuestionEntity(
        id: 'dc_fb_en_1',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_english',
        question: 'Who wrote the play "The Tempest"?',
        options: [
          QuestionOption(id: 'a', text: 'William Shakespeare'),
          QuestionOption(id: 'b', text: 'Christopher Marlowe'),
          QuestionOption(id: 'c', text: 'Ben Jonson'),
          QuestionOption(id: 'd', text: 'John Webster'),
        ],
        correctOptionId: 'a',
        explanation:
            '"The Tempest" is a renowned play written by William Shakespeare, considered one of his last plays and a masterpiece of romance and drama.',
        source: '45th-bcs',
        tags: ['45th-bcs', 'english'],
        adminVerified: true,
      ),
      QuestionEntity(
        id: 'dc_fb_en_2',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_english',
        question: 'What is the meaning of the idiom "A bolt from the blue"?',
        options: [
          QuestionOption(id: 'a', text: 'An unexpected catastrophe or event'),
          QuestionOption(id: 'b', text: 'A heavy lightning strike'),
          QuestionOption(id: 'c', text: 'A completely clear sky'),
          QuestionOption(id: 'd', text: 'A pleasant surprise'),
        ],
        correctOptionId: 'a',
        explanation:
            '"A bolt from the blue" means something sudden, unexpected, and shocking (বিনামেঘে বজ্রপাত)।',
        source: '42nd-bcs',
        tags: ['42nd-bcs', 'english'],
        adminVerified: true,
      ),
      QuestionEntity(
        id: 'dc_fb_en_3',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_english',
        question: 'Choose the correct spelling:',
        options: [
          QuestionOption(id: 'a', text: 'Lieutenant'),
          QuestionOption(id: 'b', text: 'Leftenant'),
          QuestionOption(id: 'c', text: 'Leivtenant'),
          QuestionOption(id: 'd', text: 'Lietenant'),
        ],
        correctOptionId: 'a',
        explanation: 'The correct military rank spelling is "Lieutenant" (L-I-E-U-T-E-N-A-N-T).',
        source: '41st-bcs',
        tags: ['41st-bcs', 'english'],
        adminVerified: true,
      ),
    ];

    const poolMath = [
      QuestionEntity(
        id: 'dc_fb_math_1',
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
        explanation:
            r'আমরা জানি, $a^2 + b^2 = (a+b)^2 - 2ab = (7)^2 - 2(10) = 49 - 20 = 29$',
        source: '45th-bcs',
        tags: ['45th-bcs', 'math'],
        adminVerified: true,
      ),
      QuestionEntity(
        id: 'dc_fb_math_2',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_math',
        question: r'একটি দ্রব্য ৫০০ টাকায় কিনে ৫৫০ টাকায় বিক্রয় করলে শতকরা কত লাভ হবে?',
        options: [
          QuestionOption(id: 'a', text: '১০%'),
          QuestionOption(id: 'b', text: '১২%'),
          QuestionOption(id: 'c', text: '১৫%'),
          QuestionOption(id: 'd', text: '৮%'),
        ],
        correctOptionId: 'a',
        explanation:
            r'লাভ = ৫৫০ - ৫০০ = ৫০ টাকা। অতএব শতকরা লাভ = $\frac{৫০}{৫০০} \times ১০০\% = ১০\%$।',
        source: '44th-bcs',
        tags: ['44th-bcs', 'math'],
        adminVerified: true,
      ),
      QuestionEntity(
        id: 'dc_fb_math_3',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_math',
        question: r'একটি ত্রিভুজের তিন কোণের অনুপাত ১:২:৩ হলে বৃহত্তম কোণটির মান কত?',
        options: [
          QuestionOption(id: 'a', text: '৯০°'),
          QuestionOption(id: 'b', text: '৬০°'),
          QuestionOption(id: 'c', text: '১০০°'),
          QuestionOption(id: 'd', text: '১২০°'),
        ],
        correctOptionId: 'a',
        explanation:
            r'ত্রিভুজের তিন কোণের সমষ্টি ১৮০°। অনুপাতের যোগফল = ১ + ২ + ৩ = ৬। বৃহত্তম কোণ = $১৮০° \times \frac{৩}{৬} = ৯০°$।',
        source: '43rd-bcs',
        tags: ['43rd-bcs', 'math'],
        adminVerified: true,
      ),
    ];

    const poolBd = [
      QuestionEntity(
        id: 'dc_fb_bd_1',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_bd_affairs',
        question: 'ঐতিহাসিক ৭ই মার্চের ভাষণ সংবিধানের কোন তফসিলে অন্তর্ভুক্ত করা হয়েছে?',
        options: [
          QuestionOption(id: 'a', text: 'পঞ্চম তফসিলে'),
          QuestionOption(id: 'b', text: 'ষষ্ঠ তফসিলে'),
          QuestionOption(id: 'c', text: 'সপ্তম তফসিলে'),
          QuestionOption(id: 'd', text: 'চতুর্থ তফসিলে'),
        ],
        correctOptionId: 'a',
        explanation:
            'বঙ্গবন্ধুর ঐতিহাসিক ৭ই মার্চের ভাষণ সংবিধানের ৫ম তফসিলে, ২৬শে মার্চের স্বাধীনতার ঘোষণা ৬ষ্ঠ তফসিলে এবং ১০ই এপ্রিলের স্বাধীনতার ঘোষণাপত্র ৭ম তফসিলে অন্তর্ভুক্ত।',
        source: '46th-bcs',
        tags: ['46th-bcs', 'bangladesh'],
        adminVerified: true,
      ),
      QuestionEntity(
        id: 'dc_fb_bd_2',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_bd_affairs',
        question: 'বাংলাদেশের জাতীয় সংসদের প্রথম স্পিকার কে ছিলেন?',
        options: [
          QuestionOption(id: 'a', text: 'মোহাম্মদ উল্লাহ'),
          QuestionOption(id: 'b', text: 'আব্দুল মালেক উকিল'),
          QuestionOption(id: 'c', text: 'শাহ আব্দুল হামিদ'),
          QuestionOption(id: 'd', text: 'হুমায়ূন রশীদ চৌধুরী'),
        ],
        correctOptionId: 'a',
        explanation:
            'জাতীয় সংসদের প্রথম স্পিকার ছিলেন মোহাম্মদ উল্লাহ (গণপরিষদের প্রথম স্পিকার ছিলেন শাহ আব্দুল হামিদ)।',
        source: '45th-bcs',
        tags: ['45th-bcs', 'bangladesh'],
        adminVerified: true,
      ),
      QuestionEntity(
        id: 'dc_fb_bd_3',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_bd_affairs',
        question: 'মুজিবনগর সরকার কোন তারিখে শপথ গ্রহণ করে?',
        options: [
          QuestionOption(id: 'a', text: '১৭ এপ্রিল ১৯৭১'),
          QuestionOption(id: 'b', text: '১০ এপ্রিল ১৯৭১'),
          QuestionOption(id: 'c', text: '২৫ মার্চ ১৯৭১'),
          QuestionOption(id: 'd', text: '২৬ মার্চ ১৯৭১'),
        ],
        correctOptionId: 'a',
        explanation:
            '১৯৭১ সালের ১০ই এপ্রিল মেহেরপুরের বৈদ্যনাথতলায় মুজিবনগর সরকার গঠিত হয় এবং ১৭ই এপ্রিল আনুষ্ঠানিকভাবে শপথ গ্রহণ করে।',
        source: '44th-bcs',
        tags: ['44th-bcs', 'bangladesh'],
        adminVerified: true,
      ),
    ];

    const poolGeneral = [
      QuestionEntity(
        id: 'dc_fb_gn_1',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_intl_affairs',
        question: 'আন্তর্জাতিক আদালতের (ICJ) প্রধান কার্যালয় কোথায় অবস্থিত?',
        options: [
          QuestionOption(id: 'a', text: 'হেগ, নেদারল্যান্ডস'),
          QuestionOption(id: 'b', text: 'জেনেভা, সুইজারল্যান্ড'),
          QuestionOption(id: 'c', text: 'নিউইয়র্ক, যুক্তরাষ্ট্র'),
          QuestionOption(id: 'd', text: 'ভিয়েনা, অস্ট্রিয়া'),
        ],
        correctOptionId: 'a',
        explanation:
            'জাতিসংঘের প্রধান বিচারিক অঙ্গ আন্তর্জাতিক বিচার আদালত (International Court of Justice - ICJ) নেদারল্যান্ডসের দ্য হেগ শহরের পিস প্যালেসে অবস্থিত।',
        source: '46th-bcs',
        tags: ['46th-bcs', 'international'],
        adminVerified: true,
      ),
      QuestionEntity(
        id: 'dc_fb_gn_2',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_science',
        question: 'সূর্য থেকে পৃথিবীতে আলো পৌঁছাতে গড়ে কত সময় লাগে?',
        options: [
          QuestionOption(id: 'a', text: '৮ মিনিট ১৯ সেকেন্ড'),
          QuestionOption(id: 'b', text: '১০ মিনিট'),
          QuestionOption(id: 'c', text: '৫ মিনিট ২০ সেকেন্ড'),
          QuestionOption(id: 'd', text: '৮ মিনিট ৫০ সেকেন্ড'),
        ],
        correctOptionId: 'a',
        explanation:
            'সূর্য থেকে পৃথিবীর গড় দূরত্ব প্রায় ১৫ কোটি কিলোমিটার। আলোর গতি প্রতি সেকেন্ডে প্রায় ৩ লাখ কিমি হওয়ায় পৃথিবীতে আলো আসতে প্রায় ৫০০ সেকেন্ড বা ৮ মিনিট ১৯ সেকেন্ড সময় লাগে।',
        source: '43rd-bcs',
        tags: ['43rd-bcs', 'science'],
        adminVerified: true,
      ),
      QuestionEntity(
        id: 'dc_fb_gn_3',
        examId: 'exam_bcs',
        subjectId: 'sub_bcs_ict',
        question: 'কম্পিউটারের প্রধান স্থায়ী মেমোরি কোনটি?',
        options: [
          QuestionOption(id: 'a', text: 'ROM (Read Only Memory)'),
          QuestionOption(id: 'b', text: 'RAM (Random Access Memory)'),
          QuestionOption(id: 'c', text: 'Cache Memory'),
          QuestionOption(id: 'd', text: 'Virtual Memory'),
        ],
        correctOptionId: 'a',
        explanation:
            'ROM (Read Only Memory) হলো নন-ভোলাটাইল বা স্থায়ী মেমোরি, বিদ্যুৎ চলে গেলেও এতে সংরক্ষিত ডেটা মুছে যায় না। অপরদিকে RAM হলো অস্থায়ী মেমোরি।',
        source: '45th-bcs',
        tags: ['45th-bcs', 'ict'],
        adminVerified: true,
      ),
    ];

    return [
      poolBangla[s % poolBangla.length],
      poolEnglish[(s >> 2) % poolEnglish.length],
      poolMath[(s >> 4) % poolMath.length],
      poolBd[(s >> 6) % poolBd.length],
      poolGeneral[(s >> 8) % poolGeneral.length],
    ];
  }

  @override
  Future<bool> hasUserCompletedDailyToday(String userId, String dateStr) async {
    try {
      final snap = await _firestore
          .collection('attempts')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'daily')
          .where('date', isEqualTo: dateStr)
          .limit(1)
          .get();

      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> recordDailyAttempt({
    required String userId,
    required String dateStr,
    required int score,
    required int totalQuestions,
    required int durationSeconds,
    required List<Map<String, dynamic>> answers,
  }) async {
    // 1. Record Attempt in Firestore
    final attemptRef = _firestore.collection('attempts').doc();
    await attemptRef.set({
      'userId': userId,
      'type': 'daily',
      'date': dateStr,
      'score': score,
      'totalQuestions': totalQuestions,
      'durationSeconds': durationSeconds,
      'answers': answers,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Update Streak on users/{uid}
    int newStreak = 1;
    int longestStreak = 1;

    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userSnap = await userRef.get();
      final userData = userSnap.data() ?? {};

      final storedCurrent = (userData['currentStreak'] as num?)?.toInt() ?? 0;
      final storedLongest = (userData['longestStreak'] as num?)?.toInt() ?? 0;
      final lastPracticeDate = userData['lastPracticeDate'] as String?;

      if (lastPracticeDate != null && lastPracticeDate.trim().isNotEmpty) {
        if (lastPracticeDate.trim() == dateStr) {
          newStreak = storedCurrent < 1 ? 1 : storedCurrent;
        } else {
          final parsedLast = DateTime.tryParse('${lastPracticeDate.trim()}T00:00:00Z');
          final todayParsed = DateTime.tryParse('${dateStr.trim()}T00:00:00Z');
          if (parsedLast != null && todayParsed != null) {
            final diffDays = todayParsed.difference(parsedLast).inDays;
            if (diffDays == 1) {
              newStreak = storedCurrent + 1;
            } else {
              newStreak = 1;
            }
          }
        }
      }

      longestStreak = newStreak > storedLongest ? newStreak : storedLongest;

      await userRef.set({
        'currentStreak': newStreak,
        'longestStreak': longestStreak,
        'lastPracticeDate': dateStr,
        'lastActiveDate': dateStr,
        'totalDailyCompleted': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (_) {
      // non-blocking
    }

    return {
      'attemptId': attemptRef.id,
      'currentStreak': newStreak,
      'longestStreak': longestStreak,
    };
  }
}
