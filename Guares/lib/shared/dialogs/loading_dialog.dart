import 'package:flutter/material.dart';
import 'package:guares/Auth/services/theme/app_colors.dart';

class LoadingDialog extends StatelessWidget {
  final String title;
  final String message;

  const LoadingDialog({
    super.key,
    this.title = "Please wait",
    this.message = "We're getting everything ready...",
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 95,
                width: 95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: .08),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .18),
                      blurRadius: 35,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: SizedBox(
                    height: 42,
                    width: 42,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              const SizedBox(height: 20),

              Text(
                "This won't take long.",
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: .85),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    String title = "Please wait",
    String message = "We're getting everything ready...",
  }) {
    showDialog(
      barrierColor: Colors.black.withValues(alpha: .72),
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(title: title, message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
