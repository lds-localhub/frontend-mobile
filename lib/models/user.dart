/// Papel de uma conta.
enum Role {
  client('CLIENT', 'Cliente'),
  provider('PROVIDER', 'Prestador de Serviços'),
  admin('ADMIN', 'Administrador');

  const Role(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static Role fromJson(String value) =>
      values.firstWhere((role) => role.apiValue == value);
}

/// Utilizador autenticado (E04; também o `user` do início de sessão).
class Me {
  const Me({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.address,
    required this.professionalProfileId,
  });

  factory Me.fromJson(Map<String, dynamic> json) => Me(
    userId: json['userId'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    role: Role.fromJson(json['role'] as String),
    address: json['address'] as String?,
    professionalProfileId: json['professionalProfileId'] as int?,
  );

  final int userId;
  final String name;
  final String email;
  final Role role;

  /// Localização registada; `null` enquanto não for definida.
  final String? address;

  /// Perfil profissional; `null` para Clientes e Prestadores sem perfil.
  final int? professionalProfileId;
}
