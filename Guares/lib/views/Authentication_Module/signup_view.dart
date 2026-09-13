import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guares/Auth/Bloc/auth_bloc.dart';
import 'package:guares/Auth/Bloc/auth_event.dart';
import 'package:guares/Auth/Bloc/auth_state.dart';
import 'package:guares/Auth/services/theme/app_colors.dart';
import 'package:guares/Utils/dialog_helper.dart';
import 'package:guares/views/Authentication_Module/complete_profile_view.dart';
import 'package:guares/views/Authentication_Module/login_view.dart';
import 'package:guares/views/Authentication_Module/verify_email_view.dart';
import 'package:guares/views/Authentication_Module/welcome_view.dart';
import 'package:guares/views/main_navigation_view.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isChecked = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  double _passwordStrength = 0;

  String _passwordStrengthText = "Weak";

  Color _passwordStrengthColor = Colors.red;

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;

    double strength = 0;

    if (password.length >= 6) {
      strength += 0.25;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      strength += 0.25;
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      strength += 0.25;
    }

    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength += 0.25;
    }

    setState(() {
      _passwordStrength = strength;

      if (strength <= .25) {
        _passwordStrengthText = "Weak";
        _passwordStrengthColor = Colors.red;
      } else if (strength <= .50) {
        _passwordStrengthText = "Medium";
        _passwordStrengthColor = Colors.orange;
      } else if (strength <= .75) {
        _passwordStrengthText = "Good";
        _passwordStrengthColor = Colors.amber;
      } else {
        _passwordStrengthText = "Strong";
        _passwordStrengthColor = AppColors.primary;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          DialogHelper.hideLoading(context);
          DialogHelper.showError(
            context,
            title: "Signup Failed",
            message: state.message,
          );
        }

        if (state is EmailNotVerified) {
          DialogHelper.hideLoading(context);

          DialogHelper.showSuccess(
            context,
            title: "Account Created!",
            message:
                "We've sent a verification email. Please verify your email to continue.",
            buttonText: "Continue",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const VerifyEmailView()),
              );
            },
          );
        }

        // Social sign-in (e.g. Google) for a new user -> finish profile setup.
        if (state is ProfileIncomplete) {
          DialogHelper.hideLoading(context);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompleteProfileView()),
          );
        }

        // Social sign-in for an existing, fully set up user -> go to app.
        if (state is Authenticated) {
          DialogHelper.hideLoading(context);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationView()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Top Row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WelcomeView(),
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
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const SizedBox(
                        height: 7,
                        width: 25,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.card),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const SizedBox(
                        height: 7,
                        width: 25,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.card),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 45),

                  const Text(
                    "STEP 1 OF 3",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Create your\n",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "Guares",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 45),

                  const Text(
                    "Email",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your email";
                      }

                      if (!RegExp(
                        r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return "Please enter a valid email";
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: .45),
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

                  const SizedBox(height: 25),

                  const Text(
                    "Password",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a password";
                      }

                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: .45),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: _passwordStrength,
                    color: _passwordStrengthColor,
                    backgroundColor: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    minHeight: 6,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _passwordStrengthText,
                    style: TextStyle(
                      color: _passwordStrengthColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Confirm password",
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: .45),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value!;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "I agree to the Terms of Service and Privacy Policy.",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
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
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  if (!_isChecked) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please accept the Terms & Privacy Policy.",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  context.read<AuthBloc>().add(
                                    SignupRequested(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
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
                          child: state is AuthLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 35),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: .2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "OR Sign Up with",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .6),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: .2),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return socialButton(
                            "assets/google.png",
                            state is AuthLoading
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                      GoogleSignInRequested(),
                                    );
                                  },
                          );
                        },
                      ),

                      socialButton("assets/apple.png", () {
                        DialogHelper.showComingSoon(
                          context,
                          feature: "Sign up with Apple",
                        );
                      }),

                      socialButton("assets/facebook.png", () {
                        DialogHelper.showComingSoon(
                          context,
                          feature: "Sign up with Facebook",
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 45),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: "Log In",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginView(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget socialButton(String image, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          height: 62,
          width: 62,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(image),
          ),
        ),
      ),
    );
  }
}
