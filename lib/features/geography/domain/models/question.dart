class Question {
  final String text;
  final List<String> options;
  final int answerIndex;

  Question({
    required this.text,
    required this.options,
    required this.answerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'],
      options: List<String>.from(json['options']),
      answerIndex: json['answerIndex'],
    );
  }
}
