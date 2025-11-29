import 'package:flutter/material.dart';
import '../config/theme.dart';

class AcoesBar extends StatelessWidget {
  final VoidCallback onPdfTap;
  final VoidCallback onEspelhoVendasTap;
  final VoidCallback? onCompartilharTap;

  const AcoesBar({
    super.key,
    required this.onPdfTap,
    required this.onEspelhoVendasTap,
    this.onCompartilharTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Botão PDF
          Expanded(
            child: _buildActionButton(
              icon: Icons.picture_as_pdf_outlined,
              label: 'PDF',
              onTap: onPdfTap,
              isPrimary: true,
            ),
          ),
          const SizedBox(width: 8),
          // Botão Espelho de Vendas
          Expanded(
            flex: 2,
            child: _buildActionButton(
              icon: Icons.monetization_on_outlined,
              label: 'Espelho de vendas',
              onTap: onEspelhoVendasTap,
              isPrimary: true,
            ),
          ),
          const SizedBox(width: 8),
          // Botão Compartilhar
          _buildCircleButton(
            icon: Icons.share_outlined,
            onTap: onCompartilharTap ?? () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary ? AppColors.primaryBlue : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isPrimary ? null : Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}

