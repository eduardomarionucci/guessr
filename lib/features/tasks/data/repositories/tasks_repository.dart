import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:basics/core/data/firebase_user_scope.dart';

class TasksRepository {
  CollectionReference<Map<String, dynamic>> get _tasks =>
      currentUserDocument().collection('tasks');

  Stream<List<Map<String, dynamic>>> watchTasks() => _tasks
      .orderBy('createdAt')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
      );

  Future<void> addTask(String title) async {
    await _tasks.add({
      'title': title.trim(),
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTask(String id, bool completed) =>
      _tasks.doc(id).update({'completed': completed});

  Future<void> deleteTask(String id) => _tasks.doc(id).delete();
}
