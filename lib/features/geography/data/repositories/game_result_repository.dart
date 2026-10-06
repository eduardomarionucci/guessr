import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:basics/core/data/firebase_user_scope.dart';

class GameResultRepository {
  Future<void> saveGame(
    String id,
    List<String> answers,
    int secondsRemaining, {
    required String quizId,
  }) => currentUserDocument().collection('games').doc(id).set({
    'quiz': quizId,
    'answers': answers,
    'score': answers.length,
    'secondsRemaining': secondsRemaining,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
