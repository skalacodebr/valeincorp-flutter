import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import '../config/theme.dart';
import '../models/imovel_detalhes.dart';
import '../services/imoveis_service.dart';
import '../providers/favoritos_provider.dart';
import '../widgets/espelho_vendas_modal.dart';
import '../widgets/modal_unidades.dart';
import '../widgets/stories_modal.dart';
import '../widgets/share_settings_modal.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/documento_viewer.dart';
import '../widgets/info_card_flutuante.dart';
import '../widgets/diferenciais_grid.dart';
import '../widgets/acesso_rapido_section.dart';
import '../widgets/galeria_categorias.dart';
import '../widgets/andamento_obra_section.dart';
import '../widgets/documentos_list.dart';
import '../widgets/plantas_section.dart';
import '../widgets/acoes_bar.dart';

class ImovelDetalhesScreen extends StatefulWidget {
  final int imovelId;

  const ImovelDetalhesScreen({super.key, required this.imovelId});

  @override
  State<ImovelDetalhesScreen> createState() => _ImovelDetalhesScreenState();
}

class _ImovelDetalhesScreenState extends State<ImovelDetalhesScreen>
    with SingleTickerProviderStateMixin {
  final ImoveisService _imoveisService = ImoveisService();
  late TabController _tabController;

  ImovelDetalhes? _imovel;
  Map<String, dynamic>? _empreendimentoDetalhes;
  bool _carregando = true;
  String? _erro;
  bool _mostrarMais = false;
  int _videoAtivo = 0;
  
  // Coordenadas do mapa (geocoding)
  double? _mapLatitude;
  double? _mapLongitude;
  bool _carregandoMapa = false;
  String? _enderecoMapa;

  @override
  void initState() {
    super.initState();
    // 5 tabs: Sobre, Localização, Documentos, Valores, Plantas
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final response = await _imoveisService.getById(widget.imovelId);

      if (response.success && response.data != null) {
        setState(() => _imovel = response.data);

        try {
          final empResponse = await _imoveisService.getEmpreendimentoDetalhes(widget.imovelId);
          if (empResponse.success) {
            setState(() => _empreendimentoDetalhes = empResponse.data);
          }
        } catch (e) {
          debugPrint('Erro ao carregar empreendimento: $e');
        }
        
        _carregarCoordenadas();
      } else {
        setState(() => _erro = response.message ?? 'Imóvel não encontrado');
      }
    } catch (e) {
      setState(() => _erro = 'Erro ao carregar dados');
    }

    setState(() => _carregando = false);
  }

  Future<void> _carregarCoordenadas() async {
    if (_imovel == null) return;
    
    setState(() => _carregandoMapa = true);
    
    try {
      if (_imovel!.coordenadas != null &&
          _imovel!.coordenadas!.latitude != 0 &&
          _imovel!.coordenadas!.longitude != 0 &&
          _imovel!.coordenadas!.latitude != -23.5505) {
        setState(() {
          _mapLatitude = _imovel!.coordenadas!.latitude;
          _mapLongitude = _imovel!.coordenadas!.longitude;
          _enderecoMapa = _imovel!.localizacao;
          _carregandoMapa = false;
        });
        return;
      }
      
      String endereco = '';
      if (_imovel!.endereco != null) {
        final end = _imovel!.endereco!;
        final partes = <String>[];
        if (end.logradouro.isNotEmpty) partes.add(end.logradouro);
        if (end.bairro.isNotEmpty) partes.add(end.bairro);
        if (end.cidade.isNotEmpty) partes.add(end.cidade);
        if (end.estado.isNotEmpty) partes.add(end.estado);
        endereco = partes.join(', ');
        if (endereco.isNotEmpty) endereco += ', Brasil';
      }
      
      if (endereco.isEmpty) {
        endereco = '${_imovel!.localizacao}, Brasil';
      }
      
      setState(() => _enderecoMapa = endereco);
      
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': endereco,
          'format': 'json',
          'limit': 1,
        },
        options: Options(
          headers: {'User-Agent': 'ValeincorpApp/1.0'},
        ),
      );
      
      if (response.data != null && (response.data as List).isNotEmpty) {
        final result = response.data[0];
        setState(() {
          _mapLatitude = double.parse(result['lat']);
          _mapLongitude = double.parse(result['lon']);
        });
      }
    } catch (e) {
      debugPrint('Erro no geocoding: $e');
    }
    
    setState(() => _carregandoMapa = false);
  }

  void _abrirEspelhoVendas() {
    debugPrint('[EspelhoVendas] Abrindo modal...');
    debugPrint('[EspelhoVendas] imovelId: ${widget.imovelId}');
    debugPrint('[EspelhoVendas] espelhoVendasData: ${_imovel?.espelhoVendas}');
    debugPrint('[EspelhoVendas] torres: ${_imovel?.espelhoVendas?['torres']}');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EspelhoVendasModal(
        imovelId: widget.imovelId,
        imovelNome: _imovel?.nome ?? '',
        espelhoVendasData: _imovel?.espelhoVendas,
      ),
    );
  }

  void _abrirModalUnidades() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalUnidades(
        imovelId: widget.imovelId,
        imovelNome: _imovel?.nome ?? '',
      ),
    );
  }

  void _abrirCompartilhamento() {
    ShareSettingsModal.show(
      context: context,
      entityType: 'empreendimento',
      entityId: widget.imovelId,
      entityNome: _imovel?.nome ?? 'Empreendimento',
      entitySubtitulo: _imovel?.localizacao,
      imageUrl: _imovel?.imagem,
    );
  }

  void _abrirQrCode() {
    final shareUrl = 'https://app.valeincorp.com.br/empreendimento/${widget.imovelId}';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'QR Code do Empreendimento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _imovel?.nome ?? '',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(Icons.qr_code_2, size: 120, color: AppColors.primaryBlue),
                    const SizedBox(height: 12),
                    Text(
                      shareUrl,
                      style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Escaneie para acessar',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _irParaDocumentos() {
    _tabController.animateTo(2);
  }

  void _abrirStory(Story story) {
    if (story.imagens.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoriesModal(story: story)),
    );
  }

  Future<void> _abrirGoogleMaps() async {
    if (_imovel?.endereco == null) return;

    final endereco = '${_imovel!.endereco!.logradouro} ${_imovel!.endereco!.bairro} '
        '${_imovel!.endereco!.cidade} ${_imovel!.endereco!.estado} ${_imovel!.endereco!.cep}';

    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(endereco)}';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Erro ao abrir Maps: $e');
    }
  }

  void _abrirPdf() {
    final pdfDoc = _imovel?.documentos.where((d) => d.isPdf).firstOrNull;
    
    if (pdfDoc != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DocumentoViewer(documento: pdfDoc)),
      );
    } else if (_imovel?.documentos.isNotEmpty == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DocumentoViewer(documento: _imovel!.documentos.first)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum documento disponível'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryGold),
              SizedBox(height: 16),
              Text('Carregando detalhes do imóvel...'),
            ],
          ),
        ),
      );
    }

    if (_erro != null || _imovel == null) {
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Conteúdo scrollável
          CustomScrollView(
            slivers: [
              // Header com imagem
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Imagem de fundo
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: _buildHeaderImage(),
                    ),
                    // Card flutuante
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -30,
                      child: InfoCardFlutuante(imovel: _imovel!),
                    ),
                  ],
                ),
              ),
              // Espaço para o card
              const SliverToBoxAdapter(child: SizedBox(height: 38)),
              // Tabs
              SliverToBoxAdapter(child: _buildTabs()),
              // Barra de ações
              SliverToBoxAdapter(
                child: AcoesBar(
                  onPdfTap: _abrirPdf,
                  onEspelhoVendasTap: _abrirEspelhoVendas,
                  onCompartilharTap: _abrirCompartilhamento,
                ),
              ),
              // Conteúdo da tab ativa
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildActiveTabContent(),
              ),
            ],
          ),
          // Botões de navegação fixos no topo
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(Icons.arrow_back, () => Navigator.pop(context)),
                Consumer<FavoritosProvider>(
                  builder: (context, favoritosProvider, child) {
                    final isFavorito = favoritosProvider.isFavorito(_imovel!.id);
                    return _buildCircleButton(
                      isFavorito ? Icons.favorite : Icons.favorite_border,
                      () async {
                        final wasIsFavorito = isFavorito;
                        final result = await favoritosProvider.toggleFavorito(_imovel!);
                        if (mounted) {
                          if (result) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(wasIsFavorito ? 'Removido dos favoritos' : 'Adicionado aos favoritos'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: wasIsFavorito ? AppColors.textSecondary : AppColors.success,
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
                      color: isFavorito ? Colors.red : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: _empreendimentoDetalhes?['imagem_empreendimento'] ?? _imovel?.imagem ?? '',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Container(
            color: AppColors.background,
            child: const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.background,
            child: const Icon(Icons.apartment, size: 64, color: AppColors.textHint),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _imovel!.status,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _imovel!.nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black45)],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _imovel!.localizacao,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  shadows: const [Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black45)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTabContent() {
    switch (_tabController.index) {
      case 0:
        return _buildSobreContent();
      case 1:
        return _buildLocalizacaoContent();
      case 2:
        return _buildDocumentosContent();
      case 3:
        return _buildValoresContent();
      case 4:
        return _buildPlantasContent();
      default:
        return _buildSobreContent();
    }
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color ?? AppColors.textPrimary, size: 20),
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
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Sobre'),
          Tab(text: 'Localização'),
          Tab(text: 'Documentos'),
          Tab(text: 'Valores'),
          Tab(text: 'Plantas'),
        ],
      ),
    );
  }

  Widget _buildSobreContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Galeria de Fotos (Stories)
          if (_imovel!.stories.isNotEmpty) ...[
            GaleriaCategorias(
              stories: _imovel!.stories,
              onStoryTap: _abrirStory,
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 24),
          ],

          // Descrição com "Continuar lendo"
          if (_imovel!.descricao != null && _imovel!.descricao!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _imovel!.descricao!,
                    maxLines: _mostrarMais ? null : 4,
                    overflow: _mostrarMais ? null : TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 14),
                  ),
                  if (_imovel!.descricao!.length > 200)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _mostrarMais = !_mostrarMais),
                        child: Text(
                          _mostrarMais ? 'Ver menos' : 'Continuar lendo',
                          style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Diferenciais
          if (_imovel!.diferenciais.isNotEmpty) ...[
            DiferenciaisGrid(
              diferenciais: _imovel!.diferenciais,
              diferencialAdicional: _empreendimentoDetalhes?['diferenciais_adicionais'],
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 24),
          ],

          // Vídeos - busca de múltiplas fontes
          if (_temVideos()) ...[
            _buildVideosSection(),
            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 24),
          ],

          // Andamento da Obra
          if (_imovel!.andamentoObra.isNotEmpty) ...[
            AndamentoObraSection(andamentoObra: _imovel!.andamentoObra),
            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 24),
          ],

          // Acesso Rápido
          AcessoRapidoSection(
            onCompartilharTap: _abrirCompartilhamento,
            onDocumentosTap: _irParaDocumentos,
          ),
          const SizedBox(height: 24),

          // Visão Geral - Unidades
          _buildVisaoGeralSection(),
        ],
      ),
    );
  }

  Widget _buildVisaoGeralSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Visão geral',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                'Área comum',
                _imovel!.areaComum != null ? '${_imovel!.areaComum} m²' : 'N/A',
                Icons.people,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                'Área total',
                _imovel!.areaTotal != null ? '${_imovel!.areaTotal} m²' : 'N/A',
                Icons.square_foot,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Retorna lista de URLs de vídeos de todas as fontes disponíveis
  List<String> _getVideosUrls() {
    final List<String> videos = [];
    
    // 1. Vídeo único do imóvel (videoUrl)
    if (_imovel?.videoUrl != null && _imovel!.videoUrl!.isNotEmpty) {
      videos.add(_imovel!.videoUrl!);
    }
    
    // 2. Lista de vídeos do imóvel (videosUnidades)
    if (_imovel?.videosUnidades.isNotEmpty == true) {
      for (final video in _imovel!.videosUnidades) {
        if (video.videoUrl.isNotEmpty) {
          videos.add(video.videoUrl);
        }
      }
    }
    
    // 3. Vídeos do empreendimento detalhes (videos_unidades)
    if (_empreendimentoDetalhes?['videos_unidades'] != null) {
      final videosEmp = _empreendimentoDetalhes!['videos_unidades'] as List;
      for (final video in videosEmp) {
        final url = video['video_url']?.toString() ?? '';
        if (url.isNotEmpty && !videos.contains(url)) {
          videos.add(url);
        }
      }
    }
    
    // 4. Vídeo único do empreendimento (video_url)
    if (_empreendimentoDetalhes?['video_url'] != null) {
      final url = _empreendimentoDetalhes!['video_url'].toString();
      if (url.isNotEmpty && !videos.contains(url)) {
        videos.add(url);
      }
    }
    
    return videos;
  }
  
  bool _temVideos() {
    return _getVideosUrls().isNotEmpty;
  }

  Widget _buildVideosSection() {
    final videos = _getVideosUrls();
    if (videos.isEmpty) return const SizedBox.shrink();

    // Garantir que o índice do vídeo ativo é válido
    if (_videoAtivo >= videos.length) {
      _videoAtivo = 0;
    }

    final videoAtualUrl = videos[_videoAtivo];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Vídeo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: VideoPlayerWidget(videoUrl: videoAtualUrl),
                ),
              ),
              if (videos.length > 1) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    videos.length,
                    (index) => GestureDetector(
                      onTap: () => setState(() => _videoAtivo = index),
                      child: Container(
                        width: index == _videoAtivo ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index == _videoAtivo ? AppColors.primaryBlue : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _abrirCompartilhamento,
                  icon: const Icon(Icons.share_outlined, size: 16, color: AppColors.primaryBlue),
                  label: const Text('Compartilhar', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalizacaoContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Localização',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.05),
                  AppColors.primaryGold.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Endereço Completo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                if (_imovel!.endereco != null) ...[
                  _buildEnderecoRow('Logradouro', _imovel!.endereco!.logradouro),
                  _buildEnderecoRow('Bairro', _imovel!.endereco!.bairro),
                  _buildEnderecoRow('Cidade', _imovel!.endereco!.cidade),
                  _buildEnderecoRow('Estado', _imovel!.endereco!.estado),
                  _buildEnderecoRow('CEP', _imovel!.endereco!.cep),
                ] else
                  _buildEnderecoRow('Endereço', _imovel!.localizacao),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildMapaInterativo(),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _abrirGoogleMaps,
              icon: const Icon(Icons.map),
              label: const Text('Ver no Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          if (_imovel!.pontosReferencia.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildProximidadeCard(
              'Pontos de Referência',
              Icons.place_outlined,
              _imovel!.pontosReferencia.map((p) => {'nome': p.nome, 'distancia': p.distancia}).toList(),
              AppColors.primaryBlue,
            ),
          ],
          
          if (_imovel!.transporte.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildProximidadeCard(
              'Transporte',
              Icons.directions_bus_outlined,
              _imovel!.transporte.map((t) => {'nome': t.nome, 'distancia': t.distancia}).toList(),
              AppColors.primaryGold,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProximidadeCard(String titulo, IconData icone, List<Map<String, String>> itens, Color cor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: cor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...itens.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == itens.length - 1;
            
            return Column(
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item['nome'] ?? '', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: cor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(item['distancia'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cor)),
                    ),
                  ],
                ),
                if (!isLast) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMapaInterativo() {
    if (_carregandoMapa) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primaryBlue)),
              SizedBox(height: 12),
              Text('Carregando mapa...', style: TextStyle(color: AppColors.textHint)),
            ],
          ),
        ),
      );
    }
    
    if (_mapLatitude == null || _mapLongitude == null) {
      return Container(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 48, color: AppColors.textHint),
              const SizedBox(height: 8),
              Text(_enderecoMapa ?? 'Localização não disponível', style: const TextStyle(color: AppColors.textHint, fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(_mapLatitude!, _mapLongitude!),
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.valeincorp.app',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(_mapLatitude!, _mapLongitude!),
                  width: 50,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)],
                    ),
                    child: const Icon(Icons.home, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _enderecoMapa ?? _imovel?.localizacao ?? '',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnderecoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value, style: const TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildDocumentosContent() {
    return DocumentosList(
      documentos: _imovel!.documentos,
      onDocumentoTap: (documento) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentoViewer(documento: documento)));
      },
    );
  }

  Widget _buildValoresContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.attach_money, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Valores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(
                  _imovel!.precoFormatado ?? 'R\$ ${_imovel!.preco}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 4),
                const Text('Valor total do terreno', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  'Valor por m²',
                  _imovel!.valorM2 != null ? 'R\$ ${_imovel!.valorM2}' : 'N/A',
                  Icons.square_foot,
                  AppColors.primaryGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile('Condições', 'À vista/Financiado', Icons.payment, AppColors.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
                    Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text('Observações Importantes', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber.shade800)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Valores sujeitos a alteração sem aviso prévio\n'
                  '• Consulte taxas e impostos adicionais\n'
                  '• Documentação e aprovações em dia',
                  style: TextStyle(fontSize: 13, color: Colors.amber.shade800, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantasContent() {
    return PlantasSection(
      stories: _imovel!.stories,
      onPlantaTap: _abrirStory,
    );
  }
}
