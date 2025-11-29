import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/compartilhamento.dart';
import '../utils/formatters.dart';

class CompartilhamentoCard extends StatelessWidget {
  final Compartilhamento compartilhamento;
  final VoidCallback onEdit;
  final VoidCallback onCopyLink;

  const CompartilhamentoCard({
    super.key,
    required this.compartilhamento,
    required this.onEdit,
    required this.onCopyLink,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com nome do cliente e status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (compartilhamento.nomeCliente != null)
                        Text(
                          compartilhamento.nomeCliente!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        compartilhamento.entityNome ?? 
                        '${compartilhamento.entityType == 'empreendimento' ? 'Empreendimento' : 'Unidade'} #${compartilhamento.entityId}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge de status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: compartilhamento.ativo && !compartilhamento.isExpirado
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    compartilhamento.ativo && !compartilhamento.isExpirado
                        ? 'Ativo'
                        : 'Inativo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: compartilhamento.ativo && !compartilhamento.isExpirado
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Informações do compartilhamento
            if (compartilhamento.anotacao != null && compartilhamento.anotacao!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  compartilhamento.anotacao!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            
            // Opções de visualização
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (compartilhamento.mostrarEspelhoVendas)
                  _buildBadge('Espelho de Vendas', Icons.bar_chart),
                if (compartilhamento.mostrarEndereco)
                  _buildBadge('Endereço', Icons.location_on),
                if (compartilhamento.compartilharDescricao)
                  _buildBadge('Descrição', Icons.description),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Footer com visualizações e ações
            Row(
              children: [
                // Contador de visualizações
                Row(
                  children: [
                    const Icon(
                      Icons.remove_red_eye,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${compartilhamento.totalVisualizacoes} visualizações',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Data de criação
                Text(
                  _formatDate(compartilhamento.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGold,
                      side: const BorderSide(color: AppColors.primaryGold),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCopyLink,
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('Copiar Link'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryGold),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return Formatters.date(date);
    } catch (e) {
      return dateString;
    }
  }
}

