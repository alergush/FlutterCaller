import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({
    super.key,
    required this.onTapSignUp,
  });

  final VoidCallback? onTapSignUp;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordHiden = true;
  bool _isLoadingSignIn = false;
  final _isLoadingSignInGoogle = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    final isValid = _form.currentState!.validate();

    if (!isValid) return;

    await _signIn();
  }

  Future<void> _signIn() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) return;

    setState(() {
      _isLoadingSignIn = true;
    });

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    try {
      await ref.read(authServiceProvider).signIn(email, password);
    } catch (error) {
      setState(() {
        _isLoadingSignIn = false;
      });

      if (!mounted) return;

      _showSnackBar(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSignIn = false;
        });
      }
    }
  }

  void _showSnackBar(String content) {
    ScaffoldMessenger.of(
      context,
    ).clearSnackBars();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(content),
        showCloseIcon: true,
        behavior: .floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isPasswordHiden = _isLoadingSignIn || _isLoadingSignInGoogle
        ? true
        : _isPasswordHiden;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: const Text("Flutter Caller"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: 32,
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Text(
                      "Welcome",
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      "Log in to continue",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          enabled: !_isLoadingSignIn && !_isLoadingSignInGoogle,
                          decoration: InputDecoration(
                            label: const Text("Email"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _emailController.text = "";
                              },
                              icon: const Icon(Icons.highlight_off_rounded),
                            ),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          validator: (value) {
                            return _validateEmail(value);
                          },
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !_isLoadingSignIn && !_isLoadingSignInGoogle,
                          decoration: InputDecoration(
                            label: const Text("Password"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();

                                setState(() {
                                  _isPasswordHiden = !_isPasswordHiden;
                                });
                              },
                              icon: Icon(
                                _isPasswordHiden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.key),
                          ),
                          obscureText: _isPasswordHiden,
                          validator: (value) {
                            return _validatePassword(value);
                          },
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: FloatingActionButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(16),
                            ),
                            elevation: 1,
                            heroTag: 'fab_sign_in',
                            onPressed: () async {
                              HapticFeedback.lightImpact();

                              if (!_isLoadingSignIn &&
                                  !_isLoadingSignInGoogle) {
                                await _submit();
                              }
                            },
                            child: _isLoadingSignIn
                                ? Row(
                                    mainAxisAlignment: .center,
                                    mainAxisSize: .min,
                                    children: [
                                      const Text("Signing in"),
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text("Sign in"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();

                                if (!_isLoadingSignIn &&
                                    !_isLoadingSignInGoogle &&
                                    widget.onTapSignUp != null) {
                                  widget.onTapSignUp!();
                                }
                              },
                              child: const Text(
                                "Sign up",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? input) {
    String? value = input?.trim();

    if (value == null || value.isEmpty) {
      return 'Required';
    }

    if (!value.contains('@')) {
      return 'Invalid Email';
    }

    return null;
  }

  String? _validatePassword(String? input) {
    String? value = input?.trim();
    if (value == null || value.isEmpty) {
      return 'Required';
    }

    return null;
  }
}
