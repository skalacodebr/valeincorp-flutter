import 'imovel.dart';

class ImovelDetalhes extends Imovel {
  final String? descricao;
  final List<String> imagens;
  final String? videoUrl;
  final List<Diferencial> diferenciais;
  final List<AndamentoObra> andamentoObra;
  final List<Story> stories;
  final List<PontoReferencia> pontosReferencia;
  final List<Transporte> transporte;
  final List<Documento> documentos;
  final List<VideoUnidade> videosUnidades;
  final Map<String, dynamic>? espelhoVendas;

  ImovelDetalhes({
    required super.id,
    required super.codigo,
    required super.nome,
    super.imagem,
    required super.localizacao,
    super.dataEntrega,
    required super.corretor,
    required super.cidade,
    required super.status,
    required super.preco,
    super.precoFormatado,
    super.dormitorios = 0,
    super.banheiros = 0,
    super.suites = 0,
    super.suitesMaster,
    super.vagas = 0,
    super.area = 0,
    super.areaComum,
    super.areaTotal,
    super.unidadesDisponiveis,
    super.totalUnidades,
    super.unidadesVendidas,
    super.percentualVendido,
    super.statusVenda,
    super.valorM2,
    super.coordenadas,
    super.endereco,
    super.createdAt,
    super.updatedAt,
    this.descricao,
    this.imagens = const [],
    this.videoUrl,
    this.diferenciais = const [],
    this.andamentoObra = const [],
    this.stories = const [],
    this.pontosReferencia = const [],
    this.transporte = const [],
    this.documentos = const [],
    this.videosUnidades = const [],
    this.espelhoVendas,
  });

