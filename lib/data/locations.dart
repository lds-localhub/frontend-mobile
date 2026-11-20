import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/auth.dart';
import 'package:localhub/models/location.dart';

/// Define a localização do Cliente autenticado (E16).
Future<void> setLocation(WidgetRef ref, {required LocationInput body}) async {
  await api('/users/me/location', method: 'PUT', body: body.toJson());
  // A morada registada vem do utilizador autenticado
  ref.invalidate(meProvider);
}

/// Morada correspondente a uma posição do dispositivo (E35); não grava nada.
Future<String> reverseGeocode({
  required double latitude,
  required double longitude,
}) async {
  final query = toQueryString({'latitude': latitude, 'longitude': longitude});
  final json = await api('/geocoding/reverse?$query');
  return ReverseGeocodingResult.fromJson(json! as Map<String, dynamic>).address;
}
