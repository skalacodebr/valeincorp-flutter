import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../services/imoveis_service.dart';
import 'share_settings_modal.dart';

class EspelhoVendasModal extends StatefulWidget {
  final int imovelId;
  final String imovelNome;
  final Map<String, dynamic>? espelhoVendasData;

  const EspelhoVendasModal({
    super.key,
    required this.imovelId,
    required this.imovelNome,
    this.espelhoVendasData,
  });

  @override
  State<EspelhoVendasModal> createState() => _EspelhoVendasModalState();
}

class _EspelhoVendasModalState extends State<EspelhoVendasModal>
    with SingleTickerProviderStateMixin {
  final ImoveisService _imoveisService = ImoveisService();
  late TabController _tabController;

  Map<String, dynamic>? _espelhoData;
  bool _loading = true;
  String? _error;
  int _torreSelecionada = 0;
  String _filtroStatus = 'todos';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarEspelhoVendas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarEspelhoVendas() async {
    if (widget.espelhoVendasData != null) {
      setState(() {
        _espelhoData = widget.espelhoVendasData;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _imoveisService.getEmpreendimentoDetalhes(widget.imovelId);

      if (response.success && response.data != null) {
        setState(() {
          _espelhoData = response.data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Erro ao carregar dados';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'É necessário fazer login para visualizar os detalhes do espelho de vendas';
        _loading = false;
      });
    }
  }

  Map<String, dynamic> get _resumo {
    return _espelhoData?['resumo'] as Map<String, dynamic>? ?? {};
  }

  List<dynamic> get _torres {
    return _espelhoData?['torres'] as List<dynamic>? ?? [];
  }

  Map<String, dynamic>? get _evolucaoVendas {
    return _espelhoData?['evolucaoVendas'] as Map<String, dynamic>?;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disponivel':
      case 'disponível':
        return AppColors.success;
      case 'reservado':
      case 'reservada':
        return Colors.amber;
      case 'vendido':
      case 'vendida':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'disponivel':
      case 'disponível':
        return Icons.check_circle;
      case 'reservado':
      case 'reservada':
        return Icons.access_time;
      case 'vendido':
      case 'vendida':
        return Icons.shopping_cart;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryBlue),
                  )
                : _error != null
                    ? _buildError()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildResumoTab(),
                          _buildEspelhoTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF1A2D5F)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Espelho de Vendas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.imovelNome,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: AppColors.background,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Resumo'),
          Tab(text: 'Espelho'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarEspelhoVendas,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoTab() {
    final totalUnidades = _resumo['totalUnidades'] ?? 0;
    final disponiveis = _resumo['unidadesDisponiveis'] ?? 0;
    final reservadas = _resumo['unidadesReservadas'] ?? 0;
    final vendidas = _resumo['unidadesVendidas'] ?? 0;
    final percentualVendido = _resumo['percentualVendido'] ?? 0.0;
    final percentualReservado = _resumo['percentualReservado'] ?? 0.0;
    final percentualDisponivel = _resumo['percentualDisponivel'] ?? 0.0;
    final valorTotalVendido = _resumo['valorTotalVendido'] ?? 0.0;
    final ticketMedio = _resumo['ticketMedio'] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards de resumo
          Row(
            children: [
              Expanded(
                child: _buildResumoCard(
                  'Disponíveis',
                  disponiveis,
                  percentualDisponivel,
                  AppColors.success,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResumoCard(
                  'Reservadas',
                  reservadas,
                  percentualReservado,
                  Colors.amber,
                  Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildResumoCard(
                  'Vendidas',
                  vendidas,
                  percentualVendido,
                  AppColors.error,
                  Icons.shopping_cart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResumoCard(
                  'Total',
                  totalUnidades,
                  100.0,
                  AppColors.primaryBlue,
                  Icons.home,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Valores de venda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGold.withOpacity(0.1),
                  AppColors.primaryGold.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.attach_money, color: AppColors.primaryGold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Valores de Vendas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Vendido',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(valorTotalVendido),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ticket Médio',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(ticketMedio),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Distribuição
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart, color: AppColors.primaryBlue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Distribuição',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDistribuicaoBar(
                  'Disponíveis',
                  disponiveis,
                  totalUnidades,
                  percentualDisponivel,
                  AppColors.success,
                ),
                const SizedBox(height: 12),
                _buildDistribuicaoBar(
                  'Reservadas',
                  reservadas,
                  totalUnidades,
                  percentualReservado,
                  Colors.amber,
                ),
                const SizedBox(height: 12),
                _buildDistribuicaoBar(
                  'Vendidas',
                  vendidas,
                  totalUnidades,
                  percentualVendido,
                  AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Lista de Torres
          if (_torres.isNotEmpty) ...[
            const Text(
              'Torres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._torres.map((torre) => _buildTorreResumoCard(torre as Map<String, dynamic>)),
          ],
        ],
      ),
    );
  }

  Widget _buildResumoCard(
    String label,
    int quantidade,
    double percentual,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                '${percentual.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$quantidade',
            style: TextStyle(
              fontSize: 28,
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

  Widget _buildDistribuicaoBar(String label, int quantidade, int total, double percentual, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '$quantidade (${percentual.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? quantidade / total : 0,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTorreResumoCard(Map<String, dynamic> torre) {
    final nome = torre['nome'] ?? 'Torre';
    final resumoTorre = torre['resumo'] as Map<String, dynamic>? ?? {};
    final totalUnidades = resumoTorre['totalUnidades'] ?? torre['totalUnidades'] ?? 0;
    final disponiveis = resumoTorre['unidadesDisponiveis'] ?? torre['unidadesDisponiveis'] ?? 0;
    final vendidas = resumoTorre['unidadesVendidas'] ?? torre['unidadesVendidas'] ?? 0;
    final totalAndares = torre['totalAndares'] ?? 0;
    final unidadesPorAndar = torre['unidadesPorAndar'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.apartment, color: AppColors.primaryBlue, size: 24),
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Torre $nome',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalAndares andares • $unidadesPorAndar un./andar',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$disponiveis',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'de $totalUnidades',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEspelhoTab() {
    if (_torres.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apartment, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Nenhuma torre encontrada',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Seletor de torre e filtros
        _buildTorreSelectorAndFilters(),
        // Legenda
        _buildLegenda(),
        // Grid do espelho
        Expanded(
          child: _buildEspelhoGrid(),
        ),
      ],
    );
  }

  Widget _buildTorreSelectorAndFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Seletor de torres
          if (_torres.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_torres.length, (index) {
                  final torre = _torres[index] as Map<String, dynamic>;
                  final isSelected = _torreSelecionada == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('Torre ${torre['nome']}'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _torreSelecionada = index);
                        }
                      },
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: AppColors.background,
                    ),
                  );
                }),
              ),
            ),
          const SizedBox(height: 8),
          // Filtros de status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', 'todos'),
                _buildFilterChip('Disponíveis', 'disponivel'),
                _buildFilterChip('Reservadas', 'reservada'),
                _buildFilterChip('Vendidas', 'vendida'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filtroStatus == value;
    Color chipColor;
    switch (value) {
      case 'disponivel':
        chipColor = AppColors.success;
        break;
      case 'reservada':
        chipColor = Colors.amber;
        break;
      case 'vendida':
        chipColor = AppColors.error;
        break;
      default:
        chipColor = AppColors.primaryBlue;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _filtroStatus = value);
        },
        selectedColor: chipColor.withOpacity(0.2),
        checkmarkColor: chipColor,
        labelStyle: TextStyle(
          color: isSelected ? chipColor : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? chipColor : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildLegenda() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendaItem('Disponível', AppColors.success),
          const SizedBox(width: 16),
          _buildLegendaItem('Reservada', Colors.amber),
          const SizedBox(width: 16),
          _buildLegendaItem('Vendida', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildLegendaItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEspelhoGrid() {
    if (_torreSelecionada >= _torres.length) return const SizedBox.shrink();

    final torre = _torres[_torreSelecionada] as Map<String, dynamic>;
    final andares = torre['andares'] as List<dynamic>? ?? [];

    if (andares.isEmpty) {
      return const Center(
        child: Text('Nenhum andar encontrado'),
      );
    }

    // Ordenar andares do maior para o menor (10º andar no topo)
    final andaresOrdenados = List<dynamic>.from(andares);
    andaresOrdenados.sort((a, b) {
      final andarA = (a as Map<String, dynamic>)['andar'] as int? ?? 0;
      final andarB = (b as Map<String, dynamic>)['andar'] as int? ?? 0;
      return andarB.compareTo(andarA);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: andaresOrdenados.length,
      itemBuilder: (context, index) {
        final andar = andaresOrdenados[index] as Map<String, dynamic>;
        return _buildAndarRow(andar);
      },
    );
  }

  Widget _buildAndarRow(Map<String, dynamic> andar) {
    final numeroAndar = andar['andar'] ?? 0;
    final unidades = andar['unidades'] as List<dynamic>? ?? [];

    // Filtrar unidades se necessário
    final unidadesFiltradas = _filtroStatus == 'todos'
        ? unidades
        : unidades.where((u) {
            final status = ((u as Map<String, dynamic>)['status'] ?? '').toString().toLowerCase();
            return status == _filtroStatus;
          }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador do andar
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${numeroAndar}º',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          // Unidades do andar
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: unidadesFiltradas.map((unidade) {
                return _buildUnidadeCell(unidade as Map<String, dynamic>);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnidadeCell(Map<String, dynamic> unidade) {
    final numero = unidade['numero']?.toString() ?? '';
    final status = (unidade['status'] ?? '').toString().toLowerCase();
    final statusColor = _getStatusColor(status);
    final area = unidade['area']?.toString() ?? '';
    
    // Apenas unidades disponíveis podem abrir detalhes
    final bool podeAbrirDetalhes = status == 'disponivel' || status == 'disponível';

    return GestureDetector(
      onTap: podeAbrirDetalhes ? () => _mostrarDetalhesUnidade(unidade) : null,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: statusColor.withOpacity(podeAbrirDetalhes ? 0.15 : 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              numero,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: podeAbrirDetalhes ? statusColor : statusColor.withOpacity(0.7),
              ),
            ),
            if (area.isNotEmpty)
              Text(
                '${area}m²',
                style: TextStyle(
                  fontSize: 9,
                  color: podeAbrirDetalhes ? statusColor.withOpacity(0.8) : statusColor.withOpacity(0.5),
                ),
              ),
            Icon(
              podeAbrirDetalhes ? Icons.touch_app : _getStatusIcon(status),
              size: 14,
              color: podeAbrirDetalhes ? statusColor : statusColor.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalhesUnidade(Map<String, dynamic> unidade) {
    final numero = unidade['numero']?.toString() ?? '';
    final status = (unidade['status'] ?? '').toString();
    final statusLabel = unidade['statusLabel'] ?? status;
    final statusColor = _getStatusColor(status);
    final valorFormatado = unidade['valorFormatado'] ?? '';
    final area = unidade['area']?.toString() ?? '';
    final quartos = unidade['quartos'] ?? 0;
    final suites = unidade['suites'] ?? 0;
    final banheiros = unidade['banheiros'] ?? 0;
    final posicao = unidade['posicao'] ?? '';
    final observacao = unidade['observacao'] ?? '';
    final valorM2 = unidade['valorM2'] ?? 0;
    final solManha = unidade['solManha'] == true;
    final solTarde = unidade['solTarde'] == true;
    final vistaEspecial = unidade['vistaEspecial'] == true;
    final unidadeId = unidade['id'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      numero,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unidade $numero',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (observacao.isNotEmpty)
                        Text(
                          observacao,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Valor
            if (valorFormatado.isNotEmpty && status.toLowerCase() != 'vendida')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold.withOpacity(0.1),
                      AppColors.primaryGold.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      valorFormatado,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    if (valorM2 > 0)
                      Text(
                        'R\$ ${valorM2.toStringAsFixed(2)}/m²',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Características
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (area.isNotEmpty) _buildChip(Icons.square_foot, '${area}m²'),
                if (quartos > 0) _buildChip(Icons.bed, '$quartos quartos'),
                if (suites > 0) _buildChip(Icons.king_bed, '$suites suíte(s)'),
                if (banheiros > 0) _buildChip(Icons.bathroom, '$banheiros banh.'),
                if (posicao.isNotEmpty) _buildChip(Icons.compass_calibration, posicao),
                if (solManha) _buildChip(Icons.wb_sunny, 'Sol manhã'),
                if (solTarde) _buildChip(Icons.wb_twilight, 'Sol tarde'),
                if (vistaEspecial) _buildChip(Icons.visibility, 'Vista especial'),
              ],
            ),
            const SizedBox(height: 20),

            // Botão de ação - apenas para disponíveis
            if (status.toLowerCase() == 'disponivel' || status.toLowerCase() == 'disponível')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _abrirDetalhesCompletos(unidade);
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Ver Detalhes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _abrirDetalhesCompletos(Map<String, dynamic> unidade) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _UnidadeDetalhesPage(
          unidade: unidade,
          imovelNome: widget.imovelNome,
          imovelId: widget.imovelId,
        ),
      ),
    );
  }

  Widget _buildEvolucaoTab() {
    final evolucao = _evolucaoVendas;
    
    if (evolucao == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Dados de evolução não disponíveis',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final velocidadeVenda = evolucao['velocidadeVenda'] as Map<String, dynamic>? ?? {};
    final previsaoEsgotamento = evolucao['previsaoEsgotamento'] as Map<String, dynamic>? ?? {};
    final ultimosMeses = evolucao['ultimosMeses'] as List<dynamic>? ?? [];

    final media3Meses = velocidadeVenda['mediaUltimos3Meses'] ?? 0.0;
    final media6Meses = velocidadeVenda['mediaUltimos6Meses'] ?? 0.0;
    final tendencia = velocidadeVenda['tendencia'] ?? '';
    final mesesRestantes = previsaoEsgotamento['mesesRestantes'] ?? 0;
    final dataEstimada = previsaoEsgotamento['dataEstimada'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Velocidade de Vendas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.speed, color: AppColors.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Velocidade de Vendas',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Últimos 3 meses',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            '${media3Meses.toStringAsFixed(1)} un/mês',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.border),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Últimos 6 meses',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Text(
                              '${media6Meses.toStringAsFixed(1)} un/mês',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tendência
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tendencia == 'crescente'
                  ? AppColors.success.withOpacity(0.1)
                  : tendencia == 'decrescente'
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: tendencia == 'crescente'
                    ? AppColors.success.withOpacity(0.3)
                    : tendencia == 'decrescente'
                        ? AppColors.error.withOpacity(0.3)
                        : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tendencia == 'crescente'
                        ? AppColors.success.withOpacity(0.2)
                        : tendencia == 'decrescente'
                            ? AppColors.error.withOpacity(0.2)
                            : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    tendencia == 'crescente'
                        ? Icons.trending_up
                        : tendencia == 'decrescente'
                            ? Icons.trending_down
                            : Icons.trending_flat,
                    color: tendencia == 'crescente'
                        ? AppColors.success
                        : tendencia == 'decrescente'
                            ? AppColors.error
                            : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tendência',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        tendencia == 'crescente'
                            ? 'Vendas em alta'
                            : tendencia == 'decrescente'
                                ? 'Vendas em baixa'
                                : 'Vendas estáveis',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  tendencia.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: tendencia == 'crescente'
                        ? AppColors.success
                        : tendencia == 'decrescente'
                            ? AppColors.error
                            : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Previsão de Esgotamento
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Previsão de Esgotamento',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (dataEstimada.isNotEmpty)
                        Text(
                          'Data estimada: $dataEstimada',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                Text(
                  '~$mesesRestantes meses',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Histórico de Vendas
          if (ultimosMeses.isNotEmpty) ...[
            const Text(
              'Histórico de Vendas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...ultimosMeses.map((mes) {
              final mesData = mes as Map<String, dynamic>;
              return _buildHistoricoItem(
                mesData['mes'] ?? '',
                mesData['vendas'] ?? 0,
                mesData['valor'] ?? 0,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoricoItem(String mes, int vendas, num valor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mes, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  _formatCurrency(valor.toDouble()),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$vendas vendas',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}K';
    }
    return 'R\$ ${value.toStringAsFixed(2)}';
  }
}

/// Página de detalhes completos da unidade
class _UnidadeDetalhesPage extends StatefulWidget {
  final Map<String, dynamic> unidade;
  final String imovelNome;
  final int imovelId;

  const _UnidadeDetalhesPage({
    required this.unidade,
    required this.imovelNome,
    required this.imovelId,
  });

  @override
  State<_UnidadeDetalhesPage> createState() => _UnidadeDetalhesPageState();
}

class _UnidadeDetalhesPageState extends State<_UnidadeDetalhesPage> {
  int _imagemAtiva = 0;

  String get _numero => widget.unidade['numero']?.toString() ?? '';
  String get _status => (widget.unidade['status'] ?? '').toString();
  String get _statusLabel => widget.unidade['statusLabel'] ?? _status;
  String get _valorFormatado => widget.unidade['valorFormatado'] ?? '';
  String get _area => widget.unidade['area']?.toString() ?? '';
  int get _quartos => widget.unidade['quartos'] ?? 0;
  int get _suites => widget.unidade['suites'] ?? 0;
  int get _banheiros => widget.unidade['banheiros'] ?? 0;
  String get _posicao => widget.unidade['posicao'] ?? '';
  String get _observacao => widget.unidade['observacao'] ?? '';
  num get _valorM2 => widget.unidade['valorM2'] ?? 0;
  bool get _solManha => widget.unidade['solManha'] == true;
  bool get _solTarde => widget.unidade['solTarde'] == true;
  bool get _vistaEspecial => widget.unidade['vistaEspecial'] == true;
  int get _andar => widget.unidade['andar'] ?? 0;

  // Imagens placeholder - em produção, viria da API
  List<String> get _imagens {
    // Se tiver imagens na unidade, usar
    final fotos = widget.unidade['fotos'] as List<dynamic>?;
    if (fotos != null && fotos.isNotEmpty) {
      return fotos.map((f) => f['url']?.toString() ?? '').where((url) => url.isNotEmpty).toList();
    }
    // Placeholder se não tiver imagens
    return [];
  }

  String get _linkCompartilhamento {
    return 'https://app.valeincorp.com.br/unidade/${widget.unidade['id']}';
  }

  void _compartilhar() {
    final unidadeId = widget.unidade['id'];
    if (unidadeId == null) {
      // Fallback para compartilhamento simples se não tiver ID
      final textoCompartilhamento = '''
🏠 *Unidade $_numero - ${widget.imovelNome}*

💰 *Valor:* $_valorFormatado
📐 *Área:* ${_area}m²
🛏️ *Quartos:* $_quartos
🚿 *Banheiros:* $_banheiros
${_suites > 0 ? '👑 *Suítes:* $_suites\n' : ''}🏢 *Andar:* ${_andar}º
📍 *Posição:* $_posicao
${_observacao.isNotEmpty ? '📝 *Obs:* $_observacao\n' : ''}
${_solManha ? '☀️ Sol da manhã\n' : ''}${_solTarde ? '🌅 Sol da tarde\n' : ''}${_vistaEspecial ? '🌆 Vista especial\n' : ''}
🔗 Veja mais detalhes:
$_linkCompartilhamento
''';
      Share.share(textoCompartilhamento, subject: 'Unidade $_numero - ${widget.imovelNome}');
      return;
    }

    ShareSettingsModal.show(
      context: context,
      entityType: 'unidade',
      entityId: unidadeId as int,
      entityNome: 'Unidade $_numero',
      entitySubtitulo: widget.imovelNome,
      imageUrl: _imagens.isNotEmpty ? _imagens.first : null,
    );
  }

  Color get _statusColor {
    switch (_status.toLowerCase()) {
      case 'disponivel':
      case 'disponível':
        return AppColors.success;
      case 'reservado':
      case 'reservada':
        return Colors.amber;
      case 'vendido':
      case 'vendida':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar com imagem
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: AppColors.primaryBlue, size: 20),
                ),
                onPressed: _compartilhar,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImagemHeader(),
            ),
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com número e status
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unidade $_numero',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.imovelNome,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (_observacao.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _observacao,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primaryGold,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _statusColor),
                        ),
                        child: Text(
                          _statusLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Card de valor
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.primaryBlue.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Valor',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _valorFormatado,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_valorM2 > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'R\$ ${_valorM2.toStringAsFixed(2)}/m²',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Características principais
                  const Text(
                    'Características',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid de características
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildCaracteristicaCard(Icons.square_foot, 'Área', '${_area}m²'),
                      _buildCaracteristicaCard(Icons.stairs, 'Andar', '${_andar}º'),
                      _buildCaracteristicaCard(Icons.bed, 'Quartos', '$_quartos'),
                      _buildCaracteristicaCard(Icons.bathroom, 'Banheiros', '$_banheiros'),
                      if (_suites > 0)
                        _buildCaracteristicaCard(Icons.king_bed, 'Suítes', '$_suites'),
                      if (_posicao.isNotEmpty)
                        _buildCaracteristicaCard(Icons.compass_calibration, 'Posição', _posicao),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Diferenciais
                  if (_solManha || _solTarde || _vistaEspecial) ...[
                    const Text(
                      'Diferenciais',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (_solManha)
                          _buildDiferencialChip(Icons.wb_sunny, 'Sol da Manhã', Colors.orange),
                        if (_solTarde)
                          _buildDiferencialChip(Icons.wb_twilight, 'Sol da Tarde', Colors.deepOrange),
                        if (_vistaEspecial)
                          _buildDiferencialChip(Icons.visibility, 'Vista Especial', AppColors.primaryBlue),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Botão de compartilhar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _compartilhar,
                      icon: const Icon(Icons.share),
                      label: const Text('Compartilhar Unidade'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagemHeader() {
    if (_imagens.isEmpty) {
      // Placeholder quando não há imagens
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlue.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.apartment,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Unidade $_numero',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_andar}º Andar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Carousel de imagens
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: _imagens.length,
          onPageChanged: (index) => setState(() => _imagemAtiva = index),
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: _imagens[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.background,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGold),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.primaryBlue,
                child: const Icon(Icons.apartment, size: 64, color: Colors.white),
              ),
            );
          },
        ),
        // Indicadores
        if (_imagens.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _imagens.length,
                (index) => Container(
                  width: _imagemAtiva == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _imagemAtiva == index ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaracteristicaCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiferencialChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
