import 'package:basics/features/geography/domain/models/quiz_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:basics/features/geography/presentation/screens/game_screen.dart';
import 'package:basics/features/geography/domain/models/geography_quiz.dart';

GeographyQuiz sample() => GeographyQuiz(
  id: 'regioes-do-brasil',
  title: 'Regiões',
  description: 'Teste',
  hint: 'Região',
  duration: 3,
  items: [
    QuizItem(
      answer: 'Centro-Oeste',
      clue: 'GO, MT, MS e DF',
      aliases: ['Centro Oeste'],
    ),
  ],
);

void main() {
  test(
    'Answers ignore case, accents, surrounding whitespace and support aliases',
    () {
      final capital = QuizItem(answer: 'São Luís', clue: 'MA');
      expect(capital.matches('  SAO   LUIS  '), isTrue);
      expect(capital.matches('São Paulo'), isFalse);
      expect(sample().items.single.matches('centro oeste'), isTrue);
    },
  );

  test('Invalid empty catalog is rejected', () {
    expect(
      () => GeographyQuiz.fromMap('bad', {'items': [], 'duration': 3}),
      throwsFormatException,
    );
  });

  testWidgets('Loads database quiz, accepts alias and saves completed score', (
    tester,
  ) async {
    final writes = <List<String>>[];
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          quizId: 'regioes-do-brasil',
          loader: (_) async => sample(),
          save: (answers, seconds) async {
            writes.add(answers);
          },
        ),
      ),
    );
    await tester.pump();
    expect(find.text('GO, MT, MS e DF'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Centro Oeste');
    await tester.pumpAndSettle();
    expect(find.text('Parabéns!'), findsOneWidget);
    expect(writes.single, ['Centro-Oeste']);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Resumo do jogo'), findsOneWidget);
    expect(find.text('1 de 1 respostas'), findsOneWidget);
    expect(find.text('Resultado salvo.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Shows load error and allows retry without starting timer', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          loader: (_) async {
            calls++;
            if (calls == 1) throw Exception('offline');
            return sample();
          },
          save: (_, _) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tentar novamente'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();
    await tester.pump();
    expect(find.text('GO, MT, MS e DF'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Timer ends game at zero and saves one result', (tester) async {
    var writes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          loader: (_) async => sample(),
          save: (_, seconds) async {
            expect(seconds, 0);
            writes++;
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Tempo esgotado!'), findsOneWidget);
    expect(find.text('0 de 1 respostas'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('Não encontrada'), 200);
    expect(find.textContaining('Não encontrada'), findsOneWidget);
    expect(writes, 1);
    await tester.pumpWidget(const SizedBox());
  });
}
