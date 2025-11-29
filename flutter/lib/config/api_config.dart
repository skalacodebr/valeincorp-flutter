class ApiConfig {
  // Para testes locais, use: 'http://127.0.0.1:8000/api'
  // Para produção, use: 'https://backend.valeincorp.com.br/api'
  static const String baseUrl = 'https://backend.valeincorp.com.br/api';
  
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
  
  // Favoritos endpoints
  static const String favoritos = '/favoritos';
  static String favoritoRemove(int imovelId) => '/favoritos/$imovelId';
  static String favoritoCheck(int imovelId) => '/favoritos/check/$imovelId';
  static const String favoritosCount = '/favoritos/count';
  
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
  
  // Compartilhamentos endpoints
  static const String compartilhamentos = '/compartilhamentos';
  static String compartilhamentoById(int id) => '/compartilhamentos/$id';
  static String compartilhamentoEstatisticas(int id) => '/compartilhamentos/$id/estatisticas';
  
  // System endpoints
  static const String health = '/health';
  static const String config = '/config';
}

