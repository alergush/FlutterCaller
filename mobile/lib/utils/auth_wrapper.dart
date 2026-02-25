import 'package:flutter/material.dart';
import 'package:flutter_caller/screens/auth_screen.dart';
import 'package:flutter_caller/screens/sign_up_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool showSignIn = true;

  void toggleView() {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();

    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showSignIn
        ? AuthScreen(key: const ValueKey('AuthScreen'), onTapSignUp: toggleView)
        : SignUpScreen(
            key: const ValueKey('SignUpScreen'),
            onTapLogIn: toggleView,
          );
  }
}
