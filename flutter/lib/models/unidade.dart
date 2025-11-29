class Unidade {
  final int id;
  final int numero;
  final int andar;
  final String area;
  final String areaFormatada;
  final String? areaComumTotal;
  final int quartos;
  final int suites;
  final int banheiros;
  final String valor;
  final String valorFormatado;
  final double valorM2;
  final String valorM2Formatado;
  final String status;
  final String statusLabel;
  final int statusId;
  final String? observacao;
  final String? posicao;
  final bool vistaEspecial;
  final bool solManha;
  final bool solTarde;
  final List<FotoUnidade> fotos;
  final List<String> videos;
  final List<VagaGaragem> vagasGaragem;
  final List<MedidaUnidade> medidas;
  final String? planta;
  final Torre torre;
  final Empreendimento empreendimento;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Unidade({
    required this.id,
    required this.numero,
    required this.andar,
    required this.area,
    required this.areaFormatada,
    this.areaComumTotal,
    required this.quartos,
    required this.suites,
    required this.banheiros,
    required this.valor,
    required this.valorFormatado,
    required this.valorM2,
    required this.valorM2Formatado,
    required this.status,
    required this.statusLabel,
    required this.statusId,
    this.observacao,
    this.posicao,
    this.vistaEspecial = false,
    this.solManha = false,
    this.solTarde = false,
    this.fotos = const [],
    this.videos = const [],
    this.vagasGaragem = const [],
    this.medidas = const [],
    this.planta,
    required this.torre,
    required this.empreendimento,
    this.createdAt,
    this.updatedAt,
  });

  factory Unidade.fromJson(Map<String, dynamic> json) {
    return Unidade(
      id: json['id'] ?? 0,
      numero: json['numero'] ?? 0,
      andar: json['andar'] ?? 0,
      area: json['area']?.toString() ?? '0',
      areaFormatada: json['areaFormatada'] ?? '${json['area'] ?? 0} m²',
      areaComumTotal: json['areaComumTotal'],
      quartos: json['quartos'] ?? 0,
      suites: json['suites'] ?? 0,
      banheiros: json['banheiros'] ?? 0,
      valor: json['valor']?.toString() ?? '0',
      valorFormatado: json['valorFormatado'] ?? 'R\$ 0,00',
      valorM2: (json['valorM2'] ?? 0).toDouble(),
      valorM2Formatado: json['valorM2Formatado'] ?? 'R\$ 0,00/m²',
      status: json['status'] ?? 'disponivel',
      statusLabel: json['statusLabel'] ?? 'Disponível',
      statusId: json['statusId'] ?? json['status_id'] ?? 0,
      observacao: json['observacao'],
      posicao: json['posicao'],
      vistaEspecial: json['vistaEspecial'] ?? json['vista_especial'] ?? false,
      solManha: json['solManha'] ?? json['sol_manha'] ?? false,
      solTarde: json['solTarde'] ?? json['sol_tarde'] ?? false,
      fotos: (json['fotos'] as List<dynamic>?)
          ?.map((e) => FotoUnidade.fromJson(e))
          .toList() ?? [],
      videos: (json['videos'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      vagasGaragem: (json['vagasGaragem'] as List<dynamic>?)
          ?.map((e) => VagaGaragem.fromJson(e))
          .toList() ?? [],
      medidas: (json['medidas'] as List<dynamic>?)
          ?.map((e) => MedidaUnidade.fromJson(e))
          .toList() ?? [],
      planta: json['planta'],
      torre: Torre.fromJson(json['torre'] ?? {}),
      empreendimento: Empreendimento.fromJson(json['empreendimento'] ?? {}),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'andar': andar,
      'area': area,
      'areaFormatada': areaFormatada,
      'quartos': quartos,
      'suites': suites,
      'banheiros': banheiros,
      'valor': valor,
      'valorFormatado': valorFormatado,
      'valorM2': valorM2,
      'status': status,
      'statusLabel': statusLabel,
      'posicao': posicao,
      'vagasGaragem': vagasGaragem.length,
    };
  }
}

class FotoUnidade {
  final int? id;
  final String fotosUrl;
  final String? legenda;

  FotoUnidade({
    this.id,
    required this.fotosUrl,
    this.legenda,
  });

  factory FotoUnidade.fromJson(dynamic json) {
    if (json is String) {
      return FotoUnidade(fotosUrl: json);
    }
    if (json is Map<String, dynamic>) {
      return FotoUnidade(
        id: json['id'],
        fotosUrl: json['fotos_url'] ?? json['url'] ?? json['imagem'] ?? '',
        legenda: json['legenda'],
      );
    }
    return FotoUnidade(fotosUrl: json.toString());
  }
}

class VagaGaragem {
  final int id;
  final String numero;
  final String? tipo;
  final bool cobertura;
  final String area;
  final String pavimento;
  final String status;
  final String? observacoes;

  VagaGaragem({
    required this.id,
    required this.numero,
    this.tipo,
    this.cobertura = false,
    required this.area,
    required this.pavimento,
    required this.status,
    this.observacoes,
  });

  factory VagaGaragem.fromJson(Map<String, dynamic> json) {
    return VagaGaragem(
      id: json['id'] ?? 0,
      numero: json['numero']?.toString() ?? '',
      tipo: json['tipo'],
      cobertura: json['cobertura'] == true || json['cobertura'] == 'sim' || json['cobertura'] == '1',
      area: json['area']?.toString() ?? '0',
      pavimento: json['pavimento'] ?? '',
      status: json['status'] ?? 'disponível',
      observacoes: json['observacoes'],
    );
  }
}

class MedidaUnidade {
  final int tipoMedidaId;
  final String tipoNome;
  final String tipoUnidade;
  final double valor;

  MedidaUnidade({
    required this.tipoMedidaId,
    required this.tipoNome,
    required this.tipoUnidade,
    required this.valor,
  });

  factory MedidaUnidade.fromJson(Map<String, dynamic> json) {
    return MedidaUnidade(
      tipoMedidaId: json['tipo_medida_id'] ?? 0,
      tipoNome: json['tipo_nome'] ?? '',
      tipoUnidade: json['tipo_unidade'] ?? 'm²',
      valor: (json['valor'] ?? 0).toDouble(),
    );
  }
}

class Torre {
  final int id;
  final String nome;
  final int numeroAndares;
  final int unidadesPorAndar;

  Torre({
    required this.id,
    required this.nome,
    required this.numeroAndares,
    required this.unidadesPorAndar,
  });

  factory Torre.fromJson(Map<String, dynamic> json) {
    return Torre(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      numeroAndares: json['numeroAndares'] ?? json['numero_andares'] ?? 0,
      unidadesPorAndar: json['unidadesPorAndar'] ?? json['unidades_por_andar'] ?? 0,
    );
  }
}

class Empreendimento {
  final int id;
  final String nome;
  final String? tamanhoTotalComumMetrosQuadrados;
  final String? areaTotal;
  final String? descricao;
  final EnderecoEmpreendimento? endereco;

  Empreendimento({
    required this.id,
    required this.nome,
    this.tamanhoTotalComumMetrosQuadrados,
    this.areaTotal,
    this.descricao,
    this.endereco,
  });

  factory Empreendimento.fromJson(Map<String, dynamic> json) {
    return Empreendimento(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      tamanhoTotalComumMetrosQuadrados: json['tamanhoTotalComumMetrosQuadrados'],
      areaTotal: json['area_total'],
      descricao: json['descricao'],
      endereco: json['endereco'] != null 
          ? EnderecoEmpreendimento.fromJson(json['endereco']) 
          : null,
    );
  }
}

class EnderecoEmpreendimento {
  final String logradouro;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;

  EnderecoEmpreendimento({
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
  });

  factory EnderecoEmpreendimento.fromJson(Map<String, dynamic> json) {
    return EnderecoEmpreendimento(
      logradouro: json['logradouro'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      estado: json['estado'] ?? '',
      cep: json['cep'] ?? '',
    );
  }
}

