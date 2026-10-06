import 'quiz_item.dart';

class GeographyQuiz {
  final String id;
  final String title;
  final String description;
  final String hint;
  final int duration;
  final List<QuizItem> items;
  GeographyQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.hint,
    required this.duration,
    required this.items,
  });

  factory GeographyQuiz.fromMap(String id, Map<String, dynamic> data) {
    final items = (data['items'] as List)
        .map((item) => QuizItem.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
    final duration = data['duration'] as int;
    if (items.isEmpty || duration <= 0) {
      throw const FormatException('Jogo sem perguntas ou tempo inválido.');
    }
    return GeographyQuiz(
      id: id,
      title: data['title'] as String,
      description: data['description'] as String,
      hint: data['hint'] as String,
      duration: duration,
      items: items,
    );
  }

  factory GeographyQuiz.fromCapitalsDocument(Map<String, dynamic> data) {
    final capitals = data['capitals'];
    final states = data['states'];
    if (capitals is! Map ||
        states is! Map ||
        capitals.length != 27 ||
        states.length != 27 ||
        !states.keys.every(capitals.containsKey)) {
      throw const FormatException('Documento de capitais incompleto.');
    }
    final items = <Map<String, dynamic>>[];
    for (final uf in states.keys) {
      final answer = capitals[uf];
      final state = states[uf];
      if (answer is! String ||
          answer.trim().isEmpty ||
          state is! String ||
          state.trim().isEmpty) {
        throw const FormatException('Capital ou UF inválida no Firestore.');
      }
      items.add({
        'answer': answer,
        'clue': 'Capital de $state',
        'aliases': <String>[],
      });
    }
    items.sort((a, b) => (a['clue'] as String).compareTo(b['clue'] as String));
    return GeographyQuiz.fromMap('capitais-do-brasil', {
      ...data,
      'items': items,
    });
  }
}
