import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:converter_flutter/screens/entryPoint/entry_point.dart';
import 'package:converter_flutter/services/auth_service.dart';
import 'package:converter_flutter/widgets/error_message_card.dart';

import 'sign_in_form.dart';

void showCustomDialog(BuildContext context, {required ValueChanged onValue}) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (_, _, _) {
      return const Center(
        child: SignInDialogContent(),
      );
    },
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final curvedAnim = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
      );

      return ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnim),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
  ).then(onValue);
}

class SignInDialogContent extends StatefulWidget {
  const SignInDialogContent({super.key});

  @override
  State<SignInDialogContent> createState() => _SignInDialogContentState();
}

class _SignInDialogContentState extends State<SignInDialogContent>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isGoogleSignInLoading = false;
  String? _googleSignInError;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 640,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5C6BC0).withValues(alpha: 0.15),
                offset: const Offset(0, 20),
                blurRadius: 40,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 10),
                blurRadius: 30,
              ),
            ],
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SingleChildScrollView(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Header with gradient text
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ).createShader(bounds),
                            child: const Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 32,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign in to continue your journey",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const SignInForm(),
                          //const SizedBox(height: 24),
                          //_buildDivider(),
                          //const SizedBox(height: 20),
                          Text(
                            "Or continue with",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_googleSignInError != null)
                            ErrorMessageCard(
                              message: _googleSignInError!,
                              margin: const EdgeInsets.only(bottom: 16),
                            ),
                          _buildSocialButtons(),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -52,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF667EEA).withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade300,
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "OR",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: "assets/icons/email_box.svg",
          onPressed: () {},
        ), /*
        const SizedBox(width: 16),
        _buildSocialButton(
          icon: "assets/icons/apple_box.svg",
          onPressed: () {},
        ),*/
        const SizedBox(width: 16),
        _isGoogleSignInLoading
            ? Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                    ),
                  ),
                ),
              )
            : _buildSocialButton(
                icon: "assets/icons/google_box.svg",
                onPressed: _handleGoogleSignIn,
              ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              icon,
              height: 32,
              width: 32,
            ),
          ),
        ),
      ),
    );
  }
}
