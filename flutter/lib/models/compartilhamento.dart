class Compartilhamento {
  final int id;
  final int corretorId;
  final String entityType; // 'empreendimento' ou 'unidade'
  final int entityId;
  final String linkUnico;
  final String urlCompleta;
  final String? nomeCliente;
  final String? anotacao;
  final bool receberNotificacao;
  final bool mostrarEspelhoVendas;
  final bool mostrarEndereco;
  final bool compartilharDescricao;
  final int totalVisualizacoes;
  final DateTime? ultimaVisualizacaoAt;
  final bool ativo;
  final bool isExpirado;
  final DateTime? expiraEm;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CompartilhamentoEntity? entity;

  Compartilhamento({
    required this.id,
    required this.corretorId,
    required this.entityType,
    required this.entityId,
    required this.linkUnico,
    required this.urlCompleta,
    this.nomeCliente,
    this.anotacao,
    required this.receberNotificacao,
    required this.mostrarEspelhoVendas,
    required this.mostrarEndereco,
    required this.compartilharDescricao,
    required this.totalVisualizacoes,
    this.ultimaVisualizacaoAt,
    required this.ativo,
    required this.isExpirado,
    this.expiraEm,
    required this.createdAt,
    required this.updatedAt,
    this.entity,
  });

  factory Compartilhamento.fromJson(Map<String, dynamic> json) {
    return Compartilhamento(
      id: json['id'] as int,
      corretorId: json['corretor_id'] as int,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as int,
      linkUnico: json['link_unico'] as String,
      urlCompleta: json['url_completa'] as String,
      nomeCliente: json['nome_cliente'] as String?,
      anotacao: json['anotacao'] as String?,
      receberNotificacao: json['receber_notificacao'] as bool? ?? false,
      mostrarEspelhoVendas: json['mostrar_espelho_vendas'] as bool? ?? false,
      mostrarEndereco: json['mostrar_endereco'] as bool? ?? true,
      compartilharDescricao: json['compartilhar_descricao'] as bool? ?? true,
      totalVisualizacoes: json['total_visualizacoes'] as int? ?? 0,
      ultimaVisualizacaoAt: json['ultima_visualizacao_at'] != null
          ? DateTime.parse(json['ultima_visualizacao_at'] as String)
          : null,
      ativo: json['ativo'] as bool? ?? true,
      isExpirado: json['is_expirado'] as bool? ?? false,
      expiraEm: json['expira_em'] != null
          ? DateTime.parse(json['expira_em'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      entity: json['entity'] != null
          ? CompartilhamentoEntity.fromJson(json['entity'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'corretor_id': corretorId,
      'entity_type': entityType,
      'entity_id': entityId,
      'link_unico': linkUnico,
      'url_completa': urlCompleta,
      'nome_cliente': nomeCliente,
      'anotacao': anotacao,
      'receber_notificacao': receberNotificacao,
      'mostrar_espelho_vendas': mostrarEspelhoVendas,
      'mostrar_endereco': mostrarEndereco,
      'compartilhar_descricao': compartilharDescricao,
      'total_visualizacoes': totalVisualizacoes,
      'ultima_visualizacao_at': ultimaVisualizacaoAt?.toIso8601String(),
      'ativo': ativo,
      'is_expirado': isExpirado,
      'expira_em': expiraEm?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'entity': entity?.toJson(),
    };
  }

  /// Retorna o nome de exibição da entidade
  String get entityNome => entity?.nome ?? 'N/A';

  /// Retorna se é um empreendimento
  bool get isEmpreendimento => entityType == 'empreendimento';

  /// Retorna se é uma unidade
  bool get isUnidade => entityType == 'unidade';

  /// Retorna uma descrição formatada do tipo
  String get tipoFormatado => isEmpreendimento ? 'Empreendimento' : 'Unidade';
}

class CompartilhamentoEntity {
  final int id;
  final String nome;

  CompartilhamentoEntity({
    required this.id,
    required this.nome,
  });

  factory CompartilhamentoEntity.fromJson(Map<String, dynamic> json) {
    return CompartilhamentoEntity(
      id: json['id'] as int,
      nome: json['nome'] as String? ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
    };
  }
}

class CompartilhamentoEstatisticas {
  final int totalVisualizacoes;
  final int totalAcessos;
  final int acessosUnicos;
  final DateTime? ultimaVisualizacao;
  final DateTime criadoEm;
  final List<AcessoPorData> acessosPorData;

  CompartilhamentoEstatisticas({
    required this.totalVisualizacoes,
    required this.totalAcessos,
    required this.acessosUnicos,
    this.ultimaVisualizacao,
    required this.criadoEm,
    required this.acessosPorData,
  });

  factory CompartilhamentoEstatisticas.fromJson(Map<String, dynamic> json) {
    return CompartilhamentoEstatisticas(
      totalVisualizacoes: json['total_visualizacoes'] as int? ?? 0,
      totalAcessos: json['total_acessos'] as int? ?? 0,
      acessosUnicos: json['acessos_unicos'] as int? ?? 0,
      ultimaVisualizacao: json['ultima_visualizacao'] != null
          ? DateTime.parse(json['ultima_visualizacao'] as String)
          : null,
      criadoEm: DateTime.parse(json['criado_em'] as String),
      acessosPorData: (json['acessos_por_data'] as List<dynamic>?)
              ?.map((e) => AcessoPorData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AcessoPorData {
  final String data;
  final int total;

  AcessoPorData({
    required this.data,
    required this.total,
  });

  factory AcessoPorData.fromJson(Map<String, dynamic> json) {
    return AcessoPorData(
      data: json['data'] as String,
      total: json['total'] as int,
    );
  }
}

class CriarCompartilhamentoRequest {
  final String entityType;
  final int entityId;
  final String? nomeCliente;
  final String? anotacao;
  final bool receberNotificacao;
  final bool mostrarEspelhoVendas;
  final bool mostrarEndereco;
  final bool compartilharDescricao;
  final DateTime? expiraEm;

  CriarCompartilhamentoRequest({
    required this.entityType,
    required this.entityId,
    this.nomeCliente,
    this.anotacao,
    this.receberNotificacao = false,
    this.mostrarEspelhoVendas = false,
    this.mostrarEndereco = true,
    this.compartilharDescricao = true,
    this.expiraEm,
  });

  Map<String, dynamic> toJson() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      if (nomeCliente != null && nomeCliente!.isNotEmpty) 'nome_cliente': nomeCliente,
      if (anotacao != null && anotacao!.isNotEmpty) 'anotacao': anotacao,
      'receber_notificacao': receberNotificacao,
      'mostrar_espelho_vendas': mostrarEspelhoVendas,
      'mostrar_endereco': mostrarEndereco,
      'compartilhar_descricao': compartilharDescricao,
      if (expiraEm != null) 'expira_em': expiraEm!.toIso8601String(),
    };
  }
}

