import 'package:flutter/material.dart';
import '../config/theme.dart';

class BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool disabled;
  final IconData? icon;

  const BotaoPrincipal({
    super.key,
    required this.texto,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: disabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryGold.withOpacity(0.5),
          elevation: 4,
          shadowColor: AppColors.primaryGold.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    texto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

