/// URL base da API do backend.
///
/// Definido em tempo de compilação com
/// `--dart-define=API_BASE_URL=<url>`. Por omissão aponta para o backend
/// local visto a partir do emulador Android, em que `10.0.2.2` corresponde ao
/// `localhost` do computador.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:5041',
);
