import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guares/Auth/Bloc/auth_bloc.dart';
import 'package:guares/Auth/Bloc/auth_event.dart';
import 'package:guares/Auth/Bloc/auth_state.dart';
import 'package:guares/Auth/services/theme/app_colors.dart';
import 'package:guares/Utils/dialog_helper.dart';
import 'package:guares/views/Authentication_Module/login_view.dart';
import 'package:guares/views/Authentication_Module/reset_email_sent_view.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          DialogHelper.hideLoading(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ResetEmailSentView()),
          );
        }

        if (state is AuthFailure) {
          DialogHelper.hideLoading(context);

          DialogHelper.showError(
            context,
            title: "Reset Failed",
            message: state.message,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      "Reset Password",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 15),
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Image.asset(
                        'assets/lock_in_screen.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 7),
                    const Text(
                      "FORGOT PASSWORD?",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      "No Worries, it happens./n Enter you email and we we'll send you a secure link to reset it",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 15),

                    Form(
                      key: _formKey,

                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required";
                              }

                              if (!value.contains("@")) {
                                return "Enter a valid email";
                              }

                              return null;
                            },

                            style: const TextStyle(color: Colors.white),

                            decoration: InputDecoration(
                              hintText: "Enter your email",

                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                              ),

                              prefixIcon: const Icon(
                                Icons.email_outlined,

                                color: AppColors.primary,
                              ),

                              filled: true,

                              fillColor: AppColors.surface,

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),

                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    const Text(
                      "We'll only email you a reset link - nothing else",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;

                          DialogHelper.showLoading(
                            context,
                            title: "Sending Reset Link",
                            message:
                                "Please wait while we send your password reset email...",
                          );

                          context.read<AuthBloc>().add(
                            ForgotPasswordRequested(
                              email: _emailController.text.trim(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.buttonPrimaryText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Send Reset Link",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
