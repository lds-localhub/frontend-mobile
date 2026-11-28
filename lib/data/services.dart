import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/models/service.dart';

import 'app_lifecycle.dart';

/// Detalhe de um serviço do Cliente autenticado.
final serviceProvider = FutureProvider.autoDispose.family<ServiceDetail, int>((
  ref,
  serviceId,
) async {
  ref.watch(appResumedProvider);
  final json = await api('/services/$serviceId');
  return ServiceDetail.fromJson(json! as Map<String, dynamic>);
});

/// Cria um serviço e devolve-o, para abrir o seu detalhe.
Future<ServiceDetail> createService(
  WidgetRef ref, {
  required CreateServiceInput body,
}) async {
  final json = await api('/services', method: 'POST', body: body.toJson());
  return ServiceDetail.fromJson(json! as Map<String, dynamic>);
}
