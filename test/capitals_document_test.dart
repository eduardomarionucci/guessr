import 'package:flutter_test/flutter_test.dart';
import 'package:basics/features/geography/domain/models/geography_quiz.dart';

void main() {
  Map<String, dynamic> document() => {
    'title': 'Capitais do banco',
    'description': 'Descrição do banco',
    'hint': 'Dica do banco',
    'duration': 120,
    'capitals': {for (var i = 0; i < 27; i++) 'UF$i': 'Capital $i'},
    'states': {for (var i = 0; i < 27; i++) 'UF$i': 'Estado $i'},
  };
  test('Capitals, clues and settings come from database object', () {
    final data = document();
    final quiz = GeographyQuiz.fromCapitalsDocument(data);
    expect(quiz.items.length, 27);
    expect(quiz.title, 'Capitais do banco');
    expect(quiz.duration, 120);
    expect(
      quiz.items.any(
        (item) =>
            item.answer == 'Capital 3' && item.clue == 'Capital de Estado 3',
      ),
      isTrue,
    );
    (data['capitals'] as Map)['UF3'] = 'Capital editada';
    final edited = GeographyQuiz.fromCapitalsDocument(data);
    expect(
      edited.items.any((item) => item.answer == 'Capital editada'),
      isTrue,
    );
  });
  test('Missing map, missing UF or invalid answer is rejected', () {
    expect(() => GeographyQuiz.fromCapitalsDocument({}), throwsFormatException);
    final data = document();
    (data['capitals'] as Map).remove('UF1');
    expect(
      () => GeographyQuiz.fromCapitalsDocument(data),
      throwsFormatException,
    );
    final invalid = document();
    (invalid['capitals'] as Map)['UF1'] = '';
    expect(
      () => GeographyQuiz.fromCapitalsDocument(invalid),
      throwsFormatException,
    );
  });
}
