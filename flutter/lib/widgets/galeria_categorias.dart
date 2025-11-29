import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../models/imovel_detalhes.dart';

class GaleriaCategorias extends StatelessWidget {
  final List<Story> stories;
  final VoidCallback? onCompartilharTap;
  final Function(Story) onStoryTap;

  const GaleriaCategorias({
    super.key,
    required this.stories,
    this.onCompartilharTap,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com título e botão compartilhar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                    Icons.photo_library_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Galeria de fotos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (onCompartilharTap != null)
              TextButton.icon(
                onPressed: onCompartilharTap,
                icon: const Icon(
                  Icons.share_outlined,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                label: const Text(
                  'Compartilhar / salvar',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Lista horizontal de categorias
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              final hasImages = story.imagens.isNotEmpty;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < stories.length - 1 ? 16 : 0,
                ),
                child: GestureDetector(
                  onTap: hasImages ? () => onStoryTap(story) : null,
                  child: Column(
                    children: [
                      // Círculo com imagem
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: hasImages
                                ? AppColors.primaryBlue
                                : AppColors.border,
                            width: 2,
                          ),
                          boxShadow: hasImages
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipOval(
                          child: hasImages
                              ? CachedNetworkImage(
                                  imageUrl: story.imagens.first.fotosUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.background,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primaryGold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: AppColors.background,
                                    child: Icon(
                                      _getStoryIcon(story.tipo),
                                      color: AppColors.textHint,
                                      size: 28,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.background.withOpacity(0.5),
                                  child: Icon(
                                    _getStoryIcon(story.tipo),
                                    color: AppColors.textHint,
                                    size: 28,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Label
                      SizedBox(
                        width: 70,
                        child: Text(
                          story.titulo,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: hasImages
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getStoryIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'decorado':
        return Icons.home_outlined;
      case 'externa':
        return Icons.camera_alt_outlined;
      case 'interna':
        return Icons.dashboard_outlined;
      case 'planta':
        return Icons.map_outlined;
      case 'fachada':
        return Icons.apartment_outlined;
      case 'lazer':
        return Icons.pool_outlined;
      case 'tour':
        return Icons.vrpano_outlined;
      default:
        return Icons.folder_outlined;
    }
  }
}


