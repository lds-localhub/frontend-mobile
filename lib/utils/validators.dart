/// Regra de um campo de texto: devolve a mensagem de erro, ou `null`.
typedef Validator = String? Function(String? value);

/// Junta vários validadores de um campo: devolve o primeiro erro.
Validator all(List<Validator> validators) => (value) {
  for (final validator in validators) {
    final error = validator(value);
    if (error != null) {
      return error;
    }
  }
  return null;
};

/// Campo obrigatório (só espaços conta como vazio).
Validator notEmpty(String message) =>
    (value) => (value == null || value.trim().isEmpty) ? message : null;

/// Tamanho máximo, contado sem os espaços do início e do fim.
Validator maxLength(int max, String message) =>
    (value) => (value != null && value.trim().length > max) ? message : null;

/// Número inteiro de [min] a [max] (ex.: o raio de atuação).
Validator intRange(int min, int max, String message) => (value) {
  final number = int.tryParse((value ?? '').trim());
  return (number == null || number < min || number > max) ? message : null;
};

/// Formato simples de e-mail (texto, `@`, domínio com ponto); a validação
/// final é do backend.
Validator email(String message) =>
    (value) =>
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((value ?? '').trim())
        ? null
        : message;

/// Palavra-passe com, no mínimo, 8 caracteres, uma letra e um algarismo.
Validator password() => (value) {
  final text = value ?? '';
  final valid =
      text.length >= 8 &&
      RegExp(r'\p{L}', unicode: true).hasMatch(text) &&
      RegExp(r'\d').hasMatch(text);
  return valid
      ? null
      : 'A palavra-passe tem de ter, no mínimo, 8 caracteres, com pelo menos '
            'uma letra e um algarismo.';
};
