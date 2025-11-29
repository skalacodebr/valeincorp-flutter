import '../config/api_config.dart';
import '../models/compartilhamento.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class CompartilhamentoService {
  final ApiService _api = ApiService();
  
  // Instância Dio para compartilhamentos
  Dio? _dioCompartilhamentos;
  
  Future<Dio> _getDio() async {
    await _api.init();
    
    // Sempre criar nova instância para garantir token atualizado
    final token = await _api.getToken();
    
    debugPrint('[CompartilhamentoService] Token atual: ${token != null ? "${token.substring(0, 10)}..." : "null"}');
    
    _dioCompartilhamentos = Dio(
      BaseOptions(
        baseUrl: ApiConfig.compartilhamentosBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
    );
    
    return _dioCompartilhamentos!;
  }
  
  Future<void> _ensureApiInitialized() async {
    await _api.init();
  }

  Future<ApiResponse<List<Compartilhamento>>> list({
    int? page,
    int? limit,
    String? entityType,
    int? entityId,
    bool? ativo,
    String? search,
    String? dataInicio,
    String? dataFim,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      
      if (page != null) params['page'] = page;
      if (limit != null) params['limit'] = limit;
      if (entityType != null) params['entity_type'] = entityType;
      if (entityId != null) params['entity_id'] = entityId;
      if (ativo != null) params['ativo'] = ativo;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (dataInicio != null) params['data_inicio'] = dataInicio;
      if (dataFim != null) params['data_fim'] = dataFim;

      final dio = await _getDio();
      
      // Usar rota de teste sem autenticação para desenvolvimento local
      final endpoint = ApiConfig.compartilhamentosTest;
      debugPrint('[CompartilhamentoService] Listando compartilhamentos de: $endpoint');
      
      final response = await dio.get(
        endpoint,
        queryParameters: params,
      );

      final data = response.data;

      if (data['success'] == true) {
        final compartilhamentosList = (data['data'] as List<dynamic>?)?.map((e) {
          return Compartilhamento.fromJson(e);
        }).toList() ?? [];

        return ApiResponse<List<Compartilhamento>>(
          success: true,
          data: compartilhamentosList,
          pagination: data['pagination'] != null 
              ? Pagination.fromJson(data['pagination']) 
              : null,
        );
      }

      return ApiResponse<List<Compartilhamento>>(
        success: false,
        message: data['message'] ?? 'Erro ao carregar compartilhamentos',
        data: [],
      );
    } catch (e) {
      return ApiResponse<List<Compartilhamento>>(
        success: false,
        message: 'Erro de conexão',
        data: [],
      );
    }
  }

  Future<ApiResponse<Compartilhamento>> criar({
    required String entityType,
    required int entityId,
    String? nomeCliente,
    String? anotacao,
    bool receberNotificacao = false,
    bool mostrarEspelhoVendas = false,
    bool mostrarEndereco = true,
    bool compartilharDescricao = true,
    String? expiraEm,
  }) async {
    try {
      // Garantir que o ApiService está inicializado
      await _ensureApiInitialized();
      
      final requestData = {
        'entity_type': entityType,
        'entity_id': entityId,
        'nome_cliente': nomeCliente,
        'anotacao': anotacao,
        'receber_notificacao': receberNotificacao,
        'mostrar_espelho_vendas': mostrarEspelhoVendas,
        'mostrar_endereco': mostrarEndereco,
        'compartilhar_descricao': compartilharDescricao,
        'expira_em': expiraEm,
      };
      
      // Usar rota de teste sem autenticação para desenvolvimento local
      final endpoint = ApiConfig.compartilhamentosTest;
      
      debugPrint('[CompartilhamentoService] Criando compartilhamento...');
      debugPrint('[CompartilhamentoService] Endpoint: $endpoint');
      debugPrint('[CompartilhamentoService] Base URL: ${ApiConfig.compartilhamentosBaseUrl}');
      debugPrint('[CompartilhamentoService] Dados: $requestData');
      
      final dio = await _getDio();
      final response = await dio.post(
        endpoint,
        data: requestData,
      );

      debugPrint('[CompartilhamentoService] Resposta recebida. Status: ${response.statusCode}');
      debugPrint('[CompartilhamentoService] Resposta data: ${response.data}');

      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        debugPrint('[CompartilhamentoService] Compartilhamento criado com sucesso!');
        return ApiResponse<Compartilhamento>(
          success: true,
          data: Compartilhamento.fromJson(data['data']),
          message: data['message'],
        );
      }

      debugPrint('[CompartilhamentoService] Resposta indicou falha. Message: ${data['message']}');
      return ApiResponse<Compartilhamento>(
        success: false,
        message: data['message'] ?? 'Erro ao criar compartilhamento',
      );
    } catch (e, stackTrace) {
      debugPrint('[CompartilhamentoService] ERRO ao criar compartilhamento: $e');
      debugPrint('[CompartilhamentoService] Tipo do erro: ${e.runtimeType}');
      debugPrint('[CompartilhamentoService] Stack trace: $stackTrace');
      
      // Se for um DioError, extrair mais informações
      if (e is DioException) {
        debugPrint('[CompartilhamentoService] DioError - Status: ${e.response?.statusCode}');
        debugPrint('[CompartilhamentoService] DioError - Message: ${e.message}');
        debugPrint('[CompartilhamentoService] DioError - Request Path: ${e.requestOptions.path}');
        debugPrint('[CompartilhamentoService] DioError - Request Base URL: ${e.requestOptions.baseUrl}');
        debugPrint('[CompartilhamentoService] DioError - Response: ${e.response?.data}');
        
        // Mensagem de erro mais específica para 404
        String errorMessage;
        if (e.response?.statusCode == 404) {
          final backendMessage = e.response?.data?['message'] ?? '';
          if (backendMessage.contains('route') || backendMessage.contains('not found')) {
            errorMessage = 'Rota não encontrada no servidor. Verifique se a API está atualizada.';
          } else {
            errorMessage = backendMessage.isNotEmpty 
                ? backendMessage 
                : 'Endpoint não encontrado (404). Verifique a configuração da API.';
          }
        } else {
          errorMessage = e.response?.data?['message'] ?? 
                        e.message ?? 
                        'Erro de conexão';
        }
        
        return ApiResponse<Compartilhamento>(
          success: false,
          message: errorMessage,
        );
      }
      
      return ApiResponse<Compartilhamento>(
        success: false,
        message: 'Erro de conexão: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Compartilhamento>> obterDetalhes(int id) async {
    try {
      final dio = await _getDio();
      final response = await dio.get(ApiConfig.compartilhamentoById(id));
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return ApiResponse<Compartilhamento>(
          success: true,
          data: Compartilhamento.fromJson(data['data']),
        );
      }

      return ApiResponse<Compartilhamento>(
        success: false,
        message: data['message'] ?? 'Erro ao carregar compartilhamento',
      );
    } catch (e) {
      return ApiResponse<Compartilhamento>(
        success: false,
        message: 'Erro de conexão',
      );
    }
  }

  Future<ApiResponse<Compartilhamento>> editar({
    required int id,
    String? nomeCliente,
    String? anotacao,
    bool? receberNotificacao,
    bool? mostrarEspelhoVendas,
    bool? mostrarEndereco,
    bool? compartilharDescricao,
    String? expiraEm,
  }) async {
    try {
      final Map<String, dynamic> dataToUpdate = {};
      
      if (nomeCliente != null) dataToUpdate['nome_cliente'] = nomeCliente;
      if (anotacao != null) dataToUpdate['anotacao'] = anotacao;
      if (receberNotificacao != null) dataToUpdate['receber_notificacao'] = receberNotificacao;
      if (mostrarEspelhoVendas != null) dataToUpdate['mostrar_espelho_vendas'] = mostrarEspelhoVendas;
      if (mostrarEndereco != null) dataToUpdate['mostrar_endereco'] = mostrarEndereco;
      if (compartilharDescricao != null) dataToUpdate['compartilhar_descricao'] = compartilharDescricao;
      if (expiraEm != null) dataToUpdate['expira_em'] = expiraEm;

      final dio = await _getDio();
      final response = await dio.put(
        ApiConfig.compartilhamentoById(id),
        data: dataToUpdate,
      );

      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return ApiResponse<Compartilhamento>(
          success: true,
          data: Compartilhamento.fromJson(data['data']),
          message: data['message'],
        );
      }

      return ApiResponse<Compartilhamento>(
        success: false,
        message: data['message'] ?? 'Erro ao editar compartilhamento',
      );
    } catch (e) {
      return ApiResponse<Compartilhamento>(
        success: false,
        message: 'Erro de conexão',
      );
    }
  }

  Future<ApiResponse> deletar(int id) async {
    try {
      final dio = await _getDio();
      final response = await dio.delete(ApiConfig.compartilhamentoById(id));
      final data = response.data;

      return ApiResponse(
        success: data['success'] ?? false,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao deletar compartilhamento',
      );
    }
  }

  Future<ApiResponse> copiarLink(String urlCompleta) async {
    try {
      await Clipboard.setData(ClipboardData(text: urlCompleta));
      return ApiResponse(
        success: true,
        message: 'Link copiado para a área de transferência',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao copiar link',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> obterEstatisticas(int id) async {
    try {
      final dio = await _getDio();
      final response = await dio.get(ApiConfig.compartilhamentoEstatisticas(id));
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: data['data'],
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: data['message'] ?? 'Erro ao carregar estatísticas',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Erro de conexão',
      );
    }
  }
}

