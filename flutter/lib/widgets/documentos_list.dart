import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/imovel_detalhes.dart';

class DocumentosList extends StatelessWidget {
  final List<Documento> documentos;
  final Function(Documento) onDocumentoTap;

  const DocumentosList({
    super.key,
    required this.documentos,
    required this.onDocumentoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (documentos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum documento disponível',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nome',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Data de Atualização',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Lista de documentos
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: documentos.asMap().entries.map((entry) {
                final index = entry.key;
                final documento = entry.value;
                final isLast = index == documentos.length - 1;

                return Column(
                  children: [
                    _buildDocumentoItem(documento),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        color: AppColors.border,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentoItem(Documento documento) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onDocumentoTap(documento),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getIconColor(documento).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconForDocumento(documento),
                  color: _getIconColor(documento),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              
              // Nome do documento
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documento.tipoDocumento.nome,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (documento.nomeOriginal != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        documento.nomeOriginal!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Data de atualização
              Expanded(
                flex: 2,
                child: Text(
                  _formatDate(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              
              // Chevron
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForDocumento(Documento documento) {
    if (documento.isPdf) {
      return Icons.picture_as_pdf_outlined;
    } else if (documento.isImage) {
      return Icons.image_outlined;
    }
    
    final nome = documento.tipoDocumento.nome.toLowerCase();
    if (nome.contains('tabela') || nome.contains('vendas')) {
      return Icons.table_chart_outlined;
    } else if (nome.contains('proposta') || nome.contains('ficha')) {
      return Icons.description_outlined;
    } else if (nome.contains('memorial')) {
      return Icons.article_outlined;
    } else if (nome.contains('implanta')) {
      return Icons.map_outlined;
    } else if (nome.contains('folder')) {
      return Icons.folder_outlined;
    }
    
    return Icons.insert_drive_file_outlined;
  }

  Color _getIconColor(Documento documento) {
    if (documento.isPdf) {
      return Colors.red;
    } else if (documento.isImage) {
      return Colors.blue;
    }
    return AppColors.primaryBlue;
  }

  String _formatDate() {
    // Por enquanto retorna uma data fictícia
    // Idealmente, o backend deve enviar a data de atualização
    final now = DateTime.now();
    return DateFormat('dd/MM/yyyy HH:mm').format(now);
  }
}


