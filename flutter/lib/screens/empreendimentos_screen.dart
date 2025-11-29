import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/imovel.dart';
import '../services/imoveis_service.dart';
import '../providers/favoritos_provider.dart';
import '../widgets/card_imovel.dart';

class EmpreendimentosScreen extends StatefulWidget {
  final Map<String, dynamic>? filtros;

  const EmpreendimentosScreen({super.key, this.filtros});

  @override
  State<EmpreendimentosScreen> createState() => _EmpreendimentosScreenState();
}

class _EmpreendimentosScreenState extends State<EmpreendimentosScreen> {
  final ImoveisService _imoveisService = ImoveisService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Imovel> _imoveis = [];
  bool _carregando = true;
  int _paginaAtual = 1;
  int _totalItens = 0;

  @override
  void initState() {
    super.initState();
    if (widget.filtros?['search'] != null) {
      _searchController.text = widget.filtros!['search'];
    }
    _carregarImoveis();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarImoveis() async {
    setState(() => _carregando = true);
    
    try {
      final response = await _imoveisService.list(
        page: _paginaAtual,
        limit: 20,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      
      if (response.success && response.data != null) {
        var imoveisFiltrados = response.data!;
        
        // Aplicar filtros recebidos
        if (widget.filtros != null) {
          // Filtrar por valor
          final valorDe = widget.filtros!['valorDe'] as double?;
          final valorAte = widget.filtros!['valorAte'] as double?;
          
          if (valorDe != null) {
            imoveisFiltrados = imoveisFiltrados.where((i) => i.preco >= valorDe).toList();
          }
          if (valorAte != null) {
            imoveisFiltrados = imoveisFiltrados.where((i) => i.preco <= valorAte).toList();
          }
          
          // Filtrar por localização
          final localizacoes = widget.filtros!['localizacoes'] as String?;
          if (localizacoes != null && localizacoes.isNotEmpty) {
            final locs = localizacoes.split(';').map((l) => l.toLowerCase()).toList();
            imoveisFiltrados = imoveisFiltrados.where((imovel) {
              final cidade = (imovel.endereco?.cidade ?? imovel.cidade).toLowerCase();
              final bairro = (imovel.endereco?.bairro ?? '').toLowerCase();
              final estado = (imovel.endereco?.estado ?? '').toLowerCase();
              
              return locs.any((loc) =>
                cidade.contains(loc) ||
                bairro.contains(loc) ||
                estado.contains(loc)
              );
            }).toList();
          }
        }
        
        setState(() {
          _imoveis = imoveisFiltrados;
          _totalItens = imoveisFiltrados.length;
        });
      }
    } catch (e) {
      // Handle error
    }
    
    setState(() => _carregando = false);
  }

  void _buscar() {
    setState(() => _paginaAtual = 1);
    _carregarImoveis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildResultsInfo(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _carregarImoveis,
              color: AppColors.primaryGold,
              child: _buildContent(),
            ),
          ),
        ],
      ),
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
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Resultados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _buscar(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _buscar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsInfo() {
    final filtrosAtivos = <String>[];
    
    if (widget.filtros != null) {
      if (widget.filtros!['valorDe'] != null) {
        filtrosAtivos.add('De: R\$ ${widget.filtros!['valorDe']}');
      }
      if (widget.filtros!['valorAte'] != null) {
        filtrosAtivos.add('Até: R\$ ${widget.filtros!['valorAte']}');
      }
      if (widget.filtros!['localizacoes'] != null) {
        filtrosAtivos.add('Localização: ${widget.filtros!['localizacoes']}');
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_totalItens empreendimentos encontrados',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (filtrosAtivos.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: filtrosAtivos.map((filtro) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    filtro,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryGold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      );
    }

    if (_imoveis.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.search_off,
                  size: 40,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum resultado encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tente ajustar os filtros de busca',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<FavoritosProvider>(
      builder: (context, favoritosProvider, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemCount: _imoveis.length,
          itemBuilder: (context, index) {
            final imovel = _imoveis[index];
            return CardImovel(
              imovel: imovel,
              isFavorito: favoritosProvider.isFavorito(imovel.id),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.imovelDetalhes,
                  arguments: imovel.id,
                );
              },
              onFavoritoTap: () async {
                final wasFavorito = favoritosProvider.isFavorito(imovel.id);
                final result = await favoritosProvider.toggleFavorito(imovel);
                if (mounted) {
                  if (result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(wasFavorito ? 'Removido dos favoritos' : 'Adicionado aos favoritos'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (favoritosProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(favoritosProvider.error!),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    favoritosProvider.clearError();
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}

