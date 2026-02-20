import 'package:flutter/material.dart';
import 'package:flutter_caller/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/config/firebase_options.dart';

// import 'package:flutter/scheduler.dart' show timeDilation;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // timeDilation = 20;

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
