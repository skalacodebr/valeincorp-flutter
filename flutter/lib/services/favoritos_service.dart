import '../config/api_config.dart';
import '../models/favorito.dart';
import '../models/imovel.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class FavoritosService {
  final ApiService _api = ApiService();

  Future<ApiResponse<List<Imovel>>> list({
    int? page,
    int? limit,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      
      if (page != null) params['page'] = page;
      if (limit != null) params['limit'] = limit;
      if (search != null && search.isNotEmpty) params['search'] = search;

      final response = await _api.get(
        ApiConfig.favoritos,
        queryParameters: params,
      );

      final data = response.data;

      if (data['success'] == true) {
        final favoritosList = (data['data'] as List<dynamic>?)?.map((e) {
          // API pode retornar Favorito ou diretamente Imovel
          if (e['imovel'] != null) {
            return Imovel.fromJson(e['imovel']);
          }
          return Imovel.fromJson(e);
        }).toList() ?? [];

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
    } catch (e) {
      return ApiResponse<List<Imovel>>(
        success: false,
        message: 'Erro de conexão',
        data: [],
      );
    }
  }

  Future<ApiResponse> add(int imovelId) async {
    try {
      final response = await _api.post(
        ApiConfig.favoritos,
        data: {'imovelId': imovelId},
      );

      final data = response.data;

      return ApiResponse(
        success: data['success'] ?? false,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao adicionar favorito',
      );
    }
  }

  Future<ApiResponse> remove(int imovelId) async {
    try {
      final response = await _api.delete(ApiConfig.favoritoRemove(imovelId));
      final data = response.data;

      return ApiResponse(
        success: data['success'] ?? false,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao remover favorito',
      );
    }
  }

  Future<ApiResponse<bool>> check(int imovelId) async {
    try {
      final response = await _api.get(ApiConfig.favoritoCheck(imovelId));
      final data = response.data;

      if (data['success'] == true) {
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
      final response = await _api.get(ApiConfig.favoritosCount);
      final data = response.data;

      if (data['success'] == true) {
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

