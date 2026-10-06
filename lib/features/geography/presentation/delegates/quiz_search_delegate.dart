import 'package:basics/features/geography/domain/utils/answer_normalizer.dart';
import 'package:flutter/material.dart';
import 'package:basics/features/geography/domain/models/geography_quiz.dart';
import 'package:basics/features/geography/presentation/screens/game_screen.dart';

class QuizSearchDelegate extends SearchDelegate<void> {
  final List<GeographyQuiz> quizzes;
  QuizSearchDelegate(this.quizzes);
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back),
  );
  @override
  Widget buildResults(BuildContext context) => _results(context);
  @override
  Widget buildSuggestions(BuildContext context) => _results(context);
  Widget _results(BuildContext context) {
    final matches = quizzes
        .where(
          (quiz) =>
              normalizeAnswer(quiz.title).contains(normalizeAnswer(query)),
        )
        .toList();
    if (matches.isEmpty) {
      return const Center(child: Text('Nenhum jogo encontrado.'));
    }
    return ListView(
      children: matches
          .map(
            (quiz) => ListTile(
              leading: const Icon(Icons.public),
              title: Text(quiz.title),
              subtitle: Text(quiz.description),
              onTap: () {
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(quizId: quiz.id),
                  ),
                );
              },
            ),
          )
          .toList(),
    );
  }
}
