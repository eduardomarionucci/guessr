import 'package:flutter/material.dart';
import 'package:basics/core/presentation/widgets/app_logo.dart';
import 'package:basics/features/geography/presentation/screens/game_screen.dart';
import 'package:basics/features/geography/domain/models/geography_quiz.dart';
import 'package:basics/features/geography/data/repositories/quiz_repository.dart';
import 'package:basics/features/geography/presentation/delegates/quiz_search_delegate.dart';
import 'package:basics/features/tasks/presentation/screens/tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<GeographyQuiz>> _catalog;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _catalog = QuizRepository().loadCatalog();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),
    appBar: AppBar(
      title: const AppLogo(width: 96),
      centerTitle: true,
      backgroundColor: const Color(0xFF005587),
      foregroundColor: Colors.white,
    ),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF005587)),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Tarefas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TasksScreen()),
              );
            },
          ),
        ],
      ),
    ),
    body: FutureBuilder<List<GeographyQuiz>>(
      future: _catalog,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Não foi possível carregar os jogos. Confira a conexão e as regras do Firestore. Na primeira abertura, a API do IBGE também precisa estar disponível.',
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => setState(_reload),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final quizzes = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Desafios de geografia',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Buscar jogo',
                  onPressed: () => showSearch(
                    context: context,
                    delegate: QuizSearchDelegate(quizzes),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Atualizar',
                  onPressed: () => setState(_reload),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Explore o Brasil com pistas de estados, capitais e regiões.',
              ),
            ),
            for (final quiz in quizzes)
              Card(
                color: const Color(0xFF1060C3),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.public, color: Colors.white),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'GEOGRAFIA',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          Text(
                            '${quiz.duration ~/ 60}:${(quiz.duration % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        quiz.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${quiz.items.length} respostas',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF005587),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameScreen(quizId: quiz.id),
                            ),
                          ),
                          child: const Text('Jogar agora!'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
