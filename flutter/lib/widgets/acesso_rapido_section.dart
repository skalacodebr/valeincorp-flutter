import 'package:flutter/material.dart';
import '../config/theme.dart';

class AcessoRapidoSection extends StatelessWidget {
  final VoidCallback onQrCodeTap;
  final VoidCallback onCompartilharTap;
  final VoidCallback onDocumentosTap;

  const AcessoRapidoSection({
    super.key,
    required this.onQrCodeTap,
    required this.onCompartilharTap,
    required this.onDocumentosTap,
  });

  @override
  Widget build(BuildContext context) {
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
                Icons.flash_on_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Acesso rápido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Cards de ação
        Row(
          children: [
            Expanded(
              child: _buildAcessoCard(
                icon: Icons.qr_code_2_outlined,
                label: 'QR Code',
                onTap: onQrCodeTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAcessoCard(
                icon: Icons.share_outlined,
                label: 'Compartilhar',
                onTap: onCompartilharTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAcessoCard(
                icon: Icons.description_outlined,
                label: 'Documentos',
                onTap: onDocumentosTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcessoCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


