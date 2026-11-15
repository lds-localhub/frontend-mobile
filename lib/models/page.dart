/// Lista paginada da API (`page`, `pageSize`, `total`, `items`).
class Page<T> {
  const Page({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });

  factory Page.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) => Page(
    page: json['page'] as int,
    pageSize: json['pageSize'] as int,
    total: json['total'] as int,
    items: [
      for (final item in json['items'] as List)
        itemFromJson(item as Map<String, dynamic>),
    ],
  );

  final int page;
  final int pageSize;
  final int total;
  final List<T> items;

  /// Há mais itens depois desta página.
  bool get hasMore => page * pageSize < total;
}

/// Lista sem paginação da API (`total`, `items`).
class ListResult<T> {
  const ListResult({required this.total, required this.items});

  factory ListResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) => ListResult(
    total: json['total'] as int,
    items: [
      for (final item in json['items'] as List)
        itemFromJson(item as Map<String, dynamic>),
    ],
  );

  final int total;
  final List<T> items;
}
