import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/imovel_detalhes.dart';

class AndamentoObraSection extends StatelessWidget {
  final List<AndamentoObra> andamentoObra;

  const AndamentoObraSection({
    super.key,
    required this.andamentoObra,
  });

  @override
  Widget build(BuildContext context) {
    if (andamentoObra.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.construction_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Andamento da obra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Lista de progresso
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: andamentoObra.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == andamentoObra.length - 1;

              return Column(
                children: [
                  _buildProgressRow(item),
                  if (!isLast) const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(AndamentoObra item) {
    final progress = item.progresso / 100;
    final color = _getColorForProgress(item.progresso);

    return Row(
      children: [
        // Nome (truncado se necessário)
        SizedBox(
          width: 100,
          child: Text(
            item.nome,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        
        // Barra de progresso
        Expanded(
          child: Stack(
            children: [
              // Background
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Progresso
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.8),
                        color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        
        // Porcentagem
        SizedBox(
          width: 48,
          child: Text(
            '${item.progresso} %',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getColorForProgress(int progresso) {
    if (progresso >= 80) {
      return AppColors.success;
    } else if (progresso >= 50) {
      return AppColors.primaryBlue;
    } else if (progresso >= 30) {
      return AppColors.warning;
    } else {
      return AppColors.textSecondary;
    }
  }
}


