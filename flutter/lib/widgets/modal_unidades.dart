import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../services/imoveis_service.dart';

class ModalUnidades extends StatefulWidget {
  final int imovelId;
  final String imovelNome;

  const ModalUnidades({
    super.key,
    required this.imovelId,
    required this.imovelNome,
  });

  @override
  State<ModalUnidades> createState() => _ModalUnidadesState();
}

class _ModalUnidadesState extends State<ModalUnidades> {
  final ImoveisService _imoveisService = ImoveisService();

  List<Map<String, dynamic>> _torres = [];
  List<Map<String, dynamic>> _unidades = [];
  int? _torreSelecionada;
  bool _carregandoTorres = true;
  bool _carregandoUnidades = false;
  String _filtroStatus = 'todos';
  String _busca = '';
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarTorres();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarTorres() async {
    setState(() => _carregandoTorres = true);

    try {
      final response = await _imoveisService.getTorres(widget.imovelId);
      if (response.success && response.data != null) {
        setState(() => _torres = List<Map<String, dynamic>>.from(response.data!));
      }
    } catch (e) {
      debugPrint('Erro ao carregar torres: $e');
    }

    setState(() => _carregandoTorres = false);
  }

  Future<void> _carregarUnidades(int torreId) async {
    setState(() {
      _carregandoUnidades = true;
      _torreSelecionada = torreId;
    });

    try {
      final response = await _imoveisService.getUnidadesPorTorre(torreId);
      if (response.success && response.data != null) {
        setState(() => _unidades = List<Map<String, dynamic>>.from(response.data!));
      }
    } catch (e) {
      debugPrint('Erro ao carregar unidades: $e');
    }

    setState(() => _carregandoUnidades = false);
  }

  List<Map<String, dynamic>> get _unidadesFiltradas {
    return _unidades.where((unidade) {
      // Filtro por status
      if (_filtroStatus != 'todos') {
        final status = _getStatusFromId(unidade['status_unidades_id'] as int?);
        if (status != _filtroStatus) return false;
      }

      // Filtro por busca
      if (_busca.isNotEmpty) {
        final numero = unidade['numero_apartamento']?.toString() ?? '';
        final tipologia = unidade['tipologia']?.toString().toLowerCase() ?? '';
        if (!numero.contains(_busca) && !tipologia.contains(_busca.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  String _getStatusFromId(int? statusId) {
    switch (statusId) {
      case 1:
        return 'disponivel';
      case 2:
        return 'reservado';
      case 3:
        return 'vendido';
      default:
        return 'indefinido';
    }
  }

  Color _getStatusColor(int? statusId) {
    switch (statusId) {
      case 1:
        return AppColors.success;
      case 2:
        return Colors.amber;
      case 3:
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  String _getStatusLabel(int? statusId) {
    switch (statusId) {
      case 1:
        return 'Disponível';
      case 2:
        return 'Reservado';
      case 3:
        return 'Vendido';
      default:
        return 'Indefinido';
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
          Expanded(
            child: Row(
              children: [
                // Lista de Torres
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: _buildTorresList(),
                ),
                // Divider
                Container(
                  width: 1,
                  color: AppColors.border,
                ),
                // Lista de Unidades
                Expanded(
                  child: _buildUnidadesList(),
                ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unidades Disponíveis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.imovelNome,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
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

  Widget _buildTorresList() {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.apartment, size: 18, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'Selecione a Torre',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregandoTorres
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryBlue),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _torres.length,
                    itemBuilder: (context, index) {
                      final torre = _torres[index];
                      final isSelected = _torreSelecionada == torre['id'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isSelected
                            ? AppColors.primaryBlue.withOpacity(0.1)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _carregarUnidades(torre['id'] as int),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      torre['nome'] ?? 'Torre',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.primaryBlue
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_right,
                                      size: 20,
                                      color: isSelected
                                          ? AppColors.primaryBlue
                                          : AppColors.textHint,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildTorreInfo(
                                  'Andares',
                                  '${torre['numero_andares'] ?? 0}',
                                ),
                                _buildTorreInfo(
                                  'Un./Andar',
                                  '${torre['quantidade_unidades_andar'] ?? 0}',
                                ),
                                _buildTorreInfo(
                                  'Total',
                                  '${torre['total_unidades'] ?? 0}',
                                  highlight: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTorreInfo(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: highlight ? AppColors.primaryBlue : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnidadesList() {
    if (_torreSelecionada == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apartment, size: 64, color: AppColors.textHint.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Selecione uma torre\npara ver as unidades',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filtros
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Título
              Row(
                children: [
                  Icon(Icons.home, size: 18, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Unidades da ${_torres.firstWhere((t) => t['id'] == _torreSelecionada)['nome'] ?? 'Torre'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Busca e Filtro
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _buscaController,
                      onChanged: (value) => setState(() => _busca = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar por número...',
                        hintStyle: const TextStyle(fontSize: 13),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primaryBlue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filtroStatus,
                        icon: const Icon(Icons.filter_list, size: 18),
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'todos', child: Text('Todos')),
                          DropdownMenuItem(value: 'disponivel', child: Text('Disponíveis')),
                          DropdownMenuItem(value: 'reservado', child: Text('Reservados')),
                          DropdownMenuItem(value: 'vendido', child: Text('Vendidos')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _filtroStatus = value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Lista de unidades
        Expanded(
          child: _carregandoUnidades
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                )
              : _unidadesFiltradas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_outlined, size: 48, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhuma unidade encontrada',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _unidadesFiltradas.length,
                      itemBuilder: (context, index) {
                        final unidade = _unidadesFiltradas[index];
                        return _buildUnidadeCard(unidade);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildUnidadeCard(Map<String, dynamic> unidade) {
    final statusId = unidade['status_unidades_id'] as int?;
    final statusColor = _getStatusColor(statusId);
    final statusLabel = _getStatusLabel(statusId);
    final isDisponivel = statusId == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDisponivel ? AppColors.border : AppColors.border.withOpacity(0.5),
        ),
      ),
      child: Opacity(
        opacity: isDisponivel ? 1.0 : 0.7,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unidade ${unidade['numero_apartamento'] ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${unidade['numero_andar_apartamento'] ?? 0}º Andar${unidade['posicao'] != null ? ' - ${unidade['posicao']}' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Detalhes
              Row(
                children: [
                  _buildDetalhe('Tipologia', unidade['tipologia'] ?? 'N/A'),
                  _buildDetalhe('Área', '${unidade['tamanho_unidade_metros_quadrados'] ?? 0} m²'),
                ],
              ),
              Row(
                children: [
                  _buildDetalhe(
                    'Quartos',
                    '${unidade['numero_quartos'] ?? 0} (${unidade['numero_suites'] ?? 0} suíte${(unidade['numero_suites'] ?? 0) != 1 ? 's' : ''})',
                  ),
                  _buildDetalhe('Banheiros', '${unidade['numero_banheiros'] ?? 0}'),
                ],
              ),
              const SizedBox(height: 12),
              // Valor e botão
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isDisponivel) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Valor',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          _formatarValor(unidade['valor']),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.unidadeDetalhes,
                          arguments: unidade['id'] as int,
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Ver Detalhes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ] else
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Entre em contato para mais informações',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetalhe(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarValor(dynamic valor) {
    if (valor == null) return 'N/A';
    final num = double.tryParse(valor.toString()) ?? 0;
    return 'R\$ ${num.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

