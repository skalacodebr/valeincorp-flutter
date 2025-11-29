import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/favoritos_provider.dart';
import '../widgets/card_imovel.dart';
import '../widgets/bottom_navigation.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _termoPesquisa = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritosProvider>().loadFavoritos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: Consumer<FavoritosProvider>(
              builder: (context, favoritosProvider, child) {
                if (favoritosProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGold),
                  );
                }

                final favoritos = favoritosProvider.favoritos.where((imovel) {
                  if (_termoPesquisa.isEmpty) return true;
                  final termo = _termoPesquisa.toLowerCase();
                  return imovel.codigo.toLowerCase().contains(termo) ||
                         imovel.nome.toLowerCase().contains(termo);
                }).toList();

                if (favoritos.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () => favoritosProvider.loadFavoritos(),
                  color: AppColors.primaryGold,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: favoritos.length,
                    itemBuilder: (context, index) {
                      final imovel = favoritos[index];
                      return CardImovel(
                        imovel: imovel,
                        isFavorito: true,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.imovelDetalhes,
                            arguments: imovel.id,
                          );
                        },
                        onFavoritoTap: () {
                          _confirmarRemocao(context, favoritosProvider, imovel.id);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentItem: NavItem.favoritos),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Favoritos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Consumer<FavoritosProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${provider.totalFavoritos} imóveis',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Pesquisar em favoritos...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() => _termoPesquisa = value);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _termoPesquisa.isNotEmpty;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                hasSearch ? Icons.search_off : Icons.favorite_border,
                size: 50,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasSearch 
                  ? 'Nenhum resultado encontrado'
                  : 'Nenhum favorito ainda',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch
                  ? 'Tente buscar por outro termo'
                  : 'Adicione imóveis aos favoritos para encontrá-los aqui',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                },
                icon: const Icon(Icons.search),
                label: const Text('Explorar imóveis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmarRemocao(
    BuildContext context,
    FavoritosProvider provider,
    int imovelId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover dos favoritos?'),
        content: const Text(
          'Tem certeza que deseja remover este imóvel dos seus favoritos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removerFavorito(imovelId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Removido dos favoritos'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

