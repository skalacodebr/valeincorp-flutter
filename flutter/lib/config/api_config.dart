class ApiConfig {
  // =====================================================
  // CONFIGURAÇÃO HÍBRIDA (DESENVOLVIMENTO)
  // =====================================================
  // - Dados (empreendimentos, login, etc) → Produção (com imagens/fotos)
  // - Compartilhamentos e Favoritos → Servidor local (para testes sem auth)
  // =====================================================
  
  // PRODUÇÃO - para ver empreendimentos com imagens/fotos reais
  static const String baseUrl = 'https://backend.valeincorp.com.br/api';
  
  // LOCAL - para testar compartilhamentos e favoritos (sem auth)
  // Usa rotas de teste: /api/test-compartilhamentos e /api/test-favoritos
  static const String localBaseUrl = 'http://192.168.2.116:8000/api';
  
  // Flag para usar endpoints de teste (sem autenticação)
  static const bool useTestEndpoints = true;
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String refreshToken = '/auth/refresh';
  
  // User endpoints
  static const String userProfile = '/users/profile';
  static const String uploadAvatar = '/users/upload-avatar';
  
  // Imoveis endpoints
  static const String imoveis = '/imoveis';
  static String imovelById(int id) => '/imoveis/$id';
  static String imovelImages(int id, String storyType) => '/imoveis/$id/images/$storyType';
  
  // Favoritos endpoints - usa test-favoritos quando em modo de teste
  static String get favoritos => useTestEndpoints ? '/test-favoritos' : '/favoritos';
  static String favoritoRemove(int imovelId) => useTestEndpoints 
      ? '/test-favoritos/$imovelId' 
      : '/favoritos/$imovelId';
  static String favoritoCheck(int imovelId) => useTestEndpoints 
      ? '/test-favoritos/check/$imovelId' 
      : '/favoritos/check/$imovelId';
  static String get favoritosCount => useTestEndpoints ? '/test-favoritos/count' : '/favoritos/count';
  
  // Busca endpoints
  static const String cidades = '/cidades';
  static const String buscar = '/buscar';
  
  // Construtoras endpoints
  static const String construtoras = '/construtoras';
  static String construtoraById(int id) => '/construtoras/$id';
  static String construtoraEmpreendimentos(int id) => '/construtoras/$id/empreendimentos';
  
  // Unidades endpoints
  static String unidadeById(int id) => '/unidades/$id';
  
  // Empreendimentos endpoints
  static String empreendimentoById(int id) => '/empreendimentos/$id';
  static String empreendimentoTorres(int id) => '/empreendimentos/$id';
  
  // Torres endpoints
  static String torreUnidades(int torreId) => '/torres/$torreId/unidades';
  
  // Compartilhamentos endpoints - usa test-compartilhamentos quando em modo de teste
  static String get compartilhamentos => useTestEndpoints 
      ? '/test-compartilhamentos' 
      : '/compartilhamentos';
  static String get compartilhamentosTest => compartilhamentos;
  static String get compartilhamentosBaseUrl => localBaseUrl;
  static String compartilhamentoById(int id) => useTestEndpoints 
      ? '/test-compartilhamentos/$id' 
      : '/compartilhamentos/$id';
  static String compartilhamentoEstatisticas(int id) => '/compartilhamentos/$id/estatisticas';
  
  // System endpoints
  static const String health = '/health';
  static const String config = '/config';
}

