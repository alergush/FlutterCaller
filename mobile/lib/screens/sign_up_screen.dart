import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isHidenPass = true;
  bool _isHidenConfPass = true;
  bool _isLoading = false;

  static const int _minPassLength = 6;

  Future<void> _submit(BuildContext context) async {
    // scaffoldMessenger.currentState?.clearSnackBars();

    final isValid = _form.currentState!.validate();

    if (!isValid) return;

    await _createUser(context);
  }

  Future<void> _createUser(BuildContext context) async {
    // String email = _emailController.text.trim().toLowerCase();
    // String password = _passwordController.text.trim();
    // String username = _usernameController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // await ref
      //     .read(authControllerProvider.notifier)
      //     .signUp(username, email, password);

      // if (!context.mounted) return;

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (ctx) => const HomeScreen()),
      // );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      // scaffoldMessenger.currentState?.showSnackBar(
      //   SnackBar(
      //     content: Text(error.toString()),
      //     showCloseIcon: true,
      //   ),
      // );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Caller'),
        centerTitle: true,
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 60,
                left: 16,
                right: 16,
                bottom: 32,
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Create Account",
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      "Complete to start",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 56),
                  Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            label: const Text("Username"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _usernameController.text = "";
                              },

                              icon: const Icon(Icons.highlight_off_rounded),
                            ),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            return _validateUsername(value);
                          },
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            label: const Text("Email"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _emailController.text = "";
                              },
                              icon: const Icon(Icons.highlight_off_rounded),
                            ),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          validator: (value) {
                            return _validateEmail(value);
                          },
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            label: const Text("Password"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isHidenPass = !_isHidenPass;
                                });
                              },
                              icon: Icon(
                                _isHidenPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.key),
                          ),
                          obscureText: _isHidenPass,
                          autocorrect: false,
                          validator: (value) {
                            return _validatePassword(value);
                          },
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            label: const Text("Confirm Password"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isHidenConfPass = !_isHidenConfPass;
                                });
                              },
                              icon: Icon(
                                _isHidenConfPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.key),
                          ),
                          obscureText: _isHidenConfPass,
                          autocorrect: false,
                          validator: (value) {
                            return _validateConfirmPassword(value);
                          },
                        ),
                        const SizedBox(height: 56),
                        SizedBox(
                          width: double.infinity,
                          child: FloatingActionButton(
                            elevation: 1,
                            heroTag: 'fab_sign_up',
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    HapticFeedback.lightImpact();
                                    await _submit(context);
                                  },
                            child: _isLoading
                                ? SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Sign up"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            const SizedBox(width: 2),
                            TextButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushNamedAndRemoveUntil(
                                  '/auth_screen',
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                "Log in",
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

  String? _validateUsername(String? input) {
    String? value = input?.trim();

    if (value == null || value.isEmpty) {
      return 'Required';
    }

    const String lettersAndSpaces = r'^[a-zA-Z\s]+$';

    if (!RegExp(lettersAndSpaces).hasMatch(value)) {
      return 'Can only contain letters and spaces.';
    }

    if (value.length < 2) {
      return 'Username too short.';
    }

    return null;
  }

  String? _validateEmail(String? input) {
    String? value = input?.trim().toLowerCase();

    if (value == null || value.isEmpty) {
      return 'Required';
    }
    final bool emailValid = RegExp(
      r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value);

    if (!emailValid) {
      return 'Invalid Email Format';
    }

    return null;
  }

  String? _validatePassword(String? input) {
    String? value = input?.trim();

    if (value == null || value.isEmpty) {
      return 'Required';
    }

    if (value.length < _minPassLength) {
      return 'The password must contain at least 6 characters.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? input) {
    String? value = input?.trim();

    if (value == null || value.isEmpty) {
      return 'Required';
    }

    if (value != _passwordController.text.trim()) {
      return 'Passwords don\'t match.';
    }

    return null;
  }
}