  factory ImovelDetalhes.fromJson(Map<String, dynamic> json) {
    return ImovelDetalhes(
      id: json['id'] ?? 0,
      codigo: json['codigo'] ?? '',
      nome: json['nome'] ?? '',
      imagem: json['imagem'] ?? json['imagem_empreendimento'],
      localizacao: json['localizacao'] ?? '',
      dataEntrega: json['dataEntrega'] ?? json['data_entrega'] ?? json['data'],
      corretor: json['corretor'] ?? '',
      cidade: json['cidade'] ?? json['endereco']?['cidade'] ?? '',
      status: json['status'] ?? 'Disponível',
      preco: (json['preco'] ?? 0).toDouble(),
      precoFormatado: json['precoFormatado'],
      dormitorios: json['dormitorios'] ?? 0,
      banheiros: json['banheiros'] ?? 0,
      suites: json['suites'] ?? 0,
      suitesMaster: json['suitesMaster'] ?? json['suites_master'],
      vagas: json['vagas'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      areaComum: json['areaComum'] != null ? (json['areaComum']).toDouble() : null,
      areaTotal: json['areaTotal'] != null 
          ? (json['areaTotal']).toDouble() 
          : json['area_total'] != null 
              ? (json['area_total']).toDouble() 
              : null,
      unidadesDisponiveis: json['unidadesDisponiveis'] ?? json['unidades_disponiveis'],
      totalUnidades: json['totalUnidades'] ?? json['total_unidades'],
      unidadesVendidas: json['unidadesVendidas'] ?? json['unidades_vendidas'],
      percentualVendido: json['percentualVendido'] != null 
          ? (json['percentualVendido']).toDouble() 
          : null,
      statusVenda: json['statusVenda'] ?? json['status_venda'],
      valorM2: json['valorM2'] != null ? (json['valorM2']).toDouble() : null,
      coordenadas: json['coordenadas'] != null 
          ? Coordenadas.fromJson(json['coordenadas']) 
          : null,
      endereco: json['endereco'] != null 
          ? Endereco.fromJson(json['endereco']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      descricao: json['descricao'],
      imagens: (json['imagens'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      videoUrl: json['videoUrl'],
      diferenciais: (json['diferenciais'] as List<dynamic>?)
          ?.map((e) => Diferencial.fromJson(e))
          .toList() ?? [],
      andamentoObra: (json['andamentoObra'] as List<dynamic>?)
          ?.map((e) => AndamentoObra.fromJson(e))
          .toList() ?? [],
      stories: (json['stories'] as List<dynamic>?)
          ?.map((e) => Story.fromJson(e))
          .toList() ?? [],
      pontosReferencia: (json['pontosReferencia'] as List<dynamic>?)
          ?.map((e) => PontoReferencia.fromJson(e))
          .toList() ?? [],
      transporte: (json['transporte'] as List<dynamic>?)
          ?.map((e) => Transporte.fromJson(e))
          .toList() ?? [],
      documentos: (json['documentos'] as List<dynamic>?)
          ?.map((e) => Documento.fromJson(e))
          .toList() ?? [],
      videosUnidades: (json['videos_unidades'] as List<dynamic>?)
          ?.map((e) => VideoUnidade.fromJson(e))
          .toList() ?? [],
      espelhoVendas: json['espelhoVendas'] as Map<String, dynamic>?,
    );
  }
}

class Diferencial {
  final int id;
  final String nome;
  final String icone;

  Diferencial({
    required this.id,
    required this.nome,
    required this.icone,
  });

  factory Diferencial.fromJson(Map<String, dynamic> json) {
    return Diferencial(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      icone: json['icone'] ?? '',
    );
  }
}

class AndamentoObra {
  final String nome;
  final int progresso;

  AndamentoObra({
    required this.nome,
    required this.progresso,
  });

  factory AndamentoObra.fromJson(Map<String, dynamic> json) {
    return AndamentoObra(
      nome: json['nome'] ?? '',
      progresso: json['progresso'] ?? 0,
    );
  }
}

class Story {
  final int id;
  final String titulo;
  final String tipo;
  final String? descricao;
  final List<StoryImage> imagens;

  Story({
    required this.id,
    required this.titulo,
    required this.tipo,
    this.descricao,
    this.imagens = const [],
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    final imagensList = json['imagens'] as List<dynamic>? ?? [];
    
    return Story(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      tipo: json['tipo'] ?? '',
      descricao: json['descricao'],
      imagens: imagensList.map((e) {
        if (e is String) {
          return StoryImage(fotosUrl: e);
        } else if (e is Map<String, dynamic>) {
          return StoryImage.fromJson(e);
        }
        return StoryImage(fotosUrl: e.toString());
      }).toList(),
    );
  }
}

class StoryImage {
  final String fotosUrl;
  final String? legenda;

  StoryImage({
    required this.fotosUrl,
    this.legenda,
  });

  factory StoryImage.fromJson(Map<String, dynamic> json) {
    return StoryImage(
      fotosUrl: json['fotos_url'] ?? json['url'] ?? '',
      legenda: json['legenda'],
    );
  }
}

class PontoReferencia {
  final String nome;
  final String distancia;

  PontoReferencia({
    required this.nome,
    required this.distancia,
  });

  factory PontoReferencia.fromJson(Map<String, dynamic> json) {
    return PontoReferencia(
      nome: json['nome'] ?? '',
      distancia: json['distancia'] ?? '',
    );
  }
}

class Transporte {
  final String nome;
  final String distancia;

  Transporte({
    required this.nome,
    required this.distancia,
  });

  factory Transporte.fromJson(Map<String, dynamic> json) {
    return Transporte(
      nome: json['nome'] ?? '',
      distancia: json['distancia'] ?? '',
    );
  }
}

class Documento {
  final int id;
  final String arquivoUrl;
  final TipoDocumento tipoDocumento;
  final String? nomeOriginal;
  final String? tipoMime;
  final int? tamanhoBytes;

  Documento({
    required this.id,
    required this.arquivoUrl,
    required this.tipoDocumento,
    this.nomeOriginal,
    this.tipoMime,
    this.tamanhoBytes,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] ?? 0,
      arquivoUrl: json['arquivo_url'] ?? '',
      tipoDocumento: TipoDocumento.fromJson(json['tipo_documento'] ?? {}),
      nomeOriginal: json['nome_original'],
      tipoMime: json['tipo_mime'],
      tamanhoBytes: json['tamanho_bytes'],
    );
  }

  String get tamanhoFormatado {
    if (tamanhoBytes == null) return '';
    if (tamanhoBytes! < 1024) return '${tamanhoBytes}B';
    if (tamanhoBytes! < 1024 * 1024) return '${(tamanhoBytes! / 1024).toStringAsFixed(1)}KB';
    return '${(tamanhoBytes! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  bool get isPdf => tipoDocumento.tipoArquivo == 'pdf' || (tipoMime?.contains('pdf') ?? false);
  bool get isImage => tipoDocumento.tipoArquivo == 'image' || (tipoMime?.startsWith('image/') ?? false);
}

class TipoDocumento {
  final int id;
  final String nome;
  final String tipoArquivo;
  final bool obrigatorio;
  final int ordem;

  TipoDocumento({
    required this.id,
    required this.nome,
    required this.tipoArquivo,
    this.obrigatorio = false,
    this.ordem = 0,
  });

  factory TipoDocumento.fromJson(Map<String, dynamic> json) {
    return TipoDocumento(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      tipoArquivo: json['tipo_arquivo'] ?? 'pdf',
      obrigatorio: json['obrigatorio'] ?? false,
      ordem: json['ordem'] ?? 0,
    );
  }
}

class VideoUnidade {
  final int id;
  final String videoUrl;
  final String categoria;
  final String? originalName;
  final String? mimeType;

  VideoUnidade({
    required this.id,
    required this.videoUrl,
    required this.categoria,
    this.originalName,
    this.mimeType,
  });

  factory VideoUnidade.fromJson(Map<String, dynamic> json) {
    return VideoUnidade(
      id: json['id'] ?? 0,
      videoUrl: json['video_url'] ?? '',
      categoria: json['categoria'] ?? 'geral',
      originalName: json['original_name'],
      mimeType: json['mime_type'],
    );
  }
}

