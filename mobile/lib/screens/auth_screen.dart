import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

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
  void initState() {
    super.initState();

    // GoogleSignIn.instance.initialize(
    //   serverClientId:
    //       "603682868214-sh32roipbm9sjc6o33l6ga101v04ngaj.apps.googleusercontent.com",
    // );
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
      await ref
          .read(authProvider)
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          );
    } catch (error) {
      setState(() {
        _isLoadingSignIn = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).clearSnackBars();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          showCloseIcon: true,
          behavior: .floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSignIn = false;
        });
      }
    }
  }

  // Future<void> _signInWithGoogle() async {
  //   setState(() {
  //     _isLoadingSignInGoogle = true;
  //   });

  //   try {
  // final res = await ref
  //     .read(authControllerProvider.notifier)
  //     .signInWithGoogle();

  // if (!res) {
  //   setState(() {
  //     _isLoadingSignInGoogle = false;
  //   });
  //   return;
  // }

  // if (!mounted) return;

  // Navigator.of(context).pushReplacement(
  //   MaterialPageRoute(builder: (ctx) => const HomeScreen()),
  // );
  // } catch (error) {
  //   setState(() {
  //     _isLoadingSignInGoogle = false;
  //   });
  //
  // scaffoldMessenger.currentState?.showSnackBar(
  //   SnackBar(
  //     content: Text(error.toString()),
  //     showCloseIcon: true,
  //   ),
  // );
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingSignInGoogle = false;
  //       });
  //     }
  //   }
  // }

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
                  // Center(
                  //   child: Image.asset(
                  //     'assets/images/logo.png',
                  //     width: 100,
                  //     height: 100,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  const SizedBox(height: 30),

                  const SizedBox(height: 20),
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
                                await _signIn();
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
                                    !_isLoadingSignInGoogle) {
                                  Navigator.of(
                                    context,
                                  ).pushNamedAndRemoveUntil(
                                    '/sign_up_screen',
                                    (route) => false,
                                  );
                                }
                              },
                              child: const Text(
                                "Sign up",
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 24),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: Divider(
                        //         color: Colors.grey,
                        //       ),
                        //     ),
                        //     const SizedBox(width: 12),
                        //     const Text("OR"),
                        //     const SizedBox(width: 12),
                        //     Expanded(
                        //       child: Divider(
                        //         color: Colors.grey,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 36),
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: FloatingActionButton(
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadiusGeometry.circular(16),
                        //     ),
                        //     elevation: 1,
                        //     heroTag: 'fab_sign_in_google',
                        //     onPressed:
                        //         !_isLoadingSignIn && !_isLoadingSignInGoogle
                        //         ? () async {
                        //             HapticFeedback.lightImpact();
                        //             await _signInWithGoogle();
                        //           }
                        //         : null,
                        //     child: Stack(
                        //       alignment: AlignmentGeometry.center,
                        //       children: [
                        //         Padding(
                        //           padding: const EdgeInsets.only(left: 24),
                        //           child: Align(
                        //             alignment: AlignmentGeometry.centerLeft,
                        //             // child: Image.asset(
                        //             //   'assets/images/google.png',
                        //             //   height: 30,
                        //             //   width: 30,
                        //             // ),
                        //             child: const SizedBox(
                        //               height: 30,
                        //               width: 30,
                        //             ),
                        //           ),
                        //         ),
                        //         _isLoadingSignInGoogle
                        //             ? SizedBox(
                        //                 height: 30,
                        //                 width: 30,
                        //                 child: const CircularProgressIndicator(
                        //                   strokeWidth: 2,
                        //                 ),
                        //               )
                        //             : const Text("Sign in with Google"),
                        //       ],
                        //     ),
                        //   ),
                        // ),
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
