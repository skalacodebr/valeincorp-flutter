import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/imovel.dart';
import '../models/imovel_detalhes.dart';
import '../models/unidade.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class ImoveisService {
  final ApiService _api = ApiService();

  Future<ApiResponse<List<Imovel>>> list({
    int? page,
    int? limit,
    String? cidade,
    String? search,
    double? valorMin,
    double? valorMax,
    int? dormitorios,
    int? banheiros,
    int? suites,
    int? suitesMaster,
    int? vagas,
    double? areaMin,
    double? areaMax,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      
      if (page != null) params['page'] = page;
      if (limit != null) params['limit'] = limit;
      if (cidade != null && cidade.isNotEmpty) params['cidade'] = cidade;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (valorMin != null) params['valorMin'] = valorMin;
      if (valorMax != null) params['valorMax'] = valorMax;
      if (dormitorios != null && dormitorios > 0) params['dormitorios'] = dormitorios;
      if (banheiros != null && banheiros > 0) params['banheiros'] = banheiros;
      if (suites != null && suites > 0) params['suites'] = suites;
      if (suitesMaster != null && suitesMaster > 0) params['suitesMaster'] = suitesMaster;
      if (vagas != null && vagas > 0) params['vagas'] = vagas;
      if (areaMin != null) params['areaMin'] = areaMin;
      if (areaMax != null) params['areaMax'] = areaMax;
      if (status != null && status.isNotEmpty) params['status'] = status;

      debugPrint('[ImoveisService] Chamando API: ${ApiConfig.baseUrl}${ApiConfig.imoveis}');
      debugPrint('[ImoveisService] Params: $params');
      
      final response = await _api.get(
        ApiConfig.imoveis,
        queryParameters: params,
      );

      final data = response.data;
      debugPrint('[ImoveisService] Response status: ${response.statusCode}');
      debugPrint('[ImoveisService] Response data success: ${data['success']}');
      debugPrint('[ImoveisService] Response data length: ${(data['data'] as List?)?.length ?? 0}');

      if (data['success'] == true) {
        final imoveisList = (data['data'] as List<dynamic>?)
            ?.map((e) => Imovel.fromJson(e))
            .toList() ?? [];

        return ApiResponse<List<Imovel>>(
          success: true,
          data: imoveisList,
          pagination: data['pagination'] != null 
              ? Pagination.fromJson(data['pagination']) 
              : null,
        );
      }

      return ApiResponse<List<Imovel>>(
        success: false,
        message: data['message'] ?? 'Erro ao carregar imóveis',
        data: [],
      );
    } catch (e, stackTrace) {
      debugPrint('[ImoveisService] ERRO: $e');
      debugPrint('[ImoveisService] Stack: $stackTrace');
      return ApiResponse<List<Imovel>>(
        success: false,
        message: 'Erro de conexão: $e',
        data: [],
      );
    }
  }

  Future<ApiResponse<ImovelDetalhes>> getById(int id) async {
    try {
      final response = await _api.get(ApiConfig.imovelById(id));
      final data = response.data;

      if (data['success'] == true) {
        return ApiResponse<ImovelDetalhes>(
          success: true,
          data: ImovelDetalhes.fromJson(data['data'] ?? {}),
        );
      }

      return ApiResponse<ImovelDetalhes>(
        success: false,
        message: data['message'] ?? 'Imóvel não encontrado',
      );
    } catch (e) {
      return ApiResponse<ImovelDetalhes>(
        success: false,
        message: 'Erro de conexão',
      );
    }
  }

  Future<ApiResponse<List<String>>> getCidades() async {
    try {
      final response = await _api.get(ApiConfig.cidades);
      final data = response.data;

      if (data['success'] == true) {
        final cidadesList = (data['data'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [];

        return ApiResponse<List<String>>(
          success: true,
          data: cidadesList,
        );
      }

      return ApiResponse<List<String>>(
        success: false,
        message: data['message'] ?? 'Erro ao carregar cidades',
        data: [],
      );
    } catch (e) {
      return ApiResponse<List<String>>(
        success: false,
        message: 'Erro de conexão',
        data: [],
      );
    }
  }

  Future<ApiResponse<List<Imovel>>> buscar({
    List<String>? localizacao,
    double? valorDe,
    double? valorAte,
    double? metragemDe,
    double? metragemAte,
    int? dormitorios,
    int? banheiros,
    int? suites,
    int? suitesMaster,
    int? vagasGaragem,
    List<String>? status,
    int? page,
    int? limit,
  }) async {
    try {
      final Map<String, dynamic> filtros = {};
      
      if (localizacao != null && localizacao.isNotEmpty) {
        filtros['localizacao'] = localizacao;
      }
      if (valorDe != null) filtros['valorDe'] = valorDe;
      if (valorAte != null) filtros['valorAte'] = valorAte;
      if (metragemDe != null) filtros['metragemDe'] = metragemDe;
      if (metragemAte != null) filtros['metragemAte'] = metragemAte;
      if (dormitorios != null && dormitorios > 0) filtros['dormitorios'] = dormitorios;
      if (banheiros != null && banheiros > 0) filtros['banheiros'] = banheiros;
      if (suites != null && suites > 0) filtros['suites'] = suites;
      if (suitesMaster != null && suitesMaster > 0) filtros['suitesMaster'] = suitesMaster;
      if (vagasGaragem != null && vagasGaragem > 0) filtros['vagasGaragem'] = vagasGaragem;
      if (status != null && status.isNotEmpty) filtros['status'] = status;
      if (page != null) filtros['page'] = page;
      if (limit != null) filtros['limit'] = limit;

      final response = await _api.post(
        ApiConfig.buscar,
        data: filtros,
      );

      final data = response.data;

      if (data['success'] == true) {
        final imoveisList = (data['data'] as List<dynamic>?)
            ?.map((e) => Imovel.fromJson(e))
            .toList() ?? [];

        return ApiResponse<List<Imovel>>(
          success: true,
          data: imoveisList,
          pagination: data['pagination'] != null 
              ? Pagination.fromJson(data['pagination']) 
              : null,
        );
      }

      return ApiResponse<List<Imovel>>(
        success: false,
        message: data['message'] ?? 'Erro na busca',
        data: [],
      );
    } catch (e) {
      return ApiResponse<List<Imovel>>(
        success: false,
        message: 'Erro de conexão',
        data: [],
      );
    }
  }

  Future<ApiResponse<Unidade>> getUnidadeById(int id) async {
    try {
      final response = await _api.get(ApiConfig.unidadeById(id));
      final data = response.data;

      if (data['success'] == true) {
        return ApiResponse<Unidade>(
          success: true,
          data: Unidade.fromJson(data['data'] ?? {}),
        );
      }

      return ApiResponse<Unidade>(
        success: false,
        message: data['message'] ?? 'Unidade não encontrada',
      );
    } catch (e) {
      return ApiResponse<Unidade>(
        success: false,
        message: 'Erro de conexão',
      );
    }
  }

  /// Carrega detalhes adicionais do empreendimento
  Future<ApiResponse<Map<String, dynamic>>> getEmpreendimentoDetalhes(int id) async {
    try {
      final response = await _api.get(ApiConfig.empreendimentoById(id));
      final data = response.data;

      if (data != null) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: data is Map<String, dynamic> ? data : {},
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Empreendimento não encontrado',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Erro de conexão',
      );
    }
  }

  /// Carrega torres do empreendimento
  Future<ApiResponse<List<dynamic>>> getTorres(int empreendimentoId) async {
    try {
      final response = await _api.get(ApiConfig.empreendimentoTorres(empreendimentoId));
      final data = response.data;

      if (data != null && data['torres'] != null) {
        return ApiResponse<List<dynamic>>(
          success: true,
          data: data['torres'] as List<dynamic>,
        );
      }

      return ApiResponse<List<dynamic>>(
        success: false,
        message: 'Torres não encontradas',
        data: [],
      );
    } catch (e) {
      return ApiResponse<List<dynamic>>(
        success: false,
        message: 'Erro de conexão',
        data: [],
      );
    }
  }

  /// Carrega unidades de uma torre
  Future<ApiResponse<List<dynamic>>> getUnidadesPorTorre(int torreId) async {
    try {
      final response = await _api.get(ApiConfig.torreUnidades(torreId));
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return ApiResponse<List<dynamic>>(
          success: true,
          data: data['data'] as List<dynamic>,
        );
      }

      return ApiResponse<List<dynamic>>(
        success: false,
        message: data['message'] ?? 'Unidades não encontradas',
        data: [],
      );
    } catch (e) {
      return ApiResponse<List<dynamic>>(
        success: false,
        message: 'Erro de conexão',
        data: [],
      );
    }
  }
}

