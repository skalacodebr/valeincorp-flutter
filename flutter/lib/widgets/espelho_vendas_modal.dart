import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/imoveis_service.dart';

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
  bool _showEvolucao = false;

  @override
  void initState() {
    super.initState();
    _showEvolucao = false; // TODO: Get from session storage
    _tabController = TabController(
      length: _showEvolucao ? 3 : 2,
      vsync: this,
    );
    _carregarEspelhoVendas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarEspelhoVendas() async {
    // Se já temos os dados do espelho de vendas, usar diretamente
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
      // Tratar erro 401 (não autenticado) de forma mais elegante
      setState(() {
        _error = 'É necessário fazer login para visualizar os detalhes do espelho de vendas';
        _loading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                          _buildTorresTab(),
                          if (_showEvolucao) _buildEvolucaoTab(),
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
            child: const Icon(Icons.bar_chart, color: Colors.white, size: 24),
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
        tabs: [
          const Tab(text: 'Resumo'),
          const Tab(text: 'Torres'),
          if (_showEvolucao) const Tab(text: 'Evolução'),
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
    final disponiveis = _espelhoData?['unidades_disponiveis'] ?? 0;
    final reservadas = _espelhoData?['unidades_reservadas'] ?? 0;
    final vendidas = _espelhoData?['unidades_vendidas'] ?? 0;
    final total = _espelhoData?['total_unidades'] ?? 0;

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
                  AppColors.success,
                  Icons.check_circle,
                  total,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResumoCard(
                  'Reservadas',
                  reservadas,
                  Colors.amber,
                  Icons.access_time,
                  total,
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
                  AppColors.error,
                  Icons.shopping_cart,
                  total,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResumoCard(
                  'Total',
                  total,
                  AppColors.primaryBlue,
                  Icons.home,
                  total,
                ),
              ),
            ],
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
                  total,
                  AppColors.success,
                ),
                const SizedBox(height: 12),
                _buildDistribuicaoBar(
                  'Reservadas',
                  reservadas,
                  total,
                  Colors.amber,
                ),
                const SizedBox(height: 12),
                _buildDistribuicaoBar(
                  'Vendidas',
                  vendidas,
                  total,
                  AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoCard(
    String label,
    int quantidade,
    Color color,
    IconData icon,
    int total,
  ) {
    final percentual = total > 0 ? (quantidade / total * 100).toStringAsFixed(1) : '0';

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
                '$percentual%',
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

  Widget _buildDistribuicaoBar(String label, int quantidade, int total, Color color) {
    final percentual = total > 0 ? quantidade / total : 0.0;

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
              '$quantidade (${(percentual * 100).toStringAsFixed(1)}%)',
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
            value: percentual,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTorresTab() {
    final torres = _espelhoData?['torres'] as List<dynamic>? ?? [];

    if (torres.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: torres.length,
      itemBuilder: (context, index) {
        final torre = torres[index] as Map<String, dynamic>;
        return _buildTorreCard(torre);
      },
    );
  }

  Widget _buildTorreCard(Map<String, dynamic> torre) {
    final nome = torre['nome'] ?? 'Torre';
    final andares = torre['numero_andares'] ?? 0;
    final unidadesPorAndar = torre['quantidade_unidades_andar'] ?? 0;
    final totalUnidades = torre['total_unidades'] ?? 0;
    final disponiveis = torre['unidades_disponiveis'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.apartment, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$andares andares • $unidadesPorAndar un./andar',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$disponiveis disp.',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTorreInfo('Total', '$totalUnidades'),
                      _buildTorreInfo('Disponíveis', '$disponiveis'),
                      _buildTorreInfo('Andares', '$andares'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Ver unidades da torre
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Ver Unidades'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTorreInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEvolucaoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Velocidade de Vendas',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Média últimos 3 meses',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '8 un/mês',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
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
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.trending_up, color: AppColors.success, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tendência',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Vendas em alta',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '+15%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
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
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Previsão de Esgotamento',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Baseado na velocidade atual',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '~6 meses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Histórico
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Histórico de Vendas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildHistoricoItem('Novembro 2025', 12),
          _buildHistoricoItem('Outubro 2025', 8),
          _buildHistoricoItem('Setembro 2025', 10),
          _buildHistoricoItem('Agosto 2025', 6),
        ],
      ),
    );
  }

  Widget _buildHistoricoItem(String mes, int vendas) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(mes, style: const TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              Text(
                '$vendas vendas',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textHint),
            ],
          ),
        ],
      ),
    );
  }
}
