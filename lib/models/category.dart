/// Categoria resumida, incluída noutros modelos (`serviceCategoryId` e nome).
class CategoryRef {
  const CategoryRef({required this.serviceCategoryId, required this.name});

  factory CategoryRef.fromJson(Map<String, dynamic> json) => CategoryRef(
    serviceCategoryId: json['serviceCategoryId'] as int,
    name: json['name'] as String,
  );

  final int serviceCategoryId;
  final String name;
}

/// Estado de uma categoria.
enum ActivationStatus {
  active('ACTIVE', 'Ativa'),
  inactive('INACTIVE', 'Desativada');

  const ActivationStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ActivationStatus fromJson(String value) =>
      values.firstWhere((status) => status.apiValue == value);
}

/// Categoria de serviços com o estado (E08).
class Category {
  const Category({
    required this.serviceCategoryId,
    required this.name,
    required this.status,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    serviceCategoryId: json['serviceCategoryId'] as int,
    name: json['name'] as String,
    status: ActivationStatus.fromJson(json['status'] as String),
  );

  final int serviceCategoryId;
  final String name;
  final ActivationStatus status;
}
