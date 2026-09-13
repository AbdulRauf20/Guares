import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guares/Auth/Bloc/auth_bloc.dart';
import 'package:guares/Auth/Bloc/auth_event.dart';
import 'package:guares/Auth/Bloc/auth_state.dart';
import 'package:guares/Auth/services/theme/app_colors.dart';
import 'package:guares/Auth/user_Bloc/user_bloc.dart';
import 'package:guares/Auth/user_Bloc/user_event.dart';
import 'package:guares/Utils/dialog_helper.dart';
import 'package:guares/views/Authentication_Module/complete_profile_view.dart';
import 'package:guares/views/Authentication_Module/verify_email_view.dart';
import 'dart:async';
import 'package:guares/views/Authentication_Module/welcome_view.dart';
import 'package:guares/views/main_navigation_view.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  int filledBoxes = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        filledBoxes = (filledBoxes + 1) % 5;
      });
    });

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      context.read<AuthBloc>().add(CheckAuthStatusRequested());
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeView()),
          );
        } else if (state is EmailNotVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VerifyEmailView()),
          );
        } else if (state is ProfileIncomplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompleteProfileView()),
          );
        } else if (state is Authenticated) {
          context.read<UserBloc>().add(LoadUserRequested());

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationView()),
          );
        } else if (state is AuthFailure) {
          DialogHelper.showError(
            context,
            title: "Login Failed",
            message: state.message,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Guares Background

        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                // Logo
                SizedBox(
                  height: 175,
                  width: 175,
                  child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                ),

                const SizedBox(height: 24),

                // App Name
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'G',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'uares',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                const Text(
                  'Build Better. Every Day.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFCBD5E1),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 40),

                // Contribution Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBox(0),
                    const SizedBox(width: 8),
                    _buildBox(1),
                    const SizedBox(width: 8),
                    _buildBox(2),
                    const SizedBox(width: 8),
                    _buildBox(3),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Contribution Box Widget
  Widget _buildBox(int index) {
    return Container(
      height: 18,
      width: 18,
      decoration: BoxDecoration(
        color: index < filledBoxes
            ? const Color(0xFF22C55E)
            : const Color(0xFF334155),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
