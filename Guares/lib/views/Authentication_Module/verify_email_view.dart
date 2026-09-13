import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guares/Auth/Bloc/auth_bloc.dart' show AuthBloc;
import 'package:guares/Auth/Bloc/auth_event.dart';
import 'package:guares/Auth/Bloc/auth_state.dart';
import 'package:guares/Auth/services/theme/app_colors.dart';
import 'package:guares/Utils/dialog_helper.dart';
import 'package:guares/views/Authentication_Module/complete_profile_view.dart';
import 'package:guares/views/Authentication_Module/signup_view.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {

        if (state is AuthFailure) {
          DialogHelper.showError(
            context,
            title: "Verification Failed",
            message: state.message,
          );
        }
        if (state is EmailNotVerified) {
          DialogHelper.showError(
            context,
            title: "Email verification required",
            message:
                "You need to verify your email before proceeding. Please check your inbox and click on the verification link to verify your email address.",
          );
        }
        if (state is ProfileIncomplete) {
          DialogHelper.showSuccess(
            context,
            title: "Email verification successful",
            message:
                "Your email has been verified successfully. You can now proceed to complete your profile.",
            buttonText: "Complete Profile",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CompleteProfileView()),
              );
            },
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
                /// Top Row
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpView(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      height: 7,
                      width: 25,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const SizedBox(
                      height: 7,
                      width: 25,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 5),

                    const SizedBox(
                      height: 7,
                      width: 25,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: AppColors.card),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: 45),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Step 2 of 3",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Image.asset(
                        'assets/email_sent.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      "Almost there",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const Text(
                      "Check your inbox",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Text(
                      "We sent a verification link to arauf@gmail.com",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 58,

                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                      CheckEmailVerificationRequested(),
                                    );
                                  },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.buttonPrimaryText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            child: state is AuthLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "I've Verified - Continue",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            ResendVerificationEmailRequested(),
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
                          "Resend Email",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Center(
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Wrong email address? ",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: "Edit email",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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
