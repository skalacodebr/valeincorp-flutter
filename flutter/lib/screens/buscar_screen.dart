import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../services/imoveis_service.dart';
import '../widgets/campo_input.dart';
import '../widgets/bottom_navigation.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  final ImoveisService _imoveisService = ImoveisService();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorDeController = TextEditingController();
  final TextEditingController _valorAteController = TextEditingController();

  final _moedaMask = MaskTextInputFormatter(
    mask: 'R\$ ###.###.###,##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  List<String> _estados = ['Todos'];
  List<String> _cidades = ['Todos'];
  List<String> _bairros = ['Todos'];
  
  String _estadoSelecionado = 'Todos';
  String _cidadeSelecionada = 'Todos';
  String _bairroSelecionado = 'Todos';
  
  List<String> _localizacoesSelecionadas = [];
  bool _carregandoFiltros = true;

  @override
  void initState() {
    super.initState();
    _carregarFiltros();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorDeController.dispose();
    _valorAteController.dispose();
    super.dispose();
  }

  Future<void> _carregarFiltros() async {
    setState(() => _carregandoFiltros = true);
    
    try {
      final response = await _imoveisService.list(page: 1, limit: 1000);
      if (response.success && response.data != null) {
        final imoveisList = response.data!;
        
        final estadosSet = <String>{'Todos'};
        final cidadesSet = <String>{'Todos'};
        final bairrosSet = <String>{'Todos'};
        
        for (final imovel in imoveisList) {
          if (imovel.endereco?.estado != null && imovel.endereco!.estado.isNotEmpty) {
            estadosSet.add(imovel.endereco!.estado);
          }
          final cidade = imovel.endereco?.cidade ?? imovel.cidade;
          if (cidade.isNotEmpty) {
            cidadesSet.add(cidade);
          }
          if (imovel.endereco?.bairro != null && imovel.endereco!.bairro.isNotEmpty) {
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
    
    setState(() => _carregandoFiltros = false);
  }

  void _adicionarLocalizacao() {
    String localizacao = '';
    
    if (_bairroSelecionado != 'Todos') {
      localizacao = _bairroSelecionado;
    } else if (_cidadeSelecionada != 'Todos') {
      localizacao = _cidadeSelecionada;
    } else if (_estadoSelecionado != 'Todos') {
      localizacao = _estadoSelecionado;
    }
    
    if (localizacao.isNotEmpty && !_localizacoesSelecionadas.contains(localizacao)) {
      setState(() {
        _localizacoesSelecionadas.add(localizacao);
        _estadoSelecionado = 'Todos';
        _cidadeSelecionada = 'Todos';
        _bairroSelecionado = 'Todos';
      });
    }
  }

  void _removerLocalizacao(String localizacao) {
    setState(() {
      _localizacoesSelecionadas.remove(localizacao);
    });
  }

  double? _parseMoeda(String valor) {
    if (valor.isEmpty) return null;
    final numeros = valor.replaceAll(RegExp(r'[^\d]'), '');
    if (numeros.isEmpty) return null;
    return double.parse(numeros) / 100;
  }

  void _buscar() {
    final Map<String, dynamic> filtros = {
      'page': 1,
      'limit': 20,
    };
    
    final valorDe = _parseMoeda(_valorDeController.text);
    final valorAte = _parseMoeda(_valorAteController.text);
    
    if (valorDe != null) filtros['valorDe'] = valorDe;
    if (valorAte != null) filtros['valorAte'] = valorAte;
    if (_nomeController.text.trim().isNotEmpty) {
      filtros['search'] = _nomeController.text.trim();
    }
    if (_localizacoesSelecionadas.isNotEmpty) {
      filtros['localizacoes'] = _localizacoesSelecionadas.join(';');
    }
    
    Navigator.pushNamed(
      context,
      AppRoutes.empreendimentos,
      arguments: filtros,
    );
  }

  void _limparFiltros() {
    setState(() {
      _nomeController.clear();
      _valorDeController.clear();
      _valorAteController.clear();
      _estadoSelecionado = 'Todos';
      _cidadeSelecionada = 'Todos';
      _bairroSelecionado = 'Todos';
      _localizacoesSelecionadas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do imóvel
                  CampoInput(
                    label: 'Nome do empreendimento',
                    hint: 'Digite o nome ou código',
                    controller: _nomeController,
                    prefixIcon: Icons.search,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Localização
                  const Text(
                    'Localização',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_carregandoFiltros)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryGold),
                    )
                  else
                    Column(
                      children: [
                        _buildDropdown('Estado', _estados, _estadoSelecionado, (value) {
                          setState(() => _estadoSelecionado = value!);
                        }),
                        const SizedBox(height: 12),
                        _buildDropdown('Cidade', _cidades, _cidadeSelecionada, (value) {
                          setState(() => _cidadeSelecionada = value!);
                        }),
                        const SizedBox(height: 12),
                        _buildDropdown('Bairro', _bairros, _bairroSelecionado, (value) {
                          setState(() => _bairroSelecionado = value!);
                        }),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _adicionarLocalizacao,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar localização'),
                          ),
                        ),
                      ],
                    ),
                  
                  // Localizações selecionadas
                  if (_localizacoesSelecionadas.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Localizações selecionadas:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _localizacoesSelecionadas.map((loc) {
                        return Chip(
                          label: Text(loc),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removerLocalizacao(loc),
                          backgroundColor: AppColors.primaryGold.withOpacity(0.1),
                          deleteIconColor: AppColors.primaryGold,
                          labelStyle: const TextStyle(color: AppColors.primaryGold),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Faixa de valor
                  const Text(
                    'Faixa de Valor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CampoInput(
                          label: 'De',
                          hint: 'R\$ 0,00',
                          controller: _valorDeController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.attach_money,
                          inputFormatters: [_moedaMask],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CampoInput(
                          label: 'Até',
                          hint: 'R\$ 0,00',
                          controller: _valorAteController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.attach_money,
                          inputFormatters: [_moedaMask],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botões
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _buscar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Buscar imóveis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _limparFiltros,
                      child: const Text(
                        'Limpar filtros',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentItem: NavItem.buscar),
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
                child: const Icon(Icons.search, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Buscar Imóveis',
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

  Widget _buildDropdown(
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

