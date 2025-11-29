import 'package:flutter/material.dart';
import '../config/theme.dart';

class BarraProgresso extends StatelessWidget {
  final int etapaAtual;
  final int totalEtapas;

  const BarraProgresso({
    super.key,
    required this.etapaAtual,
    required this.totalEtapas,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(
            totalEtapas,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < totalEtapas - 1 ? 8 : 0,
                ),
                child: _buildStep(index + 1),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Etapa $etapaAtual de $totalEtapas',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(int step) {
    final isCompleted = step < etapaAtual;
    final isActive = step == etapaAtual;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: isCompleted || isActive
            ? AppColors.primaryGold
            : AppColors.border,
      ),
    );
  }
}

