# Estrutura de Dados - Valeincorp Flutter

## Modelos de Dados

### 1. Imovel (Empreendimento)

```dart
class Imovel {
  final int id;
  final String codigo;
  final String nome;
  final String? imagem;
  final String localizacao;
  final String? dataEntrega;
  final String corretor;
  final String cidade;
  final String status;
  final double preco;
  final String? precoFormatado;
  final int dormitorios;
  final int banheiros;
  final int suites;
  final int? suitesMaster;
  final int vagas;
  final double area;
  final double? areaComum;
  final double? areaTotal;
  final int? unidadesDisponiveis;
  final int? totalUnidades;
  final int? unidadesVendidas;
  final double? percentualVendido;
  final String? statusVenda;
  final double? valorM2;
  final Coordenadas? coordenadas;
  final Endereco? endereco;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### 2. ImovelDetalhes (extends Imovel)

```dart
class ImovelDetalhes extends Imovel {
  final String? descricao;
  final List<String> imagens;
  final String? videoUrl;
  final List<Diferencial> diferenciais;
  final List<AndamentoObra> andamentoObra;
  final List<Story> stories;
  final List<PontoReferencia> pontosReferencia;
  final List<Transporte> transporte;
  final List<Documento> documentos;
  final List<VideoUnidade> videosUnidades;
  final Map<String, dynamic>? espelhoVendas;
}
```

### 3. Unidade

```dart
class Unidade {
  final int id;
  final int numero;
  final int andar;
  final String area;
  final String areaFormatada;
  final String? areaComumTotal;
  final int quartos;
  final int suites;
  final int banheiros;
  final String valor;
  final String valorFormatado;
  final double valorM2;
  final String valorM2Formatado;
  final String status;
  final String statusLabel;
  final int statusId;
  final String? observacao;
  final String? posicao;
  final bool vistaEspecial;
  final bool solManha;
  final bool solTarde;
  final List<FotoUnidade> fotos;
  final List<String> videos;
  final List<VagaGaragem> vagasGaragem;
  final List<MedidaUnidade> medidas;
  final String? planta;
  final Torre torre;
  final Empreendimento empreendimento;
}
```

### 4. Story

```dart
class Story {
  final int id;
  final String titulo;
  final String tipo; // folder, decorado, externa, interna, planta
  final String? descricao;
  final List<StoryImage> imagens;
}

class StoryImage {
  final String fotosUrl;
  final String? legenda;
}
```

### 5. Torre

```dart
class Torre {
  final int id;
  final String nome;
  final int numeroAndares;
  final int unidadesPorAndar;
}
```

### 6. Documento

```dart
class Documento {
  final int id;
  final String arquivoUrl;
  final TipoDocumento tipoDocumento;
}

class TipoDocumento {
  final int id;
  final String nome;
  final String tipoArquivo; // pdf, image, etc.
  final bool obrigatorio;
  final int ordem;
}
```

### 7. VagaGaragem

```dart
class VagaGaragem {
  final int id;
  final String numero;
  final String? tipo;
  final bool cobertura;
  final String area;
  final String pavimento;
  final String status;
  final String? observacoes;
}
```

### 8. MedidaUnidade

```dart
class MedidaUnidade {
  final int tipoMedidaId;
  final String tipoNome;
  final String tipoUnidade; // m², m, etc.
  final double valor;
}
```

### 9. AndamentoObra

```dart
class AndamentoObra {
  final String nome;
  final int progresso; // 0-100
}
```

### 10. Diferencial

```dart
class Diferencial {
  final int id;
  final String nome;
  final String icone;
}
```

### 11. VideoUnidade

```dart
class VideoUnidade {
  final int id;
  final String videoUrl;
  final String categoria;
  final String? originalName;
  final String? mimeType;
}
```

### 12. Endereco

```dart
class Endereco {
  final String logradouro;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
}
```

### 13. Coordenadas

```dart
class Coordenadas {
  final double lat;
  final double lng;
}
```

### 14. Usuario

```dart
class Usuario {
  final int id;
  final String nome;
  final String email;
  final String? creci;
  final String? telefone;
  final String? foto;
  final DateTime? createdAt;
}
```

### 15. ApiResponse<T>

```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Pagination? pagination;
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
```

---

## Providers (State Management)

### 1. FavoritosProvider

```dart
class FavoritosProvider extends ChangeNotifier {
  List<Imovel> _favoritos = [];
  bool _carregando = false;

  // Getters
  List<Imovel> get favoritos;
  bool get carregando;

  // Métodos
  Future<void> carregarFavoritos();
  Future<void> adicionarFavorito(Imovel imovel);
  Future<void> removerFavorito(int id);
  bool isFavorito(int id);
  Future<void> toggleFavorito(Imovel imovel);
}
```

### 2. AuthProvider

```dart
class AuthProvider extends ChangeNotifier {
  Usuario? _usuario;
  String? _token;
  bool _carregando = false;

  // Getters
  Usuario? get usuario;
  bool get isAuthenticated;
  bool get carregando;

  // Métodos
  Future<bool> login(String email, String senha);
  Future<bool> register(Map<String, dynamic> dados);
  Future<void> logout();
  Future<void> verificarToken();
  Future<void> atualizarPerfil(Map<String, dynamic> dados);
}
```

---

## Fluxo de Navegação

```
/ (Splash)
├── [Autenticado] → /dashboard
└── [Não autenticado] → /onboarding
    └── /login
        ├── /cadastro → /cadastro-sucesso → /login
        └── [Sucesso] → /dashboard

/dashboard (Tab 0 - Início)
├── Filtros (Estado, Cidade, Bairro)
├── Pesquisa
└── Click imóvel → /imovel/{id}
    ├── Modal: EspelhoVendas
    ├── Modal: ModalUnidades → /unidade/{id}
    ├── Modal: PDFViewer
    ├── Modal: StoriesModal
    └── Modal: CompartilhamentoModal

/buscar (Tab 1)
└── Resultados → /imovel/{id}

/favoritos (Tab 2)
└── Click favorito → /imovel/{id}

/perfil (Tab 3)
├── /perfil/meus-dados
├── /perfil/alterar-senha
├── Dúvidas (externo)
├── Termos (externo)
├── Privacidade (externo)
└── Sair → / (logout)
```

---

## Cores do Tema

```dart
class AppColors {
  // Primárias
  static const Color primaryBlue = Color(0xFF16244E);
  static const Color primaryGold = Color(0xFFC5A239);

  // Status
  static const Color disponivel = Color(0xFF22C55E); // verde
  static const Color reservado = Color(0xFFF59E0B);  // amarelo
  static const Color vendido = Color(0xFFEF4444);    // vermelho

  // Texto
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Background
  static const Color background = Color(0xFFF9FAFB);
  static const Color cardBackground = Colors.white;
  static const Color border = Color(0xFFE5E7EB);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
```

---

## Widgets Reutilizáveis

| Widget | Descrição | Uso |
|--------|-----------|-----|
| `ImagemImovel` | Exibe imagem com proxy e fallback | Cards de imóveis |
| `VideoPlayerWidget` | Player de vídeo com controles | Detalhes do imóvel |
| `PDFViewerModal` | Visualizador de PDF | Documentos |
| `StoriesModal` | Carrossel fullscreen de imagens | Stories |
| `CompartilhamentoModal` | Modal de compartilhamento | Compartilhar imóvel/unidade |
| `ModalUnidades` | Lista de torres e unidades | Ver disponibilidade |
| `EspelhoVendasModal` | Dashboard de vendas | Análise de vendas |
| `ImageZoomModal` | Galeria com zoom | Fotos da unidade |

