import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

DocumentReference<Map<String, dynamic>> currentUserDocument() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw StateError('Sessão indisponível.');
  return FirebaseFirestore.instance.collection('users').doc(user.uid);
}
