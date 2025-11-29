import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/imovel_detalhes.dart';

class InfoCardFlutuante extends StatelessWidget {
  final ImovelDetalhes imovel;
  final VoidCallback onPdfTap;
  final VoidCallback onEspelhoVendasTap;
  final VoidCallback? onReservaTap;
  final VoidCallback? onCompartilharTap;

  const InfoCardFlutuante({
    super.key,
    required this.imovel,
    required this.onPdfTap,
    required this.onEspelhoVendasTap,
    this.onReservaTap,
    this.onCompartilharTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Informações principais (área, dormitórios, vagas)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Área
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.straighten_outlined,
                    value: _formatArea(),
                    label: 'm²',
                  ),
                ),
                _buildDivider(),
                // Dormitórios
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.bed_outlined,
                    value: '${imovel.dormitorios}',
                    label: 'dorm',
                  ),
                ),
                _buildDivider(),
                // Vagas
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.directions_car_outlined,
                    value: '${imovel.vagas}',
                    label: 'vaga(s)',
                  ),
                ),
              ],
            ),
          ),
          
          // Linha divisória
          Container(
            height: 1,
            color: AppColors.border,
          ),
          
          // Botões de ação
          Padding(
            padding: const EdgeInsets.all(12),
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
                // Botão Reserva
                _buildCircleButton(
                  icon: Icons.bookmark_border_outlined,
                  onTap: onReservaTap ?? () {},
                ),
                const SizedBox(width: 8),
                // Botão Compartilhar
                _buildCircleButton(
                  icon: Icons.share_outlined,
                  onTap: onCompartilharTap ?? () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatArea() {
    final areaMin = imovel.area;
    final areaMax = imovel.areaTotal ?? imovel.area;
    
    if (areaMin == areaMax || areaMax == 0) {
      return '${areaMin.toStringAsFixed(0)}';
    }
    
    return '${areaMin.toStringAsFixed(0)} à ${areaMax.toStringAsFixed(0)}';
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: AppColors.border,
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isPrimary ? null : Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}


