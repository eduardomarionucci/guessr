import 'package:flutter/material.dart';
import 'package:basics/features/geography/domain/models/geography_quiz.dart';

class GameSummaryScreen extends StatelessWidget {
  final GeographyQuiz quiz;
  final int secondsRemaining;
  final bool won;
  final Future<bool> saved;
  const GameSummaryScreen({
    super.key,
    required this.quiz,
    required this.secondsRemaining,
    required this.won,
    required this.saved,
  });

  String _time(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final found = quiz.items.where((item) => item.isFound).length;
    final percentage = (found * 100 / quiz.items.length).round();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Resumo do jogo'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF005587),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.home),
            label: const Text('Voltar para a tela principal'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF005587),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: const Color(0xFF1060C3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    won ? Icons.emoji_events : Icons.timer_off,
                    color: Colors.white,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    won ? 'Parabéns!' : 'Tempo esgotado!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quiz.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$found de ${quiz.items.length} respostas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aproveitamento: $percentage%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _detail(
                    'Tempo utilizado',
                    _time(quiz.duration - secondsRemaining),
                  ),
                  const Divider(),
                  _detail('Tempo restante', _time(secondsRemaining)),
                  const Divider(),
                  _detail(
                    'Respostas pendentes',
                    '${quiz.items.length - found}',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: FutureBuilder<bool>(
              future: saved,
              builder: (context, snapshot) => Text(
                snapshot.connectionState != ConnectionState.done
                    ? 'Salvando resultado...'
                    : snapshot.data == true
                    ? 'Resultado salvo.'
                    : 'Não foi possível salvar o resultado. Confira sua conexão.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Text(
            'Detalhes das respostas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final item in quiz.items)
            Card(
              child: ListTile(
                leading: Icon(
                  item.isFound ? Icons.check_circle : Icons.cancel_outlined,
                  color: item.isFound ? Colors.green : Colors.orange.shade800,
                ),
                title: Text(item.answer),
                subtitle: Text(
                  '${item.clue}\n${item.isFound ? 'Encontrada' : 'Não encontrada'}',
                ),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Row(
    children: [
      Expanded(child: Text(label)),
      const SizedBox(width: 12),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}
