import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/favoritos_service.dart';
import '../services/api_service.dart';
import '../models/imovel.dart';
import 'auth_provider.dart';

class FavoritosProvider extends ChangeNotifier {
  final FavoritosService _favoritosService = FavoritosService();
  final ApiService _apiService = ApiService();
  
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
  
  /// Verifica se há token real de autenticação (não apenas isAuthenticated local)
  Future<bool> _hasRealToken() async {
    return await _apiService.hasToken();
  }

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
    
    // Verificar se há token real (não apenas login de teste)
    final hasToken = await _hasRealToken();
    if (!hasToken) {
      _error = 'Faça login com sua conta para adicionar favoritos';
      debugPrint('[FavoritosProvider] Tentativa de adicionar favorito sem token real');
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
        _error = response.message ?? 'Erro ao adicionar favorito';
        debugPrint('[FavoritosProvider] Falha ao adicionar: ${response.message}');
        notifyListeners();
        return false;
      }

      _error = null; // Limpa erro anterior em caso de sucesso
      debugPrint('[FavoritosProvider] Favorito adicionado com sucesso: ${imovel.id}');
      return true;
    } catch (e) {
      // Revert on error
      _favoritosIds.remove(imovel.id);
      _favoritos.removeWhere((f) => f.id == imovel.id);
      _totalFavoritos--;
      _error = 'Erro ao adicionar favorito';
      debugPrint('[FavoritosProvider] Exceção ao adicionar: $e');
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
    
    // Verificar se há token real (não apenas login de teste)
    final hasToken = await _hasRealToken();
    if (!hasToken) {
      _error = 'Faça login com sua conta para remover favoritos';
      debugPrint('[FavoritosProvider] Tentativa de remover favorito sem token real');
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
        _error = response.message ?? 'Erro ao remover favorito';
        debugPrint('[FavoritosProvider] Falha ao remover: ${response.message}');
        notifyListeners();
        return false;
      }

      _error = null; // Limpa erro anterior em caso de sucesso
      debugPrint('[FavoritosProvider] Favorito removido com sucesso: $imovelId');
      return true;
    } catch (e) {
      // Revert on error
      _favoritosIds.add(imovelId);
      _favoritos.add(imovelRemovido);
      _totalFavoritos++;
      _error = 'Erro ao remover favorito';
      debugPrint('[FavoritosProvider] Exceção ao remover: $e');
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

