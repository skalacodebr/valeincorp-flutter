import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/imovel.dart';
import '../services/imoveis_service.dart';
import '../providers/favoritos_provider.dart';
import '../widgets/card_imovel.dart';
import '../widgets/bottom_navigation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ImoveisService _imoveisService = ImoveisService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Imovel> _imoveis = [];
  List<String> _estados = ['Todos'];
  List<String> _cidades = ['Todos'];
  List<String> _bairros = ['Todos'];
  
  String _estadoSelecionado = 'Todos';
  String _cidadeSelecionada = 'Todos';
  String _bairroSelecionado = 'Todos';
  
  bool _carregando = true;
  bool _mostrarFiltros = false;
  int _paginaAtual = 1;
  int _totalItens = 0;
  String _termoPesquisa = '';
  String? _erroConexao;

  @override
  void initState() {
    super.initState();
    _carregarImoveis();
    _carregarFiltros();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarFiltros() async {
    try {
      final response = await _imoveisService.list(page: 1, limit: 1000);
      if (response.success && response.data != null) {
        final imoveisList = response.data!;
        
        final estadosSet = <String>{'Todos'};
        final cidadesSet = <String>{'Todos'};
        final bairrosSet = <String>{'Todos'};
        
        for (final imovel in imoveisList) {
          if (imovel.endereco?.estado != null) {
            estadosSet.add(imovel.endereco!.estado);
          }
          final cidade = imovel.endereco?.cidade ?? imovel.cidade;
          if (cidade.isNotEmpty) {
            cidadesSet.add(cidade);
          }
          if (imovel.endereco?.bairro != null) {
            bairrosSet.add(imovel.endereco!.bairro);
          }
        }
        
        setState(() {
          _estados = estadosSet.toList()..sort();
          _cidades = cidadesSet.toList()..sort();
          _bairros = bairrosSet.toList()..sort();
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _carregarImoveis() async {
    setState(() {
      _carregando = true;
      _erroConexao = null;
    });
    
    try {
      debugPrint('[Dashboard] Carregando imóveis...');
      final response = await _imoveisService.list(
        page: _paginaAtual,
        limit: 20,
        search: _termoPesquisa.isEmpty ? null : _termoPesquisa,
        cidade: _cidadeSelecionada == 'Todos' ? null : _cidadeSelecionada,
      );
      
      debugPrint('[Dashboard] Response success: ${response.success}');
      debugPrint('[Dashboard] Response data: ${response.data?.length ?? 0} itens');
      debugPrint('[Dashboard] Response message: ${response.message}');
      
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        var imoveisFiltrados = response.data!;
        debugPrint('[Dashboard] Imóveis recebidos da API: ${imoveisFiltrados.length}');
        
        // Filtrar por estado
        if (_estadoSelecionado != 'Todos') {
          final antes = imoveisFiltrados.length;
          imoveisFiltrados = imoveisFiltrados.where((imovel) =>
            imovel.endereco?.estado?.toLowerCase() == _estadoSelecionado.toLowerCase()
          ).toList();
          debugPrint('[Dashboard] Após filtro de estado ($_estadoSelecionado): $antes -> ${imoveisFiltrados.length}');
        }
        
        // Filtrar por cidade
        if (_cidadeSelecionada != 'Todos') {
          final antes = imoveisFiltrados.length;
          imoveisFiltrados = imoveisFiltrados.where((imovel) {
            final cidade = imovel.endereco?.cidade ?? imovel.cidade;
            return cidade.toLowerCase() == _cidadeSelecionada.toLowerCase();
          }).toList();
          debugPrint('[Dashboard] Após filtro de cidade ($_cidadeSelecionada): $antes -> ${imoveisFiltrados.length}');
        }
        
        // Filtrar por bairro
        if (_bairroSelecionado != 'Todos') {
          final antes = imoveisFiltrados.length;
          imoveisFiltrados = imoveisFiltrados.where((imovel) =>
            imovel.endereco?.bairro?.toLowerCase() == _bairroSelecionado.toLowerCase()
          ).toList();
          debugPrint('[Dashboard] Após filtro de bairro ($_bairroSelecionado): $antes -> ${imoveisFiltrados.length}');
        }
        
        debugPrint('[Dashboard] Total de imóveis após filtros: ${imoveisFiltrados.length}');
        setState(() {
          _imoveis = imoveisFiltrados;
          _totalItens = imoveisFiltrados.length;
          _carregando = false;
          _erroConexao = null;
        });
      } else {
        // Se a resposta não foi bem-sucedida ou não tem dados, limpar a lista
        debugPrint('[Dashboard] Resposta não bem-sucedida ou sem dados');
        debugPrint('[Dashboard] Success: ${response.success}, Data null: ${response.data == null}, Data empty: ${response.data?.isEmpty ?? true}');
        
        // Verificar se é erro de conexão
        if (!response.success && response.message != null && response.message!.toLowerCase().contains('conexão')) {
          setState(() {
            _imoveis = [];
            _totalItens = 0;
            _carregando = false;
            _erroConexao = response.message ?? 'Erro de conexão com o servidor';
          });
        } else {
          setState(() {
            _imoveis = [];
            _totalItens = 0;
            _carregando = false;
            _erroConexao = null;
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[Dashboard] ERRO ao carregar imóveis: $e');
      debugPrint('[Dashboard] Stack trace: $stackTrace');
      
      // Verificar se é erro de conexão
      final erroMsg = e.toString().toLowerCase();
      String mensagemErro;
      
      if (erroMsg.contains('connection') || erroMsg.contains('conexão') || erroMsg.contains('xmlhttprequest')) {
        mensagemErro = 'Não foi possível conectar ao servidor.\n\n'
            'Possíveis causas:\n'
            '• Problema de conexão com a internet\n'
            '• Servidor temporariamente indisponível\n'
            '• Problema de CORS (se estiver em Flutter Web)\n\n'
            'Tente novamente em alguns instantes.';
      } else {
        mensagemErro = 'Erro ao carregar empreendimentos:\n${e.toString()}';
      }
      
      setState(() {
        _imoveis = [];
        _totalItens = 0;
        _carregando = false;
        _erroConexao = mensagemErro;
      });
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _mostrarFiltros = false;
      _paginaAtual = 1;
    });
    _carregarImoveis();
  }

  void _limparFiltros() {
    setState(() {
      _estadoSelecionado = 'Todos';
      _cidadeSelecionada = 'Todos';
      _bairroSelecionado = 'Todos';
      _paginaAtual = 1;
    });
    _carregarImoveis();
  }

  void _buscar() {
    setState(() {
      _termoPesquisa = _searchController.text;
      _paginaAtual = 1;
    });
    _carregarImoveis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _carregarImoveis,
              color: AppColors.primaryGold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildResultsCount(),
                    _buildActiveFilters(),
                    const SizedBox(height: 16),
                    _buildImoveisGrid(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentItem: NavItem.inicio),
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
              Image.asset(
                'assets/images/logo-sucesso-nova.png',
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.apartment,
                      color: AppColors.primaryGold,
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildFiltersButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersButton() {
    return Stack(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            setState(() => _mostrarFiltros = !_mostrarFiltros);
          },
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text('Filtros'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (_mostrarFiltros)
          Positioned(
            top: 48,
            right: 0,
            child: _buildFiltersDropdown(),
          ),
      ],
    );
  }

  Widget _buildFiltersDropdown() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownFilter('Estado', _estados, _estadoSelecionado, (value) {
              setState(() => _estadoSelecionado = value!);
            }),
            const SizedBox(height: 12),
            _buildDropdownFilter('Cidade', _cidades, _cidadeSelecionada, (value) {
              setState(() => _cidadeSelecionada = value!);
            }),
            const SizedBox(height: 12),
            _buildDropdownFilter('Bairro', _bairros, _bairroSelecionado, (value) {
              setState(() => _bairroSelecionado = value!);
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _limparFiltros,
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _aplicarFiltros,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    List<String> items,
    String value,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Pesquisar por código ou nome...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, size: 18),
              SizedBox(width: 4),
              Text('Buscar'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsCount() {
    return Text(
      'Total de $_totalItens exclusividades encontradas',
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
    );
  }

  Widget _buildActiveFilters() {
    final activeFilters = <String>[];
    if (_estadoSelecionado != 'Todos') activeFilters.add('Estado: $_estadoSelecionado');
    if (_cidadeSelecionada != 'Todos') activeFilters.add('Cidade: $_cidadeSelecionada');
    if (_bairroSelecionado != 'Todos') activeFilters.add('Bairro: $_bairroSelecionado');

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          const Text(
            'Filtros ativos:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          ...activeFilters.map((filter) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                filter,
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImoveisGrid() {
    if (_carregando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            color: AppColors.primaryGold,
          ),
        ),
      );
    }

    // Mostrar erro de conexão
    if (_erroConexao != null) {
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
                  Icons.wifi_off,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Erro de Conexão',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _erroConexao!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _carregarImoveis,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_imoveis.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.search_off,
                  size: 32,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum imóvel encontrado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tente alterar os filtros selecionados',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<FavoritosProvider>(
      builder: (context, favoritosProvider, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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

