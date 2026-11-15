// Geocodificador simulado (stub do Nominatim) para os testes de sistema.
//
// O backend real é configurado com Nominatim__BaseUrl=http://localhost:<porta>/
// e passa a pedir aqui as coordenadas das moradas, sem alterar o código do
// backend. O serviço público limita os pedidos a cerca de 1 por segundo, pode
// bloquear os IP do CI e devolver coordenadas diferentes ao longo do tempo; o
// stub responde sempre o mesmo, no formato jsonv2 do Nominatim.
//
// Execução: dart run tool/nominatim_stub.dart
// Porta: variável NOMINATIM_STUB_PORT (por omissão, 8089).

import 'dart:convert';
import 'dart:io';

/// Localidade com coordenadas fixas e a morada da pesquisa inversa.
class Localidade {
  const Localidade({
    required this.chave,
    required this.lat,
    required this.lon,
    required this.rua,
    required this.numero,
    required this.codigoPostal,
    required this.cidade,
  });

  /// Texto procurado na morada, sem acentos e em minúsculas.
  final String chave;
  final String lat;
  final String lon;
  final String rua;
  final String numero;
  final String codigoPostal;
  final String cidade;

  String get nomeCompleto => '$rua $numero, $codigoPostal $cidade, Portugal';
}

/// Coordenadas fixas, aproximadas ao centro das localidades (dados fictícios,
/// RNF-20). A primeira localidade que aparecer na morada é a usada. Iguais às
/// do stub do frontend web.
const localidades = <Localidade>[
  Localidade(
    chave: 'porto',
    lat: '41.1496',
    lon: '-8.6109',
    rua: 'Avenida dos Aliados',
    numero: '1',
    codigoPostal: '4000-064',
    cidade: 'Porto',
  ),
  Localidade(
    chave: 'felgueiras',
    lat: '41.3647',
    lon: '-8.1979',
    rua: 'Rua Dr. Leonardo Coimbra',
    numero: '10',
    codigoPostal: '4610-105',
    cidade: 'Felgueiras',
  ),
  Localidade(
    chave: 'braga',
    lat: '41.5454',
    lon: '-8.4265',
    rua: 'Avenida da Liberdade',
    numero: '1',
    codigoPostal: '4710-251',
    cidade: 'Braga',
  ),
  Localidade(
    chave: 'lisboa',
    lat: '38.7223',
    lon: '-9.1393',
    rua: 'Avenida da Liberdade',
    numero: '1',
    codigoPostal: '1250-096',
    cidade: 'Lisboa',
  ),
];

/// Uma morada com este texto simula o Nominatim indisponível (HTTP 503).
const moradaIndisponivel = 'geocodificador indisponivel';

const _semAcentos = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', //
  'é': 'e', 'ê': 'e', 'í': 'i', 'ó': 'o', 'ô': 'o', 'õ': 'o', //
  'ú': 'u', 'ü': 'u', 'ç': 'c',
};

String normalizar(String texto) {
  final buffer = StringBuffer();
  for (final letra in texto.toLowerCase().split('')) {
    buffer.write(_semAcentos[letra] ?? letra);
  }
  return buffer.toString();
}

Localidade? procurarPorMorada(String morada) {
  final texto = normalizar(morada);
  for (final l in localidades) {
    if (texto.contains(l.chave)) {
      return l;
    }
  }
  return null;
}

/// Localidade mais próxima das coordenadas (distância simples em graus,
/// suficiente para os testes).
Localidade procurarPorCoordenadas(double lat, double lon) {
  var melhor = localidades.first;
  var menor = double.infinity;
  for (final l in localidades) {
    final dLat = double.parse(l.lat) - lat;
    final dLon = double.parse(l.lon) - lon;
    final d = dLat * dLat + dLon * dLon;
    if (d < menor) {
      menor = d;
      melhor = l;
    }
  }
  return melhor;
}

Future<void> enviarJson(HttpResponse res, int estado, Object corpo) async {
  res.statusCode = estado;
  res.headers.contentType = ContentType.json;
  res.write(jsonEncode(corpo));
  await res.close();
}

Future<void> responder(HttpRequest req) async {
  final url = req.uri;
  stdout.writeln(
    '${DateTime.now().toUtc().toIso8601String()} ${req.method} $url',
  );
  final res = req.response;

  if (req.method != 'GET') {
    return enviarJson(res, 405, {'error': 'Method not allowed'});
  }

  switch (url.path) {
    // Verificação de que o stub está a responder (usada pela pipeline)
    case '/status':
      return enviarJson(res, 200, {'status': 0, 'message': 'OK'});

    case '/search':
      final morada = url.queryParameters['q'] ?? '';
      if (normalizar(morada).contains(moradaIndisponivel)) {
        return enviarJson(res, 503, {'error': 'Service unavailable'});
      }
      final l = procurarPorMorada(morada);
      // Morada desconhecida: o Nominatim responde 200 com uma lista vazia
      return enviarJson(res, 200, [
        if (l != null)
          {'lat': l.lat, 'lon': l.lon, 'display_name': l.nomeCompleto},
      ]);

    case '/reverse':
      final lat = double.tryParse(url.queryParameters['lat'] ?? '');
      final lon = double.tryParse(url.queryParameters['lon'] ?? '');
      if (lat == null || lon == null) {
        return enviarJson(res, 400, {'error': 'Invalid coordinates'});
      }
      final l = procurarPorCoordenadas(lat, lon);
      return enviarJson(res, 200, {
        'lat': l.lat,
        'lon': l.lon,
        'display_name': l.nomeCompleto,
        'address': {
          'road': l.rua,
          'house_number': l.numero,
          'postcode': l.codigoPostal,
          'city': l.cidade,
          'country': 'Portugal',
        },
      });

    default:
      return enviarJson(res, 404, {'error': 'Not found'});
  }
}

Future<void> main() async {
  final porta =
      int.tryParse(Platform.environment['NOMINATIM_STUB_PORT'] ?? '') ?? 8089;
  final servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, porta);
  stdout.writeln(
    'Geocodificador simulado (Nominatim) em http://localhost:$porta/',
  );
  await for (final req in servidor) {
    await responder(req);
  }
}
