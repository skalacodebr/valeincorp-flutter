import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/compartilhamento.dart';
import '../providers/favoritos_provider.dart';
import '../services/compartilhamento_service.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/card_imovel.dart';

class AtividadesScreen extends StatefulWidget {
  const AtividadesScreen({super.key});

  @override
  State<AtividadesScreen> createState() => _AtividadesScreenState();
}

class _AtividadesScreenState extends State<AtividadesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _CompartilhamentosTab(),
                _FavoritosTab(),
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
        child: Column(
          children: [
            // Título
            Padding(
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
                    child: const Icon(Icons.analytics_outlined, color: Colors.white),
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
            // TabBar
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: AppColors.primaryGold,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Compartilhamentos'),
                  Tab(text: 'Favoritos'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== ABA COMPARTILHAMENTOS =====
class _CompartilhamentosTab extends StatefulWidget {
  const _CompartilhamentosTab();

  @override
  State<_CompartilhamentosTab> createState() => _CompartilhamentosTabState();
}

class _CompartilhamentosTabState extends State<_CompartilhamentosTab> {
  final CompartilhamentoService _service = CompartilhamentoService();
  
  List<Compartilhamento> _compartilhamentos = [];
  bool _carregando = true;
  String? _erro;
  String _filtro = 'todos'; // todos, empreendimento, unidade

  @override
  void initState() {
    super.initState();
    _carregarCompartilhamentos();
  }

  Future<void> _carregarCompartilhamentos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final response = await _service.listar(
        entityType: _filtro == 'todos' ? null : _filtro,
      );

      if (response.success && response.data != null) {
        setState(() {
          _compartilhamentos = response.data!;
          _carregando = false;
        });
      } else {
        setState(() {
          _erro = response.message ?? 'Erro ao carregar compartilhamentos';
          _carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar: $e';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtros
        _buildFiltros(),
        
        // Lista
        Expanded(
          child: _carregando
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGold),
                )
              : _erro != null
                  ? _buildErro()
                  : _compartilhamentos.isEmpty
                      ? _buildVazio()
                      : RefreshIndicator(
                          onRefresh: _carregarCompartilhamentos,
                          color: AppColors.primaryGold,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _compartilhamentos.length,
                            itemBuilder: (context, index) {
                              return _CompartilhamentoCard(
                                compartilhamento: _compartilhamentos[index],
                                onRefresh: _carregarCompartilhamentos,
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFiltroChip('Todos', 'todos'),
            const SizedBox(width: 8),
            _buildFiltroChip('Empreendimentos', 'empreendimento'),
            const SizedBox(width: 8),
            _buildFiltroChip('Unidades', 'unidade'),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroChip(String label, String value) {
    final isSelected = _filtro == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filtro = value);
        _carregarCompartilhamentos();
      },
      selectedColor: AppColors.primaryBlue.withOpacity(0.1),
      checkmarkColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primaryBlue : AppColors.border,
      ),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _erro ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarCompartilhamentos,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVazio() {
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
              child: const Icon(
                Icons.share_outlined,
                size: 50,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum compartilhamento ainda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Compartilhe empreendimentos ou unidades\npara rastrear os acessos aqui',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ===== CARD DE COMPARTILHAMENTO =====
class _CompartilhamentoCard extends StatelessWidget {
  final Compartilhamento compartilhamento;
  final VoidCallback onRefresh;

  const _CompartilhamentoCard({
    required this.compartilhamento,
    required this.onRefresh,
  });

  String _formatarData(DateTime data) {
    final now = DateTime.now();
    final diff = now.difference(data);
    
    if (diff.inMinutes < 60) {
      return 'há ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'há ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'há ${diff.inDays}d';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(data);
    }
  }

  void _copiarLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: compartilhamento.urlCompleta));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copiado!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com imagem e info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    compartilhamento.isEmpreendimento
                        ? Icons.apartment
                        : Icons.door_front_door,
                    color: AppColors.primaryBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        compartilhamento.entityNome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: compartilhamento.isEmpreendimento
                                  ? AppColors.primaryGold.withOpacity(0.1)
                                  : AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              compartilhamento.tipoFormatado,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: compartilhamento.isEmpreendimento
                                    ? AppColors.primaryGold
                                    : AppColors.success,
                              ),
                            ),
                          ),
                          if (compartilhamento.nomeCliente != null &&
                              compartilhamento.nomeCliente!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cliente: ${compartilhamento.nomeCliente}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatarData(compartilhamento.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botão de editar
                IconButton(
                  onPressed: () => _mostrarOpcoes(context),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: AppColors.border),

          // Footer com estatísticas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Visualizações
                _buildEstatistica(
                  Icons.visibility_outlined,
                  compartilhamento.totalVisualizacoes.toString(),
                ),
                const SizedBox(width: 16),
                
                // Copiar link
                GestureDetector(
                  onTap: () => _copiarLink(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Link',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Status
                if (!compartilhamento.ativo || compartilhamento.isExpirado)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      compartilhamento.isExpirado ? 'Expirado' : 'Inativo',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstatistica(IconData icon, String valor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _mostrarOpcoes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              compartilhamento.entityNome,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (compartilhamento.nomeCliente != null &&
                compartilhamento.nomeCliente!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Cliente: ${compartilhamento.nomeCliente}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 20),
            _buildOpcaoItem(
              context,
              Icons.copy,
              'Copiar link',
              () {
                Navigator.pop(context);
                _copiarLink(context);
              },
            ),
            _buildOpcaoItem(
              context,
              Icons.bar_chart,
              'Ver estatísticas',
              () {
                Navigator.pop(context);
                _mostrarEstatisticas(context);
              },
            ),
            if (compartilhamento.ativo)
              _buildOpcaoItem(
                context,
                Icons.block,
                'Desativar link',
                () {
                  Navigator.pop(context);
                  _desativarLink(context);
                },
                isDestructive: true,
              ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcaoItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textPrimary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _mostrarEstatisticas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _EstatisticasModal(
        compartilhamento: compartilhamento,
      ),
    );
  }

  Future<void> _desativarLink(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desativar link?'),
        content: const Text(
          'O link não poderá mais ser acessado. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final service = CompartilhamentoService();
      final response = await service.desativar(compartilhamento.id);
      
      if (context.mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link desativado com sucesso'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          onRefresh();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Erro ao desativar'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

// ===== MODAL DE ESTATÍSTICAS =====
class _EstatisticasModal extends StatefulWidget {
  final Compartilhamento compartilhamento;

  const _EstatisticasModal({required this.compartilhamento});

  @override
  State<_EstatisticasModal> createState() => _EstatisticasModalState();
}

class _EstatisticasModalState extends State<_EstatisticasModal> {
  final CompartilhamentoService _service = CompartilhamentoService();
  
  CompartilhamentoEstatisticas? _estatisticas;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  Future<void> _carregarEstatisticas() async {
    final response = await _service.obterEstatisticas(widget.compartilhamento.id);
    
    if (mounted) {
      setState(() {
        _estatisticas = response.data;
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Estatísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          if (_carregando)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            )
          else if (_estatisticas != null)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildEstatCard(
                        'Visualizações',
                        _estatisticas!.totalVisualizacoes.toString(),
                        Icons.visibility,
                        AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEstatCard(
                        'Acessos únicos',
                        _estatisticas!.acessosUnicos.toString(),
                        Icons.person,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Última visualização',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _estatisticas!.ultimaVisualizacao != null
                            ? DateFormat('dd/MM/yyyy HH:mm')
                                .format(_estatisticas!.ultimaVisualizacao!)
                            : 'Nenhuma visualização ainda',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            const Text('Erro ao carregar estatísticas'),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildEstatCard(String label, String valor, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== ABA FAVORITOS =====
class _FavoritosTab extends StatefulWidget {
  const _FavoritosTab();

  @override
  State<_FavoritosTab> createState() => _FavoritosTabState();
}

class _FavoritosTabState extends State<_FavoritosTab> {
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
    return Column(
      children: [
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

