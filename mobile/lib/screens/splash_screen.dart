import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/screens/auth_screen.dart';
import 'package:flutter_caller/screens/home_screen.dart';
import 'package:flutter_caller/providers/auth_state_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: authStateAsync.when(
        data: (user) => user != null
            ? const HomeScreen(key: ValueKey('HomeScreen'))
            : const AuthScreen(key: ValueKey('AuthScreen')),
        error: (error, stack) =>
            const Scaffold(body: Center(child: Text("ERROR"))),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
    );
  }
}
