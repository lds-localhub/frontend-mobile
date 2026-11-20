enum ActivationStatus {
  active('ACTIVE', 'Ativa'),
  inactive('INACTIVE', 'Desativada');

  const ActivationStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static ActivationStatus fromJson(String value) =>
      values.firstWhere((s) => s.apiValue == value);
}

/// Categoria resumida, incluída noutros modelos (perfil, serviços, relatórios).
class CategoryRef {
  const CategoryRef({required this.serviceCategoryId, required this.name});

  final int serviceCategoryId;
  final String name;

  factory CategoryRef.fromJson(Map<String, dynamic> json) => CategoryRef(
    serviceCategoryId: json['serviceCategoryId'] as int,
    name: json['name'] as String,
  );
}

/// Categoria com o estado (lista das categorias).
class Category {
  const Category({
    required this.serviceCategoryId,
    required this.name,
    required this.status,
  });

  final int serviceCategoryId;
  final String name;
  final ActivationStatus status;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    serviceCategoryId: json['serviceCategoryId'] as int,
    name: json['name'] as String,
    status: ActivationStatus.fromJson(json['status'] as String),
  );
}
