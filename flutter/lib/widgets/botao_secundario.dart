import 'package:flutter/material.dart';
import '../config/theme.dart';

class BotaoSecundario extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool disabled;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;

  const BotaoSecundario({
    super.key,
    required this.texto,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? AppColors.primaryBlue;
    final foregroundColor = textColor ?? AppColors.primaryBlue;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: disabled || isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: BorderSide(
            color: disabled ? color.withOpacity(0.5) : color,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
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

