import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/compartilhamento.dart';
import 'api_service.dart';

class CompartilhamentoService {
  final ApiService _apiService = ApiService();

  /// Lista todos os compartilhamentos do corretor autenticado
  Future<ApiResponse<List<Compartilhamento>>> listar({
    int page = 1,
    int limit = 20,
    String? entityType,
    int? entityId,
    bool? ativo,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (entityType != null) queryParams['entity_type'] = entityType;
      if (entityId != null) queryParams['entity_id'] = entityId;
      if (ativo != null) queryParams['ativo'] = ativo.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiService.get(
        ApiConfig.compartilhamentos,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['data'] ?? [];
        final compartilhamentos = items
            .map((json) => Compartilhamento.fromJson(json as Map<String, dynamic>))
            .toList();

        return ApiResponse(
          success: true,
          data: compartilhamentos,
          message: 'Compartilhamentos carregados com sucesso',
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Erro ao carregar compartilhamentos',
      );
    } catch (e) {
      debugPrint('[CompartilhamentoService] Erro ao listar: $e');
      
      // Tratamento específico para erros comuns
      final errorMessage = e.toString();
      if (errorMessage.contains('404')) {
        return ApiResponse(
          success: true,
          data: <Compartilhamento>[], // Retorna lista vazia enquanto API não está disponível
          message: 'Funcionalidade em breve disponível',
        );
      } else if (errorMessage.contains('401')) {
        return ApiResponse(
          success: false,
          message: 'Faça login para ver seus compartilhamentos',
        );
      }
      
      return ApiResponse(
        success: false,
        message: 'Erro ao carregar compartilhamentos',
      );
    }
  }

  /// Cria um novo compartilhamento
  Future<ApiResponse<Compartilhamento>> criar(CriarCompartilhamentoRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConfig.compartilhamentos,
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        final compartilhamento = Compartilhamento.fromJson(data['data'] as Map<String, dynamic>);

        return ApiResponse(
          success: true,
          data: compartilhamento,
          message: 'Compartilhamento criado com sucesso',
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Erro ao criar compartilhamento',
      );
    } catch (e) {
      debugPrint('[CompartilhamentoService] Erro ao criar: $e');
      
      final errorMessage = e.toString();
      if (errorMessage.contains('404')) {
        return ApiResponse(
          success: false,
          message: 'Funcionalidade de compartilhamento em breve disponível. Use o compartilhamento direto por enquanto.',
        );
      } else if (errorMessage.contains('401')) {
        return ApiResponse(
          success: false,
          message: 'Faça login para compartilhar',
        );
      }
      
      return ApiResponse(
        success: false,
        message: 'Erro ao criar compartilhamento',
      );
    }
  }

  /// Obtém detalhes de um compartilhamento
  Future<ApiResponse<Compartilhamento>> obter(int id) async {
    try {
      final response = await _apiService.get(ApiConfig.compartilhamentoById(id));

      if (response.statusCode == 200) {
        final data = response.data;
        final compartilhamento = Compartilhamento.fromJson(data['data'] as Map<String, dynamic>);

        return ApiResponse(
          success: true,
          data: compartilhamento,
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Erro ao obter compartilhamento',
      );
    } catch (e) {
      debugPrint('[CompartilhamentoService] Erro ao obter: $e');
      return ApiResponse(
        success: false,
        message: 'Erro ao obter compartilhamento: $e',
      );
    }
  }

  /// Atualiza um compartilhamento existente
  Future<ApiResponse<Compartilhamento>> atualizar(
    int id, {
    String? nomeCliente,
    String? anotacao,
    bool? receberNotificacao,
    bool? mostrarEspelhoVendas,
    bool? mostrarEndereco,
    bool? compartilharDescricao,
    DateTime? expiraEm,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nomeCliente != null) data['nome_cliente'] = nomeCliente;
      if (anotacao != null) data['anotacao'] = anotacao;
      if (receberNotificacao != null) data['receber_notificacao'] = receberNotificacao;
      if (mostrarEspelhoVendas != null) data['mostrar_espelho_vendas'] = mostrarEspelhoVendas;
      if (mostrarEndereco != null) data['mostrar_endereco'] = mostrarEndereco;
      if (compartilharDescricao != null) data['compartilhar_descricao'] = compartilharDescricao;
      if (expiraEm != null) data['expira_em'] = expiraEm.toIso8601String();

      final response = await _apiService.put(
        ApiConfig.compartilhamentoById(id),
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final compartilhamento = Compartilhamento.fromJson(responseData['data'] as Map<String, dynamic>);

        return ApiResponse(
          success: true,
          data: compartilhamento,
          message: 'Compartilhamento atualizado com sucesso',
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Erro ao atualizar compartilhamento',
      );
    } catch (e) {
      debugPrint('[CompartilhamentoService] Erro ao atualizar: $e');
      return ApiResponse(
        success: false,
        message: 'Erro ao atualizar compartilhamento: $e',
      );
    }
  }

  /// Desativa um compartilhamento
  Future<ApiResponse<void>> desativar(int id) async {
    try {
      final response = await _apiService.delete(ApiConfig.compartilhamentoById(id));

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Compartilhamento desativado com sucesso',
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Erro ao desativar compartilhamento',
      );
    } catch (e) {
      debugPrint('[CompartilhamentoService] Erro ao desativar: $e');
      return ApiResponse(
        success: false,
        message: 'Erro ao desativar compartilhamento: $e',
      );
    }
  }

  /// Obtém estatísticas de um compartilhamento
  Future<ApiResponse<CompartilhamentoEstatisticas>> obterEstatisticas(int id) async {
    try {
      final response = await _apiService.get(ApiConfig.compartilhamentoEstatisticas(id));

      if (response.statusCode == 200) {
        final data = response.data;
        final estatisticas = CompartilhamentoEstatisticas.fromJson(data['data'] as Map<String, dynamic>);

        return ApiResponse(
          success: true,
          data: estatisticas,
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Erro ao obter estatísticas',
      );
    } catch (e) {
      debugPrint('[CompartilhamentoService] Erro ao obter estatísticas: $e');
      return ApiResponse(
        success: false,
        message: 'Erro ao obter estatísticas: $e',
      );
    }
  }
}

