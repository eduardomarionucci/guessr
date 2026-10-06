import '../utils/answer_normalizer.dart';

class QuizItem {
  final String answer;
  final String clue;
  final List<String> aliases;
  bool isFound;
  QuizItem({
    required this.answer,
    required this.clue,
    this.aliases = const [],
    this.isFound = false,
  });

  factory QuizItem.fromMap(Map<String, dynamic> data) => QuizItem(
    answer: data['answer'] as String,
    clue: data['clue'] as String,
    aliases: List<String>.from(data['aliases'] ?? const []),
  );
  bool matches(String text) => [
    answer,
    ...aliases,
  ].any((answer) => normalizeAnswer(answer) == normalizeAnswer(text));
}
