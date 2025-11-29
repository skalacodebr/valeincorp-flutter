import 'package:flutter/material.dart';
import '../services/favoritos_service.dart';
import '../models/imovel.dart';
import 'auth_provider.dart';

class FavoritosProvider extends ChangeNotifier {
  final FavoritosService _favoritosService = FavoritosService();
  
  AuthProvider? _authProvider;
  List<Imovel> _favoritos = [];
  Set<int> _favoritosIds = {};
  bool _isLoading = false;
  String? _error;
  int _totalFavoritos = 0;

  List<Imovel> get favoritos => _favoritos;
  Set<int> get favoritosIds => _favoritosIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalFavoritos => _totalFavoritos;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (authProvider.isAuthenticated) {
      loadFavoritos();
    } else {
      _favoritos = [];
      _favoritosIds = {};
      _totalFavoritos = 0;
    }
  }

  Future<void> loadFavoritos({String? search}) async {
    if (_authProvider == null || !_authProvider!.isAuthenticated) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _favoritosService.list(search: search);

      if (response.success && response.data != null) {
        _favoritos = response.data!;
        _favoritosIds = _favoritos.map((f) => f.id).toSet();
        _totalFavoritos = _favoritos.length;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Erro ao carregar favoritos';
    }

    _isLoading = false;
    notifyListeners();
  }

  bool isFavorito(int imovelId) {
    return _favoritosIds.contains(imovelId);
  }

  Future<bool> toggleFavorito(Imovel imovel) async {
    if (isFavorito(imovel.id)) {
      return await removerFavorito(imovel.id);
    } else {
      return await adicionarFavorito(imovel);
    }
  }

  Future<bool> adicionarFavorito(Imovel imovel) async {
    if (_authProvider == null || !_authProvider!.isAuthenticated) {
      _error = 'Você precisa estar logado';
      notifyListeners();
      return false;
    }

    // Otimistic update
    _favoritosIds.add(imovel.id);
    _favoritos.add(imovel);
    _totalFavoritos++;
    notifyListeners();

    try {
      final response = await _favoritosService.add(imovel.id);

      if (!response.success) {
        // Revert on failure
        _favoritosIds.remove(imovel.id);
        _favoritos.removeWhere((f) => f.id == imovel.id);
        _totalFavoritos--;
        _error = response.message;
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      // Revert on error
      _favoritosIds.remove(imovel.id);
      _favoritos.removeWhere((f) => f.id == imovel.id);
      _totalFavoritos--;
      _error = 'Erro ao adicionar favorito';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removerFavorito(int imovelId) async {
    if (_authProvider == null || !_authProvider!.isAuthenticated) {
      _error = 'Você precisa estar logado';
      notifyListeners();
      return false;
    }

    // Store for potential revert
    final imovelRemovido = _favoritos.firstWhere(
      (f) => f.id == imovelId,
      orElse: () => _favoritos.first,
    );

    // Optimistic update
    _favoritosIds.remove(imovelId);
    _favoritos.removeWhere((f) => f.id == imovelId);
    _totalFavoritos--;
    notifyListeners();

    try {
      final response = await _favoritosService.remove(imovelId);

      if (!response.success) {
        // Revert on failure
        _favoritosIds.add(imovelId);
        _favoritos.add(imovelRemovido);
        _totalFavoritos++;
        _error = response.message;
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      // Revert on error
      _favoritosIds.add(imovelId);
      _favoritos.add(imovelRemovido);
      _totalFavoritos++;
      _error = 'Erro ao remover favorito';
      notifyListeners();
      return false;
    }
  }

  Future<void> checkFavorito(int imovelId) async {
    try {
      final response = await _favoritosService.check(imovelId);
      
      if (response.success && response.data == true) {
        _favoritosIds.add(imovelId);
      } else {
        _favoritosIds.remove(imovelId);
      }
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearFavoritos() {
    _favoritos = [];
    _favoritosIds = {};
    _totalFavoritos = 0;
    notifyListeners();
  }
}

