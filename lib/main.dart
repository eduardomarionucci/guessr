import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'app/startup_error_app.dart';
import 'core/services/firebase_connection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeFirebase();
  } catch (error) {
    final String details;
    if (error is FirebaseException) {
      details = '${error.plugin}/${error.code}';
    } else if (error is StateError) {
      details = error.message.toString();
    } else {
      details = error.runtimeType.toString();
    }
    debugPrint('Firebase startup failed: $details');
    runApp(StartupErrorApp(details: details));
    return;
  }
  runApp(const JetpunkApp());
}
