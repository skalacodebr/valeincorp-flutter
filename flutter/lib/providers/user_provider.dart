import 'dart:io';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import 'auth_provider.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  
  AuthProvider? _authProvider;
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get nome => _user?.nome ?? 'Carregando...';
  String get email => _user?.email ?? '...';
  String get creci => _user?.creci ?? '...';
  String? get fotoUsuario => _user?.fotoUsuario;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (authProvider.isAuthenticated && authProvider.user != null) {
      _user = authProvider.user;
    }
  }

  Future<void> loadProfile() async {
    if (_authProvider == null || !_authProvider!.isAuthenticated) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _userService.getProfile();

      if (response.success && response.data != null) {
        _user = response.data;
        _authProvider?.setUser(response.data!);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Erro ao carregar perfil';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? nome,
    String? email,
    String? telefone,
    String? cpf,
    String? creci,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _userService.updateProfile(
        nome: nome,
        email: email,
        telefone: telefone,
        cpf: cpf,
        creci: creci,
      );

      if (response.success && response.data != null) {
        _user = response.data;
        _authProvider?.setUser(response.data!);
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
      _error = 'Erro ao atualizar perfil';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String senhaAtual,
    required String novaSenha,
    required String confirmarSenha,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _userService.changePassword(
        senhaAtual: senhaAtual,
        novaSenha: novaSenha,
        confirmarSenha: confirmarSenha,
      );

      _isLoading = false;
      
      if (!response.success) {
        _error = response.message ?? response.firstError;
      }
      
      notifyListeners();
      return response.success;
    } catch (e) {
      _error = 'Erro ao alterar senha';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadAvatar(File file) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _userService.uploadAvatar(file);

      if (response.success && response.data != null) {
        _user = response.data;
        _authProvider?.setUser(response.data!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao fazer upload';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}

