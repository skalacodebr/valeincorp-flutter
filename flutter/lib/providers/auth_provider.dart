import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    await _apiService.init();
    _isAuthenticated = await _authService.isAuthenticated();
    notifyListeners();
  }

  Future<bool> checkAuth() async {
    _isAuthenticated = await _authService.isAuthenticated();
    notifyListeners();
    return _isAuthenticated;
  }

  Future<bool> login(String email, String senha) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, senha);

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _isAuthenticated = true;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? response.firstError;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao fazer login. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login de teste para desenvolvimento
  /// Credenciais: teste@valeincorp.com / teste123
  Future<bool> loginAsTestUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simula um pequeno delay como se fosse uma requisição real
    await Future.delayed(const Duration(milliseconds: 800));

    // Cria um usuário de teste
    _user = User(
      id: 999,
      nome: 'Usuário de Teste',
      email: 'teste@valeincorp.com',
      creci: '12345-F',
      telefone: '(11) 99999-9999',
      cpfCnpj: '123.456.789-00',
      isPessoaJuridica: false,
      fotoUsuario: null,
      documento: null,
      createdAt: DateTime.now(),
    );
    
    _isAuthenticated = true;
    _error = null;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<Map<String, dynamic>> register({
    required String nomeCompleto,
    required String email,
    required String cpfCnpj,
    required bool isPessoaJuridica,
    required String telefone,
    required String creci,
    required String senha,
    required String confirmarSenha,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        nomeCompleto: nomeCompleto,
        email: email,
        cpfCnpj: cpfCnpj,
        isPessoaJuridica: isPessoaJuridica,
        telefone: telefone,
        creci: creci,
        senha: senha,
        confirmarSenha: confirmarSenha,
      );

      _isLoading = false;
      
      if (response.success) {
        notifyListeners();
        return {'success': true};
      } else {
        _error = response.message;
        notifyListeners();
        return {
          'success': false,
          'message': response.message,
          'errors': response.errors,
        };
      }
    } catch (e) {
      _error = 'Erro no cadastro. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(email);
      
      _isLoading = false;
      
      if (!response.success) {
        _error = response.message;
      }
      
      notifyListeners();
      return response.success;
    } catch (e) {
      _error = 'Erro ao enviar email. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    
    _user = null;
    _isAuthenticated = false;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

