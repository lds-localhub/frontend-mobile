import 'dart:convert';

import 'package:http/http.dart' as http;

import 'accounts.dart';
import 'addresses.dart';
import 'providers.dart';

// Preparação de serviços, propostas e avaliações pela API documentada (E20,
// E25, E28, E29, E31, E32), sem acesso direto à base de dados. Ficam com a
// data do dia da execução.

/// Data UTC de hoje (`AAAA-MM-DD`), a que o backend usa para validar as datas.
String todayUtc() => DateTime.now().toUtc().toIso8601String().substring(0, 10);

Future<Map<String, dynamic>> _post(
  String path,
  String token,
  int status, [
  Map<String, Object?>? body,
]) async {
  final response = await http.post(
    apiUri(path),
    headers: jsonHeaders(token: token),
    body: body == null ? null : jsonEncode(body),
  );
  failIfNot(response, status);
  return response.body.isEmpty
      ? const {}
      : jsonDecode(response.body) as Map<String, dynamic>;
}

/// E20: serviço do [client] com uma solicitação direta ao [provider].
Future<int> createDirectRequestService(
  TestAccount client,
  TestProvider provider, {
  String categoryName = 'Canalização',
}) async {
  final [categoryId] = await categoryIds([categoryName]);
  final body = await _post('/api/services', client.token, 201, {
    'proposalModel': 'DIRECT_REQUEST',
    'serviceCategoryId': categoryId,
    'title': 'Serviço ${uniqueId()}',
    'description': 'Serviço criado pelos testes de sistema.',
    'requestedStartDate': todayUtc(),
    'location': testAddresses['carla'],
    'professionalProfileIds': [provider.professionalProfileId],
  });
  return body['serviceId'] as int;
}

/// E25: proposta do [provider] ao serviço [serviceId]; devolve o `proposalId`.
Future<int> submitProposal(
  TestProvider provider,
  int serviceId, {
  double amount = 80,
}) async {
  final body = await _post(
    '/api/services/$serviceId/proposals',
    provider.account.token,
    201,
    {'amount': amount, 'conditions': 'Condições dos testes de sistema.'},
  );
  return body['proposalId'] as int;
}

/// E28: o [client] aceita a proposta; o serviço passa a atribuído.
Future<void> acceptProposal(TestAccount client, int proposalId) =>
    _post('/api/proposals/$proposalId/accept', client.token, 200);

/// E29: o [client] recusa a proposta.
Future<void> declineProposal(TestAccount client, int proposalId) =>
    _post('/api/proposals/$proposalId/decline', client.token, 200);

/// E31: o [client] marca o serviço como realizado.
Future<void> completeService(TestAccount client, int serviceId) =>
    _post('/api/services/$serviceId/complete', client.token, 200);

/// E32: o [client] avalia o serviço realizado.
Future<void> reviewService(TestAccount client, int serviceId, int rating) =>
    _post('/api/services/$serviceId/review', client.token, 201, {
      'rating': rating,
    });

/// E20 + E25 + E28 + E31 (+ E32): serviço realizado, com a proposta do
/// [provider] aceite e, com [rating], avaliado.
Future<int> createCompletedService(
  TestAccount client,
  TestProvider provider, {
  double amount = 80,
  int? rating,
}) async {
  final serviceId = await createDirectRequestService(client, provider);
  final proposalId = await submitProposal(provider, serviceId, amount: amount);
  await acceptProposal(client, proposalId);
  await completeService(client, serviceId);
  if (rating != null) {
    await reviewService(client, serviceId, rating);
  }
  return serviceId;
}
