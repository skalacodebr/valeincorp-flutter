import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/favorito.dart';
import '../models/imovel.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class FavoritosService {
  final ApiService _api = ApiService();
  
  /// Verifica se a resposta indica sucesso (aceita bool, int e string)
  bool _isSuccess(dynamic success) {
    if (success == null) return false;
    if (success is bool) return success;
    if (success is int) return success == 1;
    if (success is String) return success == 'true' || success == '1';
    return false;
  }
  
  // Cliente Dio separado para requisições locais (quando useTestEndpoints = true)
  late final Dio _localDio;
  
  FavoritosService() {
    _localDio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.localBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }
  
  /// Retorna o cliente Dio apropriado baseado na configuração
  Future<Response> _get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    if (ApiConfig.useTestEndpoints) {
      debugPrint('[FavoritosService] Usando endpoint de teste: ${ApiConfig.localBaseUrl}$endpoint');
      return await _localDio.get(endpoint, queryParameters: queryParameters);
    }
    return await _api.get(endpoint, queryParameters: queryParameters);
  }
  
  Future<Response> _post(String endpoint, {dynamic data}) async {
    if (ApiConfig.useTestEndpoints) {
      debugPrint('[FavoritosService] POST de teste: ${ApiConfig.localBaseUrl}$endpoint');
      return await _localDio.post(endpoint, data: data);
    }
    return await _api.post(endpoint, data: data);
  }
  
  Future<Response> _delete(String endpoint) async {
    if (ApiConfig.useTestEndpoints) {
      debugPrint('[FavoritosService] DELETE de teste: ${ApiConfig.localBaseUrl}$endpoint');
      return await _localDio.delete(endpoint);
    }
    return await _api.delete(endpoint);
  }

  Future<ApiResponse<List<Imovel>>> list({
    int? page,
    int? limit,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> params = {'corretor_id': 1}; // ID fixo para testes
      
      if (page != null) params['page'] = page;
      if (limit != null) params['limit'] = limit;
      if (search != null && search.isNotEmpty) params['search'] = search;

      debugPrint('[FavoritosService] Listando favoritos de: ${ApiConfig.favoritos}');

      final response = await _get(
        ApiConfig.favoritos,
        queryParameters: params,
      );

      final data = response.data;
      debugPrint('[FavoritosService] Resposta: ${data['success']}');

      if (_isSuccess(data['success'])) {
        final favoritosList = (data['data'] as List<dynamic>?)?.map((e) {
          // API pode retornar Favorito ou diretamente Imovel
          if (e['imovel'] != null) {
            return Imovel.fromJson(e['imovel']);
          }
          return Imovel.fromJson(e);
        }).toList() ?? [];

        debugPrint('[FavoritosService] Carregados ${favoritosList.length} favoritos');

        return ApiResponse<List<Imovel>>(
          success: true,
          data: favoritosList,
          pagination: data['pagination'] != null 
              ? Pagination.fromJson(data['pagination']) 
              : null,
        );
      }

      return ApiResponse<List<Imovel>>(
        success: false,
        message: data['message'] ?? 'Erro ao carregar favoritos',
        data: [],
      );
    } on DioException catch (e) {
      debugPrint('[FavoritosService] DioException: ${e.type} - ${e.message}');
      debugPrint('[FavoritosService] Status: ${e.response?.statusCode}');
      debugPrint('[FavoritosService] Data: ${e.response?.data}');
      
      String message = 'Erro de conexão';
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout) {
        message = 'Servidor indisponível. Verifique sua conexão.';
      } else if (e.response?.statusCode == 401) {
        message = 'Sessão expirada. Faça login novamente.';
      } else if (e.response?.statusCode == 403) {
        message = 'Acesso negado';
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        message = e.response?.data['message'];
      }
      
      return ApiResponse<List<Imovel>>(
        success: false,
        message: message,
        data: [],
      );
    } catch (e) {
      debugPrint('[FavoritosService] Erro: $e');
      return ApiResponse<List<Imovel>>(
        success: false,
        message: 'Erro de conexão',
        data: [],
      );
    }
  }

  Future<ApiResponse> add(int imovelId) async {
    try {
      debugPrint('[FavoritosService] Adicionando favorito $imovelId');
      
      final response = await _post(
        ApiConfig.favoritos,
        data: {'imovelId': imovelId, 'corretor_id': 1},
      );

      final data = response.data;
      debugPrint('[FavoritosService] Resposta add: ${data['success']} - ${data['message']}');

      return ApiResponse(
        success: _isSuccess(data['success']),
        message: data['message'],
      );
    } on DioException catch (e) {
      debugPrint('[FavoritosService] DioException ao adicionar: ${e.type}');
      debugPrint('[FavoritosService] Status: ${e.response?.statusCode}');
      debugPrint('[FavoritosService] Data: ${e.response?.data}');
      
      String message = 'Erro ao adicionar favorito';
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout) {
        message = 'Servidor indisponível. Verifique sua conexão.';
      } else if (e.response?.statusCode == 401) {
        message = 'Sessão expirada. Faça login novamente.';
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        message = e.response?.data['message'];
      }
      
      return ApiResponse(
        success: false,
        message: message,
      );
    } catch (e) {
      debugPrint('[FavoritosService] Erro ao adicionar: $e');
      return ApiResponse(
        success: false,
        message: 'Erro ao adicionar favorito',
      );
    }
  }

  Future<ApiResponse> remove(int imovelId) async {
    try {
      debugPrint('[FavoritosService] Removendo favorito $imovelId');
      
      final response = await _delete('${ApiConfig.favoritoRemove(imovelId)}?corretor_id=1');
      final data = response.data;

      debugPrint('[FavoritosService] Resposta remove: ${data['success']}');

      return ApiResponse(
        success: _isSuccess(data['success']),
        message: data['message'],
      );
    } on DioException catch (e) {
      debugPrint('[FavoritosService] DioException ao remover: ${e.type}');
      
      String message = 'Erro ao remover favorito';
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout) {
        message = 'Servidor indisponível';
      } else if (e.response?.statusCode == 401) {
        message = 'Sessão expirada. Faça login novamente.';
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        message = e.response?.data['message'];
      }
      
      return ApiResponse(
        success: false,
        message: message,
      );
    } catch (e) {
      debugPrint('[FavoritosService] Erro ao remover: $e');
      return ApiResponse(
        success: false,
        message: 'Erro ao remover favorito',
      );
    }
  }

  Future<ApiResponse<bool>> check(int imovelId) async {
    try {
      final response = await _get(
        ApiConfig.favoritoCheck(imovelId),
        queryParameters: {'corretor_id': 1},
      );
      final data = response.data;

      if (_isSuccess(data['success'])) {
        return ApiResponse<bool>(
          success: true,
          data: data['isFavorito'] ?? data['data']?['isFavorito'] ?? false,
        );
      }

      return ApiResponse<bool>(
        success: false,
        data: false,
        message: data['message'],
      );
    } on DioException catch (e) {
      String message = 'Erro de conexão';
      if (e.response?.statusCode == 401) {
        message = 'Sessão expirada';
      }
      return ApiResponse<bool>(
        success: false,
        data: false,
        message: message,
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        data: false,
        message: 'Erro de conexão',
      );
    }
  }

  Future<ApiResponse<int>> count() async {
    try {
      final response = await _get(
        ApiConfig.favoritosCount,
        queryParameters: {'corretor_id': 1},
      );
      final data = response.data;

      if (_isSuccess(data['success'])) {
        return ApiResponse<int>(
          success: true,
          data: data['totalFavoritos'] ?? data['data']?['totalFavoritos'] ?? 0,
        );
      }

      return ApiResponse<int>(
        success: false,
        data: 0,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<int>(
        success: false,
        data: 0,
        message: 'Erro de conexão',
      );
    }
  }
}

