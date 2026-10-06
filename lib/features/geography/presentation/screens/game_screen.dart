import 'dart:async';
import 'package:flutter/material.dart';
import 'package:basics/features/geography/data/repositories/game_result_repository.dart';
import 'package:basics/features/geography/domain/models/geography_quiz.dart';
import 'package:basics/features/geography/data/repositories/quiz_repository.dart';
import 'package:basics/features/geography/presentation/screens/game_summary_screen.dart';

class GameScreen extends StatefulWidget {
  final String quizId;
  final Future<GeographyQuiz> Function(String)? loader;
  final Future<void> Function(List<String>, int)? save;
  const GameScreen({
    super.key,
    this.quizId = 'capitais-do-brasil',
    this.loader,
    this.save,
  });
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GeographyQuiz? _quiz;
  String? _error;
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _finished = false;
  final _controller = TextEditingController();
  final _store = GameResultRepository();
  final _gameId = DateTime.now().microsecondsSinceEpoch.toString();
  Future<void> _pendingSave = Future.value();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final quiz = await (widget.loader ?? QuizRepository().loadQuiz)(
        widget.quizId,
      );
      if (!mounted) return;
      setState(() {
        _quiz = quiz;
        _secondsRemaining = quiz.duration;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _finished) return;
        setState(() => _secondsRemaining--);
        if (_secondsRemaining == 0) _finish(false);
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Não foi possível carregar este jogo do Firestore.',
        );
      }
    }
  }

  Future<bool> _saveProgress() {
    final answers = _quiz!.items
        .where((item) => item.isFound)
        .map((item) => item.answer)
        .toList();
    final seconds = _secondsRemaining;
    // Serializa gravações para uma resposta antiga não substituir a pontuação atual.
    final saved = _pendingSave.then((_) async {
      try {
        if (widget.save != null) {
          await widget.save!(answers, seconds);
        } else {
          await _store.saveGame(
            _gameId,
            answers,
            seconds,
            quizId: widget.quizId,
          );
        }
        return true;
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Não foi possível salvar a pontuação. Confira sua conexão.',
              ),
            ),
          );
        }
        return false;
      }
    });
    _pendingSave = saved.then((_) {});
    return saved;
  }

  void _checkAnswer(String text) {
    if (_finished || _quiz == null || text.trim().isEmpty) return;
    final matches = _quiz!.items
        .where((item) => !item.isFound && item.matches(text))
        .toList();
    if (matches.isEmpty) return;
    setState(() {
      for (final item in matches) {
        item.isFound = true;
      }
      _controller.clear();
    });
    if (_quiz!.items.every((item) => item.isFound)) {
      _finish(true);
    } else {
      _saveProgress();
    }
  }

  void _finish(bool won) {
    if (_finished) return;
    _timer?.cancel();
    setState(() => _finished = true);
    final saved = _saveProgress();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GameSummaryScreen(
          quiz: _quiz!,
          secondsRemaining: _secondsRemaining,
          won: won,
          saved: saved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _quiz;
    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Geografia')),
        body: Center(
          child: _error == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _load,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
        ),
      );
    }
    final score = quiz.items.where((item) => item.isFound).length;
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(quiz.title),
        backgroundColor: const Color(0xFF005587),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: _secondsRemaining < 30
                ? Colors.red.shade700
                : const Color(0xFF1060C3),
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tempo: $minutes:$seconds | Pontos: $score/${quiz.items.length}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _checkAnswer,
              enabled: !_finished,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: quiz.hint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: quiz.items.length,
              itemBuilder: (context, index) {
                final item = quiz.items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(item.isFound ? item.answer : '???'),
                    subtitle: Text(item.clue),
                    trailing: Icon(
                      item.isFound ? Icons.check_circle : Icons.circle_outlined,
                      color: item.isFound ? Colors.green : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
