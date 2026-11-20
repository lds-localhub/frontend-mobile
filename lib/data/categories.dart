import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/app_lifecycle.dart';
import 'package:localhub/models/category.dart';
import 'package:localhub/models/page.dart';

/// Categorias ativas, ordenadas pelo nome, para os seletores de categoria
/// (E08).
final categoriesProvider = FutureProvider.autoDispose<List<Category>>((
  ref,
) async {
  ref.watch(appResumedProvider);
  // Sem `includeInactive`, a API devolve só as categorias ativas
  final json = await api('/categories');
  return ListResult.fromJson(
    json! as Map<String, dynamic>,
    Category.fromJson,
  ).items;
});
