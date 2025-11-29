import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/imovel_detalhes.dart';

class DiferenciaisGrid extends StatelessWidget {
  final List<Diferencial> diferenciais;
  final String? diferencialAdicional;

  const DiferenciaisGrid({
    super.key,
    required this.diferenciais,
    this.diferencialAdicional,
  });

  @override
  Widget build(BuildContext context) {
    if (diferenciais.isEmpty && diferencialAdicional == null) {
      return const SizedBox.shrink();
    }

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
                Icons.star_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Diferenciais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Grid de diferenciais
        if (diferenciais.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: diferenciais.length,
            itemBuilder: (context, index) {
              return _buildDiferencialItem(diferenciais[index]);
            },
          ),

        // Diferenciais adicionais (texto)
        if (diferencialAdicional != null && diferencialAdicional!.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Diferenciais adicionais',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              diferencialAdicional!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDiferencialItem(Diferencial diferencial) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForDiferencial(diferencial.icone, diferencial.nome),
            color: AppColors.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              diferencial.nome,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForDiferencial(String icone, String nome) {
    // Primeiro tenta pelo nome do ícone
    final iconMap = <String, IconData>{
      // Ícones comuns
      'fitness': Icons.fitness_center_outlined,
      'academia': Icons.fitness_center_outlined,
      'gym': Icons.fitness_center_outlined,
      'pool': Icons.pool_outlined,
      'piscina': Icons.pool_outlined,
      'playground': Icons.child_care_outlined,
      'brinquedoteca': Icons.toys_outlined,
      'party': Icons.celebration_outlined,
      'festas': Icons.celebration_outlined,
      'salao': Icons.celebration_outlined,
      'churrasqueira': Icons.outdoor_grill_outlined,
      'bbq': Icons.outdoor_grill_outlined,
      'gourmet': Icons.restaurant_outlined,
      'spa': Icons.spa_outlined,
      'sauna': Icons.hot_tub_outlined,
      'club': Icons.local_bar_outlined,
      'clubhouse': Icons.local_bar_outlined,
      'portaria': Icons.security_outlined,
      'seguranca': Icons.shield_outlined,
      'pet': Icons.pets_outlined,
      'garden': Icons.park_outlined,
      'jardim': Icons.park_outlined,
      'quadra': Icons.sports_tennis_outlined,
      'esporte': Icons.sports_outlined,
      'coworking': Icons.business_center_outlined,
      'bike': Icons.pedal_bike_outlined,
      'bicicletario': Icons.pedal_bike_outlined,
      'lavanderia': Icons.local_laundry_service_outlined,
      'cinema': Icons.movie_outlined,
      'games': Icons.sports_esports_outlined,
      'jogos': Icons.sports_esports_outlined,
      'kids': Icons.child_friendly_outlined,
      'lounge': Icons.weekend_outlined,
      'rooftop': Icons.deck_outlined,
      'terraço': Icons.deck_outlined,
      'valet': Icons.local_parking_outlined,
      'estacionamento': Icons.local_parking_outlined,
      'wifi': Icons.wifi_outlined,
      'ar': Icons.ac_unit_outlined,
      'elevador': Icons.elevator_outlined,
    };

    // Busca pelo nome do ícone ou pelo nome do diferencial
    final searchKey = icone.toLowerCase();
    final searchName = nome.toLowerCase();

    for (final entry in iconMap.entries) {
      if (searchKey.contains(entry.key) || searchName.contains(entry.key)) {
        return entry.value;
      }
    }

    // Ícone padrão
    return Icons.check_circle_outline;
  }
}


