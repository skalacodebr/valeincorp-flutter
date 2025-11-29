# Valeincorp Flutter App

Aplicativo móvel Valeincorp para imóveis e empreendimentos, desenvolvido em Flutter.

## Requisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code com extensões Flutter

## Instalação

1. Clone o repositório
2. Navegue até a pasta `flutter/`
3. Execute:

```bash
flutter pub get
```

## Executar o App

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Estrutura do Projeto

```
lib/
├── config/
│   ├── api_config.dart    # URLs e endpoints da API
│   ├── theme.dart         # Cores e estilos
│   └── routes.dart        # Navegação
├── models/
│   ├── user.dart          # Modelo de usuário
│   ├── imovel.dart        # Modelo de imóvel
│   ├── imovel_detalhes.dart
│   ├── favorito.dart
│   ├── unidade.dart
│   └── api_response.dart
├── services/
│   ├── api_service.dart   # Cliente HTTP base
│   ├── auth_service.dart  # Autenticação
│   ├── user_service.dart  # Perfil
│   ├── imoveis_service.dart
│   └── favoritos_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   └── favoritos_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── cadastro_screen.dart
│   ├── dashboard_screen.dart
│   ├── buscar_screen.dart
│   ├── empreendimentos_screen.dart
│   ├── imovel_detalhes_screen.dart
│   ├── unidade_detalhes_screen.dart
│   ├── favoritos_screen.dart
│   ├── perfil_screen.dart
│   ├── meus_dados_screen.dart
│   └── alterar_senha_screen.dart
├── widgets/
│   ├── campo_input.dart
│   ├── botao_principal.dart
│   ├── card_imovel.dart
│   ├── bottom_navigation.dart
│   ├── image_carousel.dart
│   ├── video_player_widget.dart
│   ├── pdf_viewer_widget.dart
│   └── map_widget.dart
├── utils/
│   └── formatters.dart
└── main.dart
```

## Funcionalidades

### Autenticação
- Login com email e senha
- Cadastro em 3 etapas
- Recuperação de senha
- Token JWT com refresh

### Imóveis
- Listagem com grid
- Filtros por estado, cidade, bairro
- Busca por nome ou código
- Detalhes completos com:
  - Stories (galeria de imagens)
  - Vídeos
  - Documentos PDF
  - Localização no mapa
  - Andamento da obra
  - Unidades disponíveis

### Favoritos
- Adicionar/remover favoritos
- Listagem de favoritos
- Busca dentro dos favoritos

### Perfil
- Visualizar e editar dados
- Upload de foto
- Alterar senha
- Logout

## API

O app se conecta à API em:
```
https://backend.valeincorp.com.br/api
```

### Endpoints Utilizados

- `POST /auth/login` - Login
- `POST /auth/register` - Cadastro
- `POST /auth/refresh` - Refresh token
- `GET /users/profile` - Perfil
- `PUT /users/profile` - Atualizar perfil
- `POST /users/upload-avatar` - Upload foto
- `GET /imoveis` - Listar imóveis
- `GET /imoveis/:id` - Detalhes
- `GET /favoritos` - Listar favoritos
- `POST /favoritos` - Adicionar
- `DELETE /favoritos/:id` - Remover

## Cores do Tema

- Azul escuro: `#16244E`
- Dourado: `#C5A239`

## Build

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

## Dependências Principais

- `provider` - Gerenciamento de estado
- `dio` - Cliente HTTP
- `flutter_secure_storage` - Armazenamento seguro
- `cached_network_image` - Cache de imagens
- `video_player` - Player de vídeo
- `flutter_pdfview` - Visualizador PDF
- `share_plus` - Compartilhamento
- `url_launcher` - Abrir links externos
- `mask_text_input_formatter` - Máscaras de input

