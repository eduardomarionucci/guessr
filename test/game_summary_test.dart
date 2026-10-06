import 'package:basics/features/geography/domain/models/quiz_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:basics/features/geography/presentation/screens/game_screen.dart';
import 'package:basics/features/geography/presentation/screens/game_summary_screen.dart';
import 'package:basics/features/geography/domain/models/geography_quiz.dart';

void main() {
  GeographyQuiz quiz() => GeographyQuiz(
    id: 'capitais',
    title: 'Capitais do Brasil',
    description: '',
    hint: 'Capital',
    duration: 60,
    items: [QuizItem(answer: 'Brasília', clue: 'Distrito Federal')],
  );

  testWidgets('Completed game replaces play screen and returns to home', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    loader: (_) async => quiz(),
                    save: (_, _) async {},
                  ),
                ),
              ),
              child: const Text('Início dos jogos'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Início dos jogos'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Brasilia');
    await tester.pumpAndSettle();
    expect(find.byType(GameSummaryScreen), findsOneWidget);
    expect(find.byType(GameScreen), findsNothing);
    expect(find.text('Aproveitamento: 100%'), findsOneWidget);
    await tester.tap(find.text('Voltar para a tela principal'));
    await tester.pumpAndSettle();
    expect(find.text('Início dos jogos'), findsOneWidget);
    expect(find.byType(GameSummaryScreen), findsNothing);
  });

  testWidgets('Summary shows missed answers and failed persistence', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GameSummaryScreen(
          quiz: quiz(),
          secondsRemaining: 0,
          won: false,
          saved: Future.value(false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aproveitamento: 0%'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
    expect(
      find.text('Não foi possível salvar o resultado. Confira sua conexão.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Brasília'), 200);
    expect(find.text('Brasília'), findsOneWidget);
    expect(find.textContaining('Não encontrada'), findsOneWidget);
  });
}
