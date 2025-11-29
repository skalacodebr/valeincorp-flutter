class User {
  final int id;
  final String nome;
  final String email;
  final String creci;
  final String telefone;
  final String cpfCnpj;
  final bool isPessoaJuridica;
  final String? fotoUsuario;
  final String? documento;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.nome,
    required this.email,
    required this.creci,
    required this.telefone,
    required this.cpfCnpj,
    this.isPessoaJuridica = false,
    this.fotoUsuario,
    this.documento,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? json['nomeCompleto'] ?? '',
      email: json['email'] ?? '',
      creci: json['creci'] ?? '',
      telefone: json['telefone'] ?? '',
      cpfCnpj: json['cpfCnpj'] ?? json['cpf'] ?? '',
      isPessoaJuridica: json['isPessoaJuridica'] ?? json['is_pessoa_juridica'] ?? false,
      fotoUsuario: json['fotoUsuario'] ?? json['foto_usuario'],
      documento: json['documento'] ?? json['documento_url'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'creci': creci,
      'telefone': telefone,
      'cpf': cpfCnpj,
      'isPessoaJuridica': isPessoaJuridica,
      'fotoUsuario': fotoUsuario,
      'documento': documento,
    };
  }

  User copyWith({
    int? id,
    String? nome,
    String? email,
    String? creci,
    String? telefone,
    String? cpfCnpj,
    bool? isPessoaJuridica,
    String? fotoUsuario,
    String? documento,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      creci: creci ?? this.creci,
      telefone: telefone ?? this.telefone,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      isPessoaJuridica: isPessoaJuridica ?? this.isPessoaJuridica,
      fotoUsuario: fotoUsuario ?? this.fotoUsuario,
      documento: documento ?? this.documento,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AuthResponse {
  final User user;
  final String token;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.token,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] ?? json['data']?['user'] ?? {}),
      token: json['token'] ?? json['data']?['token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['data']?['refreshToken'] ?? '',
    );
  }
}

