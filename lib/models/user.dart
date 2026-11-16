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

  /// Prestador que ainda não criou o perfil profissional.
  bool get needsProfile =>
      role == Role.provider && professionalProfileId == null;
}

/// Resposta do início de sessão (E02).
class LoginResult {
  const LoginResult({required this.token, required this.user});

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
    token: json['token'] as String,
    user: Me.fromJson(json['user'] as Map<String, dynamic>),
  );

  final String token;
  final Me user;
}

/// Corpo do registo de conta (E01).
class RegisterInput {
  const RegisterInput({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  final String name;
  final String email;
  final String password;
  final Role role;

  Map<String, Object?> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'role': role.apiValue,
  };
}

/// Corpo do início de sessão (E02), sempre como aplicação mobile.
class LoginInput {
  const LoginInput({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, Object?> toJson() => {
    'email': email,
    'password': password,
    // O backend recusa aqui as contas de Administrador
    'client': 'MOBILE',
  };
}

/// Corpo da alteração da própria palavra-passe (E40); a confirmação não é
/// enviada.
class ChangePasswordInput {
  const ChangePasswordInput({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  Map<String, Object?> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}
