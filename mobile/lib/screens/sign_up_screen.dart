import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({
    super.key,
    required this.onTapLogIn,
  });

  final VoidCallback? onTapLogIn;

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
  static const int _minUsernameLength = 2;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    final isValid = _form.currentState!.validate();

    if (!isValid) return;

    await _signUp();
  }

  Future<void> _signUp() async {
    String email = _emailController.text.trim().toLowerCase();
    String password = _passwordController.text.trim();
    String username = _usernameController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authServiceProvider).signUp(email, password, username);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      _showSnackBar(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
    _isHidenPass = _isLoading ? true : _isHidenPass;
    _isHidenConfPass = _isLoading ? true : _isHidenConfPass;

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
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            label: const Text("Username"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
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
                          enabled: !_isLoading,
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
                          autocorrect: false,
                          validator: (value) {
                            return _validateEmail(value);
                          },
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            label: const Text("Password"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
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
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            label: const Text("Confirm Password"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
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
                            onPressed: () async {
                              HapticFeedback.lightImpact();

                              if (!_isLoading) {
                                await _submit();
                              }
                            },
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: .center,
                                    mainAxisSize: .min,
                                    children: [
                                      const Text("Signing up"),
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
                                HapticFeedback.lightImpact();

                                if (!_isLoading && widget.onTapLogIn != null) {
                                  widget.onTapLogIn!();
                                }
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

    if (value.length < _minUsernameLength) {
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
