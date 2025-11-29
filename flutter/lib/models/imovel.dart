class Imovel {
  final int id;
  final String codigo;
  final String nome;
  final String? imagem;
  final String localizacao;
  final String? dataEntrega;
  final String corretor;
  final String cidade;
  final String status;
  final double preco;
  final String? precoFormatado;
  final int dormitorios;
  final int banheiros;
  final int suites;
  final int? suitesMaster;
  final int vagas;
  final double area;
  final double? areaComum;
  final double? areaTotal;
  final int? unidadesDisponiveis;
  final int? totalUnidades;
  final int? unidadesVendidas;
  final double? percentualVendido;
  final String? statusVenda;
  final double? valorM2;
  final Coordenadas? coordenadas;
  final Endereco? endereco;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Imovel({
    required this.id,
    required this.codigo,
    required this.nome,
    this.imagem,
    required this.localizacao,
    this.dataEntrega,
    required this.corretor,
    required this.cidade,
    required this.status,
    required this.preco,
    this.precoFormatado,
    this.dormitorios = 0,
    this.banheiros = 0,
    this.suites = 0,
    this.suitesMaster,
    this.vagas = 0,
    this.area = 0,
    this.areaComum,
    this.areaTotal,
    this.unidadesDisponiveis,
    this.totalUnidades,
    this.unidadesVendidas,
    this.percentualVendido,
    this.statusVenda,
    this.valorM2,
    this.coordenadas,
    this.endereco,
    this.createdAt,
    this.updatedAt,
  });

  factory Imovel.fromJson(Map<String, dynamic> json) {
    return Imovel(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nome': nome,
      'imagem': imagem,
      'localizacao': localizacao,
      'dataEntrega': dataEntrega,
      'corretor': corretor,
      'cidade': cidade,
      'status': status,
      'preco': preco,
      'precoFormatado': precoFormatado,
      'dormitorios': dormitorios,
      'banheiros': banheiros,
      'suites': suites,
      'suitesMaster': suitesMaster,
      'vagas': vagas,
      'area': area,
      'areaComum': areaComum,
      'areaTotal': areaTotal,
      'unidadesDisponiveis': unidadesDisponiveis,
      'totalUnidades': totalUnidades,
      'unidadesVendidas': unidadesVendidas,
      'percentualVendido': percentualVendido,
      'statusVenda': statusVenda,
      'valorM2': valorM2,
      'coordenadas': coordenadas?.toJson(),
      'endereco': endereco?.toJson(),
    };
  }

  String calcularStatusVendas() {
    if (percentualVendido != null) {
      return '${percentualVendido!.toStringAsFixed(0)}% vendido';
    }
    if (unidadesVendidas != null && totalUnidades != null && totalUnidades! > 0) {
      final percentual = (unidadesVendidas! / totalUnidades!) * 100;
      return '${percentual.toStringAsFixed(0)}% vendido';
    }
    return statusVenda ?? status;
  }
}

class Coordenadas {
  final double latitude;
  final double longitude;

  Coordenadas({
    required this.latitude,
    required this.longitude,
  });

  factory Coordenadas.fromJson(Map<String, dynamic> json) {
    return Coordenadas(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Endereco {
  final String logradouro;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
  final String? complemento;

  Endereco({
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
    this.complemento,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      logradouro: json['logradouro'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      estado: json['estado'] ?? '',
      cep: json['cep'] ?? '',
      complemento: json['complemento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logradouro': logradouro,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'complemento': complemento,
    };
  }

  String get enderecoCompleto {
    final partes = <String>[];
    if (logradouro.isNotEmpty) partes.add(logradouro);
    if (bairro.isNotEmpty) partes.add(bairro);
    if (cidade.isNotEmpty) partes.add(cidade);
    if (estado.isNotEmpty) partes.add(estado);
    if (cep.isNotEmpty) partes.add(cep);
    return partes.join(', ');
  }
}

