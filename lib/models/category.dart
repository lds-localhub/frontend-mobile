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
