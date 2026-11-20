import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/app_lifecycle.dart';
import 'package:localhub/data/auth.dart';
import 'package:localhub/models/page.dart';
import 'package:localhub/models/profile.dart';

/// Perfil profissional de um Prestador (E13); o Prestador só lê o seu.
final profileProvider = FutureProvider.autoDispose.family<Profile, int>((
  ref,
  professionalProfileId,
) async {
  ref.watch(appResumedProvider);
  final json = await api('/profiles/$professionalProfileId');
  return Profile.fromJson(json! as Map<String, dynamic>);
});

/// Avaliações de um Prestador, da mais recente para a mais antiga (E15).
final reviewsProvider = FutureProvider.autoDispose
    .family<Page<Review>, ReviewsParams>((ref, params) async {
      ref.watch(appResumedProvider);
      final query = toQueryString({
        'page': params.page,
        'pageSize': params.pageSize,
      });
      final json = await api(
        '/profiles/${params.professionalProfileId}/reviews?$query',
      );
      return Page.fromJson(json! as Map<String, dynamic>, Review.fromJson);
    });

/// Cria o perfil profissional do Prestador autenticado (E12).
Future<void> createProfile(WidgetRef ref, {required ProfileInput body}) async {
  await api('/profiles', method: 'POST', body: body.toJson());
  // O utilizador autenticado passa a ter perfil, e as guardas deixam-no passar
  ref.invalidate(meProvider);
}

/// Atualiza o perfil profissional do Prestador autenticado (E14).
Future<void> updateProfile(WidgetRef ref, {required ProfileInput body}) async {
  await api('/profiles/me', method: 'PUT', body: body.toJson());
  ref.invalidate(profileProvider);
}
