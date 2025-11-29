import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';

class CompartilhamentoModal extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String? preco;
  final String? localizacao;
  final String? imageUrl;
  final String linkPublico;
  final String tipo; // 'imovel' ou 'unidade'

  const CompartilhamentoModal({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.preco,
    this.localizacao,
    this.imageUrl,
    required this.linkPublico,
    required this.tipo,
  });

  Future<void> _copiarLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: linkPublico));
    
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.success, size: 16),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Link copiado!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'O link foi copiado para área de transferência',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _compartilharWhatsApp(BuildContext context) async {
    final mensagem = '''
🏠 *$titulo*

${preco != null ? '💰 $preco\n' : ''}${localizacao != null ? '📍 $localizacao\n' : ''}
🔗 Veja mais detalhes: $linkPublico

_Compartilhado via Valeincorp_
''';

    final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(mensagem)}';
    
    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Erro ao abrir WhatsApp: $e');
    }
  }

  Future<void> _compartilharNativo(BuildContext context) async {
    final mensagem = '''
$titulo

${preco ?? ''}
${localizacao ?? ''}

Veja mais detalhes: $linkPublico
''';

    try {
      await Share.share(mensagem, subject: titulo);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao compartilhar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.share, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compartilhar ${tipo == 'unidade' ? 'Unidade' : 'Imóvel'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Compartilhe ${tipo == 'unidade' ? 'esta unidade' : 'este imóvel'} com outros',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.apartment, color: AppColors.textHint),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.apartment, color: AppColors.textHint),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitulo.isNotEmpty)
                        Text(
                          subtitulo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Link
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, size: 16, color: AppColors.textHint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    linkPublico,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Botão Copiar Link
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _copiarLink(context),
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copiar Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Botão WhatsApp
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _compartilharWhatsApp(context),
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('Compartilhar via WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Botão Compartilhar Nativo
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _compartilharNativo(context),
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text('Outras opções'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

