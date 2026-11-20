import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/app_lifecycle.dart';
import 'package:localhub/data/auth.dart';
import 'package:localhub/models/profile.dart';

final profileProvider = FutureProvider.autoDispose.family<Profile?, int>((
  ref,
  id,
) async {
  ref.watch(appResumedProvider);
  final json = await api('/profiles/$id');

  return Profile.fromJson(json! as Map<String, dynamic>);
});

/// Cria o perfil do Prestador; o utilizador autenticado passa a ter perfil e as guardas deixam-no passar.
Future<void> createProfile(WidgetRef ref, {required ProfileInput body}) async {
  await api('/profiles', method: 'POST', body: body.toJson());
  ref.invalidate(meProvider);
}

/// Atualiza o perfil do próprio Prestador.
Future<void> updateProfile(WidgetRef ref, {required ProfileInput body}) async {
  await api('/profiles/me', method: 'PUT', body: body.toJson());
  ref.invalidate(profileProvider);
}
