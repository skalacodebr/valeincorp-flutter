import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/imovel.dart';
import '../providers/favoritos_provider.dart';
import '../providers/compartilhamentos_provider.dart';
import '../widgets/card_imovel.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/compartilhamento_card.dart';
import '../widgets/editar_compartilhamento_modal.dart';

class AtividadesScreen extends StatefulWidget {
  const AtividadesScreen({super.key});

  @override
  State<AtividadesScreen> createState() => _AtividadesScreenState();
}

class _AtividadesScreenState extends State<AtividadesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _termoPesquisa = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritosProvider>().loadFavoritos();
      context.read<CompartilhamentosProvider>().loadCompartilhamentos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCompartilhamentosTab(),
                _buildFavoritosTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentItem: NavItem.atividades),
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
                child: const Icon(Icons.timeline, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Atividades',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryGold,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryGold,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Compartilhamentos'),
          Tab(text: 'Favoritos'),
        ],
      ),
    );
  }

  Widget _buildCompartilhamentosTab() {
    return Column(
      children: [
        _buildSearchBar('Pesquisar compartilhamentos...'),
        Expanded(
          child: Consumer<CompartilhamentosProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.compartilhamentos.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGold),
                );
              }

              final compartilhamentos = provider.compartilhamentos.where((c) {
                if (_termoPesquisa.isEmpty) return true;
                final termo = _termoPesquisa.toLowerCase();
                return (c.nomeCliente?.toLowerCase().contains(termo) ?? false) ||
                       (c.entityNome?.toLowerCase().contains(termo) ?? false);
              }).toList();

              if (compartilhamentos.isEmpty) {
                return _buildEmptyCompartilhamentos();
              }

              return RefreshIndicator(
                onRefresh: () => provider.refreshCompartilhamentos(),
                color: AppColors.primaryGold,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: compartilhamentos.length,
                  itemBuilder: (context, index) {
                    final compartilhamento = compartilhamentos[index];
                    return CompartilhamentoCard(
                      compartilhamento: compartilhamento,
                      onEdit: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => EditarCompartilhamentoModal(
                            compartilhamento: compartilhamento,
                          ),
                        );
                      },
                      onCopyLink: () {
                        provider.copiarLink(compartilhamento.urlCompleta);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copiado!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritosTab() {
    return Column(
      children: [
        _buildSearchBar('Pesquisar em favoritos...'),
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
                return _buildEmptyFavoritos();
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
                        _confirmarRemocao(context, favoritosProvider, imovel);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(String hintText) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: hintText,
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

  Widget _buildEmptyCompartilhamentos() {
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
                hasSearch ? Icons.search_off : Icons.share_outlined,
                size: 50,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasSearch 
                  ? 'Nenhum resultado encontrado'
                  : 'Nenhum compartilhamento ainda',
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
                  : 'Compartilhe imóveis para acompanhar visualizações',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFavoritos() {
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
    Imovel imovel,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Remover favorito?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja remover "${imovel.nome}" dos seus favoritos?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final result = await provider.removerFavorito(imovel.id);
              if (mounted) {
                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${imovel.nome} removido dos favoritos'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else if (provider.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error!),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.error,
                    ),
                  );
                  provider.clearError();
                }
              }
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

