import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../models/unidade.dart';
import '../services/imoveis_service.dart';
import '../widgets/share_settings_modal.dart';
import '../widgets/image_zoom_modal.dart';

class UnidadeDetalhesScreen extends StatefulWidget {
  final int unidadeId;

  const UnidadeDetalhesScreen({super.key, required this.unidadeId});

  @override
  State<UnidadeDetalhesScreen> createState() => _UnidadeDetalhesScreenState();
}

class _UnidadeDetalhesScreenState extends State<UnidadeDetalhesScreen>
    with SingleTickerProviderStateMixin {
  final ImoveisService _imoveisService = ImoveisService();
  late TabController _tabController;
  
  Unidade? _unidade;
  bool _carregando = true;
  String? _erro;
  int _imagemAtiva = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarUnidade();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarUnidade() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final response = await _imoveisService.getUnidadeById(widget.unidadeId);
      
      if (response.success && response.data != null) {
        setState(() => _unidade = response.data);
      } else {
        setState(() => _erro = response.message ?? 'Unidade não encontrada');
      }
    } catch (e) {
      setState(() => _erro = 'Erro ao carregar dados');
    }

    setState(() => _carregando = false);
  }

  void _compartilhar() {
    if (_unidade == null) return;
    
    ShareSettingsModal.show(
      context: context,
      entityType: 'unidade',
      entityId: widget.unidadeId,
      entityNome: 'Unidade ${_unidade!.numero}',
      entitySubtitulo: _unidade!.empreendimento.nome,
      imageUrl: _unidade!.fotos.isNotEmpty ? _unidade!.fotos.first.fotosUrl : null,
    );
  }

  void _abrirZoomModal(int index) {
    if (_unidade == null || _unidade!.fotos.isEmpty) return;
    
    final zoomImages = _unidade!.fotos.map((foto) => ZoomImage(
      url: foto.fotosUrl,
      legenda: 'Unidade ${_unidade!.numero} - ${_unidade!.empreendimento.nome}',
    )).toList();
    
    showImageZoom(context, zoomImages, initialIndex: index);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disponivel':
      case 'disponível':
        return AppColors.disponivel;
      case 'vendido':
      case 'vendida':
        return AppColors.vendido;
      case 'reservado':
      case 'reservada':
        return AppColors.reservado;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    }

    if (_erro != null || _unidade == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_erro ?? 'Erro desconhecido'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetalhesTab(),
                _buildVagasTab(),
                _buildLocalizacaoTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    final fotos = _unidade!.fotos;
    
    return Stack(
      children: [
        // Image carousel
        SizedBox(
          height: 280,
          child: fotos.isEmpty
              ? Container(
                  color: AppColors.background,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 64, color: AppColors.textHint),
                  ),
                )
              : GestureDetector(
                  onTap: () => _abrirZoomModal(_imagemAtiva),
                  child: PageView.builder(
                    itemCount: fotos.length,
                    onPageChanged: (index) => setState(() => _imagemAtiva = index),
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: fotos[index].fotosUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.background,
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.primaryGold),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.background,
                          child: const Icon(Icons.broken_image, size: 64, color: AppColors.textHint),
                        ),
                      );
                    },
                  ),
                ),
        ),
        
        // Gradient overlay
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),
        
        // Top bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(Icons.arrow_back, () => Navigator.pop(context)),
                Row(
                  children: [
                    _buildCircleButton(Icons.share, _compartilhar),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Page indicators
        if (fotos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(fotos.length, (index) {
                return Container(
                  width: _imagemAtiva == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _imagemAtiva == index
                        ? AppColors.primaryGold
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Detalhes'),
          Tab(text: 'Vagas'),
          Tab(text: 'Localização'),
        ],
      ),
    );
  }

  Widget _buildDetalhesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unidade ${_unidade!.numero}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _unidade!.empreendimento.nome,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(_unidade!.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _unidade!.statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Main info grid
          Row(
            children: [
              Expanded(child: _buildInfoTile('Andar', '${_unidade!.andar}º', Icons.layers)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoTile('Área', _unidade!.areaFormatada, Icons.square_foot)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoTile('Quartos', '${_unidade!.quartos}', Icons.bed)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoTile('Suítes', '${_unidade!.suites}', Icons.bathtub)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoTile('Banheiros', '${_unidade!.banheiros}', Icons.wc)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoTile('Vagas', '${_unidade!.vagasGaragem.length}', Icons.directions_car)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Características especiais
          _buildSection('Características', [
            _buildCheckItem('Vista especial', _unidade!.vistaEspecial),
            _buildCheckItem('Sol da manhã', _unidade!.solManha),
            _buildCheckItem('Sol da tarde', _unidade!.solTarde),
          ]),
          
          const SizedBox(height: 24),
          
          // Medidas
          if (_unidade!.medidas.isNotEmpty) ...[
            _buildSection(
              'Medidas',
              _unidade!.medidas.map((medida) {
                return _buildMedidaRow(medida.tipoNome, '${medida.valor} ${medida.tipoUnidade}');
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Descrição do empreendimento
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
                    Icon(Icons.business, color: AppColors.primaryBlue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sobre o Empreendimento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _unidade!.empreendimento.nome,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_unidade!.empreendimento.endereco != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${_unidade!.empreendimento.endereco!.bairro}, ${_unidade!.empreendimento.endereco!.cidade}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
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

  Widget _buildVagasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.1),
                  AppColors.primaryGold.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_car, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vagas de Garagem',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_unidade!.vagasGaragem.length} vaga${_unidade!.vagasGaragem.length != 1 ? 's' : ''} disponível${_unidade!.vagasGaragem.length != 1 ? 'is' : ''}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Lista de Vagas
          if (_unidade!.vagasGaragem.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.no_transfer, size: 48, color: AppColors.textHint),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma vaga de garagem',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_unidade!.vagasGaragem.length, (index) {
              final vaga = _unidade!.vagasGaragem[index];
              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
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
                          const Icon(Icons.directions_car, color: AppColors.primaryBlue, size: 24),
                          Text(
                            vaga.numero,
                            style: const TextStyle(
                              fontSize: 10,
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
                            'Vaga ${vaga.numero}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildVagaInfo(Icons.layers, vaga.pavimento),
                              const SizedBox(width: 12),
                              _buildVagaInfo(Icons.square_foot, '${vaga.area} m²'),
                            ],
                          ),
                          if (vaga.cobertura)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.roofing, color: AppColors.success, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'Coberta',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildVagaInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLocalizacaoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Localização na torre
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.05),
                  AppColors.primaryGold.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Localização no Empreendimento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildLocalizacaoCard(
                        'Torre',
                        _unidade!.torre.nome,
                        Icons.apartment,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLocalizacaoCard(
                        'Andar',
                        '${_unidade!.andar}º',
                        Icons.layers,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildLocalizacaoCard(
                        'Unidade',
                        _unidade!.numero.toString(),
                        Icons.home,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLocalizacaoCard(
                        'Posição',
                        _unidade!.posicao ?? 'N/A',
                        Icons.explore,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Endereço
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
                    Icon(Icons.location_on, color: AppColors.primaryBlue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Endereço do Empreendimento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_unidade!.empreendimento.endereco != null) ...[
                  _buildEnderecoRow('Logradouro', _unidade!.empreendimento.endereco!.logradouro),
                  _buildEnderecoRow('Bairro', _unidade!.empreendimento.endereco!.bairro),
                  _buildEnderecoRow('Cidade', _unidade!.empreendimento.endereco!.cidade),
                  _buildEnderecoRow('Estado', _unidade!.empreendimento.endereco!.estado),
                  _buildEnderecoRow('CEP', _unidade!.empreendimento.endereco!.cep),
                ] else
                  const Text(
                    'Endereço não disponível',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Características da posição
          _buildSection('Características da Posição', [
            _buildCheckItem('Vista especial', _unidade!.vistaEspecial),
            _buildCheckItem('Sol da manhã', _unidade!.solManha),
            _buildCheckItem('Sol da tarde', _unidade!.solTarde),
          ]),
          
          // Observações
          if (_unidade!.observacao != null && _unidade!.observacao!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Observações',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _unidade!.observacao!,
                    style: TextStyle(color: Colors.amber.shade800),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocalizacaoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnderecoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
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
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildCheckItem(String label, bool checked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.cancel,
            color: checked ? AppColors.success : AppColors.textHint,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: checked ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedidaRow(String label, String value) {
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
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Valor',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _unidade!.valorFormatado,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _compartilhar,
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Compartilhar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

