class QuestionOption {
  final String id;
  final String text;

  const QuestionOption({
    required this.id,
    required this.text,
  });

  factory QuestionOption.fromMap(Map<String, dynamic> map) {
    return QuestionOption(
      id: map['id']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
    };
  }
}

class QuestionEntity {
  final String id;
  final String examId;
  final String subjectId;
  final String question;
  final List<QuestionOption> options;
  final String correctOptionId;
  final String explanation;
  final String difficulty;
  final int? year;
  final String? source;
  final List<String> tags;
  final String? imageUrl;
  final String? textEn;

  const QuestionEntity({
    required this.id,
    required this.examId,
    required this.subjectId,
    required this.question,
    required this.options,
    required this.correctOptionId,
    required this.explanation,
    this.difficulty = 'medium',
    this.year,
    this.source,
    this.tags = const [],
    this.imageUrl,
    this.textEn,
  });

  /// Alias getter for question text
  String get text => question;

  factory QuestionEntity.fromFirestore(String id, Map<String, dynamic> data) {
    final rawOptions = data['options'] as List<dynamic>? ?? [];
    final options = rawOptions
        .map((o) => QuestionOption.fromMap(o as Map<String, dynamic>))
        .toList();

    final rawTags = data['tags'] as List<dynamic>? ?? [];
    final tags = rawTags.map((t) => t.toString()).toList();

    return QuestionEntity(
      id: id,
      examId: data['examId']?.toString() ?? 'exam_bcs',
      subjectId: data['subjectId']?.toString() ?? 'sub_bcs_bangla',
      question: data['question']?.toString() ?? data['text']?.toString() ?? '',
      options: options,
      correctOptionId: data['correctOptionId']?.toString() ?? 'a',
      explanation: data['explanation']?.toString() ?? '',
      difficulty: data['difficulty']?.toString() ?? 'medium',
      year: data['year'] is int ? data['year'] : int.tryParse(data['year']?.toString() ?? ''),
      source: data['source']?.toString(),
      tags: tags,
      imageUrl: data['imageUrl']?.toString(),
      textEn: data['textEn']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'subjectId': subjectId,
      'question': question,
      'options': options.map((o) => o.toMap()).toList(),
      'correctOptionId': correctOptionId,
      'explanation': explanation,
      'difficulty': difficulty,
      'year': year,
      'source': source,
      'tags': tags,
      'imageUrl': imageUrl,
      'textEn': textEn,
    };
  }
}
