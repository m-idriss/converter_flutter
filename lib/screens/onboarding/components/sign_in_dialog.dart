import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:converter_flutter/screens/entryPoint/entry_point.dart';
import 'package:converter_flutter/services/auth_service.dart';

import 'sign_in_form.dart';

void showCustomDialog(BuildContext context, {required ValueChanged onValue}) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, _, _) {
      return const Center(
        child: SignInDialogContent(),
      );
    },
    transitionBuilder: (_, anim, _, child) {
      Tween<Offset> tween = Tween(begin: const Offset(0, -1), end: Offset.zero);

      return SlideTransition(
        position: tween.animate(
          CurvedAnimation(parent: anim, curve: Curves.easeInOut),
        ),
        child: child,
      );
    },
  ).then(onValue);
}

class SignInDialogContent extends StatefulWidget {
  const SignInDialogContent({super.key});

  @override
  State<SignInDialogContent> createState() => _SignInDialogContentState();
}

class _SignInDialogContentState extends State<SignInDialogContent> {
  final AuthService _authService = AuthService();
  bool _isGoogleSignInLoading = false;
  String? _googleSignInError;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleSignInLoading = true;
      _googleSignInError = null;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null && mounted) {
        // Navigate to entry point on success
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const EntryPoint()),
          (route) => false,
        );
      } else if (mounted) {
        // User cancelled sign-in
        setState(() {
          _isGoogleSignInLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isGoogleSignInLoading = false;
          _googleSignInError = _authService.getErrorMessage(e);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGoogleSignInLoading = false;
          _googleSignInError = 'Failed to sign in with Google. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 670,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 30),
            blurRadius: 60,
          ),
          const BoxShadow(
            color: Colors.black45,
            offset: Offset(0, 30),
            blurRadius: 60,
          ),
        ],
      ),
      child: Scaffold(
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: 34,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Sign in to access all features",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SignInForm(),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: Colors.black26,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      "Sign up with Email, Apple or Google",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  if (_googleSignInError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _googleSignInError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        icon: SvgPicture.asset(
                          "assets/icons/email_box.svg",
                          height: 64,
                          width: 64,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        icon: SvgPicture.asset(
                          "assets/icons/apple_box.svg",
                          height: 64,
                          width: 64,
                        ),
                      ),
                      _isGoogleSignInLoading
                          ? const SizedBox(
                              height: 64,
                              width: 64,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : IconButton(
                              onPressed: _handleGoogleSignIn,
                              padding: EdgeInsets.zero,
                              icon: SvgPicture.asset(
                                "assets/icons/google_box.svg",
                                height: 64,
                                width: 64,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: -48,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
