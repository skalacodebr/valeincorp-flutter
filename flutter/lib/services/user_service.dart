import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await _api.get(ApiConfig.userProfile);
      final data = response.data;

      if (data['success'] == true) {
        // API returns data in 'user' instead of 'data'
        final userData = data['user'] ?? data['data'];
        return ApiResponse<User>(
          success: true,
          data: User.fromJson(userData ?? {}),
        );
      }

      return ApiResponse<User>(
        success: false,
        message: data['message'] ?? 'Erro ao carregar perfil',
      );
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Erro de conexão',
      );
    }
  }

  Future<ApiResponse<User>> updateProfile({
    String? nome,
    String? email,
    String? telefone,
    String? cpf,
    String? creci,
    String? senhaAtual,
    String? novaSenha,
  }) async {
    try {
      final Map<String, dynamic> profileData = {};
      
      if (nome != null) profileData['nome'] = nome;
      if (email != null) profileData['email'] = email;
      if (telefone != null) profileData['telefone'] = telefone;
      if (cpf != null) profileData['cpf'] = cpf;
      if (creci != null) profileData['creci'] = creci;
      if (senhaAtual != null) profileData['senhaAtual'] = senhaAtual;
      if (novaSenha != null) profileData['novaSenha'] = novaSenha;

      final response = await _api.put(
        ApiConfig.userProfile,
        data: profileData,
      );

      final data = response.data;

      if (data['success'] == true) {
        final userData = data['user'] ?? data['data'];
        return ApiResponse<User>(
          success: true,
          data: User.fromJson(userData ?? {}),
          message: data['message'],
        );
      }

      return ApiResponse<User>(
        success: false,
        message: data['message'] ?? 'Erro ao atualizar perfil',
        errors: data['errors'] != null
            ? Map<String, List<String>>.from(
                (data['errors'] as Map).map(
                  (key, value) => MapEntry(
                    key.toString(),
                    (value as List).map((e) => e.toString()).toList(),
                  ),
                ),
              )
            : null,
      );
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Erro de conexão',
      );
    }
  }

  Future<ApiResponse<User>> uploadAvatar(File file) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _api.dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.uploadAvatar}',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final data = response.data;

      if (data['success'] == true) {
        final userData = data['user'] ?? data['data'];
        return ApiResponse<User>(
          success: true,
          data: userData != null ? User.fromJson(userData) : null,
          message: data['message'],
        );
      }

      return ApiResponse<User>(
        success: false,
        message: data['message'] ?? 'Erro ao fazer upload',
      );
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Erro ao fazer upload',
      );
    }
  }

  Future<ApiResponse> changePassword({
    required String senhaAtual,
    required String novaSenha,
    required String confirmarSenha,
  }) async {
    try {
      final response = await _api.put(
        ApiConfig.userProfile,
        data: {
          'senhaAtual': senhaAtual,
          'novaSenha': novaSenha,
          'confirmarSenha': confirmarSenha,
        },
      );

      final data = response.data;

      return ApiResponse(
        success: data['success'] ?? false,
        message: data['message'],
        errors: data['errors'] != null
            ? Map<String, List<String>>.from(
                (data['errors'] as Map).map(
                  (key, value) => MapEntry(
                    key.toString(),
                    (value as List).map((e) => e.toString()).toList(),
                  ),
                ),
              )
            : null,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao alterar senha',
      );
    }
  }
}

