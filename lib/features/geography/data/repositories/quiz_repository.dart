import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:basics/core/data/firebase_user_scope.dart';
import 'package:basics/features/geography/data/services/ibge_service.dart';
import 'package:basics/features/geography/domain/models/geography_quiz.dart';

class QuizRepository {
  static const capitalsId = 'capitais-do-brasil';

  CollectionReference<Map<String, dynamic>> get _quizzes =>
      currentUserDocument().collection('quizzes');

  Future<GeographyQuiz> _loadCapitals() async {
    final doc = await FirebaseFirestore.instance
        .collection('quiz_catalog')
        .doc(capitalsId)
        .get();
    if (!doc.exists) {
      throw StateError('Importe quiz_catalog/capitais-do-brasil no Firestore.');
    }
    return GeographyQuiz.fromCapitalsDocument(doc.data()!);
  }

  Future<List<GeographyQuiz>> loadCatalog() async {
    await _prepareCatalog();
    final snapshot = await _quizzes.get();
    // Documentos pessoais antigos de capitais não substituem o catálogo compartilhado.
    final quizzes = snapshot.docs
        .where((doc) => doc.id != capitalsId)
        .map((doc) => GeographyQuiz.fromMap(doc.id, doc.data()))
        .toList();
    quizzes.add(await _loadCapitals());
    quizzes.sort((a, b) => a.title.compareTo(b.title));
    return quizzes;
  }

  Future<GeographyQuiz> loadQuiz(String id) async {
    if (id == capitalsId) return _loadCapitals();
    final doc = await _quizzes.doc(id).get();
    if (!doc.exists) throw StateError('Jogo não encontrado no Firestore.');
    return GeographyQuiz.fromMap(doc.id, doc.data()!);
  }

  Future<void> _prepareCatalog() async {
    const ids = ['estados-do-brasil', 'regioes-do-brasil'];
    final existing = await Future.wait(ids.map((id) => _quizzes.doc(id).get()));
    if (existing.every((doc) => doc.exists)) return;
    final states = await IbgeService().states();
    final regions = <String, List<String>>{};
    for (final state in states) {
      final region = (state['regiao'] as Map)['nome'] as String;
      regions.putIfAbsent(region, () => []).add(state['nome'] as String);
    }
    final data = <String, Map<String, dynamic>>{
      ids[0]: {
        'title': 'Estados e Distrito Federal',
        'description': 'Reconheça as 27 unidades da federação por suas siglas.',
        'hint': 'Digite o nome da unidade da federação...',
        'duration': 600,
        'items': states
            .map(
              (state) => {
                'answer': state['nome'],
                'clue': 'UF: ${state['sigla']}',
                'aliases': <String>[],
              },
            )
            .toList(),
      },
      ids[1]: {
        'title': 'Regiões do Brasil',
        'description':
            'Identifique as cinco regiões pelas unidades da federação.',
        'hint': 'Digite uma região...',
        'duration': 180,
        'items': regions.entries
            .map(
              (entry) => {
                'answer': entry.key,
                'clue': entry.value.join(', '),
                'aliases': entry.key == 'Centro-Oeste'
                    ? ['Centro Oeste']
                    : <String>[],
              },
            )
            .toList(),
      },
    };
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docs = await Future.wait(
        ids.map((id) => transaction.get(_quizzes.doc(id))),
      );
      for (var i = 0; i < ids.length; i++) {
        if (!docs[i].exists) {
          transaction.set(_quizzes.doc(ids[i]), {
            ...data[ids[i]]!,
            'source': 'IBGE Localidades',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }
}
