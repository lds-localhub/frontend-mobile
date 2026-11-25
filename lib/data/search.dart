import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/models/page.dart';
import 'package:localhub/models/profile.dart';

import 'app_lifecycle.dart';

/// Prestadores de uma categoria, do mais próximo ao mais distante da
/// localização de referência (E18).
final searchProvidersProvider = FutureProvider.autoDispose
    .family<Page<ProviderSearchItem>, SearchProvidersParams>((
      ref,
      params,
    ) async {
      ref.watch(appResumedProvider);
      final query = toQueryString({
        'serviceCategoryId': params.serviceCategoryId,
        'address': params.address,
        'name': params.name,
        'page': params.page,
      });
      final json = await api('/search/providers?$query');
      return Page.fromJson(
        json! as Map<String, dynamic>,
        ProviderSearchItem.fromJson,
      );
    });
