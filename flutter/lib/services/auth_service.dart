import '../config/api_config.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<ApiResponse<AuthResponse>> login(String email, String senha) async {
    try {
      final response = await _api.post(
        ApiConfig.login,
        data: {'email': email, 'senha': senha},
      );

      final data = response.data;
      
      if (data['success'] == true) {
        // Extract token from response
        final token = data['token'] ?? data['data']?['token'];
        final refreshToken = data['refreshToken'] ?? data['data']?['refreshToken'];
        
        if (token != null) {
          await _api.setToken(token);
        }
        if (refreshToken != null) {
          await _api.setRefreshToken(refreshToken);
        }

        return ApiResponse<AuthResponse>(
          success: true,
          data: AuthResponse.fromJson(data),
          message: data['message'],
        );
      }

      return ApiResponse<AuthResponse>(
        success: false,
        message: data['message'] ?? 'Erro ao fazer login',
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
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Erro de conexão. Tente novamente.',
      );
    }
  }

  Future<ApiResponse<User>> register({
    required String nomeCompleto,
    required String email,
    required String cpfCnpj,
    required bool isPessoaJuridica,
    required String telefone,
    required String creci,
    required String senha,
    required String confirmarSenha,
  }) async {
    try {
      final response = await _api.post(
        ApiConfig.register,
        data: {
          'nomeCompleto': nomeCompleto,
          'email': email,
          'cpfCnpj': cpfCnpj,
          'isPessoaJuridica': isPessoaJuridica,
          'telefone': telefone,
          'creci': creci,
          'senha': senha,
          'confirmarSenha': confirmarSenha,
        },
      );

      final data = response.data;

      if (data['success'] == true) {
        return ApiResponse<User>(
          success: true,
          data: User.fromJson(data['data'] ?? data['user'] ?? {}),
          message: data['message'],
        );
      }

      return ApiResponse<User>(
        success: false,
        message: data['message'] ?? 'Erro no cadastro',
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
        message: 'Erro de conexão. Tente novamente.',
      );
    }
  }

  Future<ApiResponse> forgotPassword(String email) async {
    try {
      final response = await _api.post(
        ApiConfig.forgotPassword,
        data: {'email': email},
      );

      final data = response.data;

      return ApiResponse(
        success: data['success'] ?? false,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão. Tente novamente.',
      );
    }
  }

  Future<void> logout() async {
    await _api.clearTokens();
  }

  Future<bool> isAuthenticated() async {
    return await _api.hasToken();
  }
}

