import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/imovel_detalhes.dart';

class InfoCardFlutuante extends StatelessWidget {
  final ImovelDetalhes imovel;

  const InfoCardFlutuante({
    super.key,
    required this.imovel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                icon: Icons.straighten_outlined,
                value: _formatArea(),
                label: 'm²',
              ),
              _buildDivider(),
              _buildInfoItem(
                icon: Icons.bed_outlined,
                value: '${imovel.dormitorios}',
                label: 'dorm',
              ),
              _buildDivider(),
              _buildInfoItem(
                icon: Icons.directions_car_outlined,
                value: '${imovel.vagas}',
                label: 'vaga(s)',
              ),
            ],
          ),
        ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.border,
    );
  }
}
