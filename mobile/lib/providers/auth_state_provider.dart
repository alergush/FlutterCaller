import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_caller/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authProvider);
  return auth.authStateChanges();
});
