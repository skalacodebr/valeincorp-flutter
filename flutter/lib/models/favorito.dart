import 'imovel.dart';

class Favorito {
  final int id;
  final int imovelId;
  final Imovel imovel;
  final DateTime favoritadoEm;

  Favorito({
    required this.id,
    required this.imovelId,
    required this.imovel,
    required this.favoritadoEm,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      id: json['id'] ?? 0,
      imovelId: json['imovelId'] ?? json['imovel_id'] ?? 0,
      imovel: Imovel.fromJson(json['imovel'] ?? {}),
      favoritadoEm: json['favoritadoEm'] != null 
          ? DateTime.parse(json['favoritadoEm'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imovelId': imovelId,
      'imovel': imovel.toJson(),
      'favoritadoEm': favoritadoEm.toIso8601String(),
    };
  }
}

