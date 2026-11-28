import 'package:localhub/models/category.dart';

/// Perfil profissional de um Prestador (E13).
class Profile {
  const Profile({
    required this.professionalProfileId,
    required this.name,
    required this.introduction,
    required this.contactDetails,
    required this.experience,
    required this.serviceCategories,
    required this.address,
    required this.serviceRadiusKm,
    required this.averageRating,
    required this.reviewCount,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    professionalProfileId: json['professionalProfileId'] as int,
    name: json['name'] as String,
    introduction: json['introduction'] as String,
    contactDetails: json['contactDetails'] as String,
    experience: json['experience'] as String,
    serviceCategories: [
      for (final category in json['serviceCategories'] as List)
        CategoryRef.fromJson(category as Map<String, dynamic>),
    ],
    address: json['address'] as String,
    serviceRadiusKm: json['serviceRadiusKm'] as int,
    averageRating: (json['averageRating'] as num?)?.toDouble(),
    reviewCount: json['reviewCount'] as int,
  );

  final int professionalProfileId;
  final String name;
  final String introduction;
  final String contactDetails;
  final String experience;
  final List<CategoryRef> serviceCategories;
  final String address;
  final int serviceRadiusKm;

  /// Classificação média; `null` enquanto não houver avaliações.
  final double? averageRating;
  final int reviewCount;
}

/// Avaliação de um serviço realizado, na lista das avaliações de um Prestador
/// (E15).
class Review {
  const Review({
    required this.reviewId,
    required this.rating,
    required this.comment,
    required this.clientName,
    required this.creationDate,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    reviewId: json['reviewId'] as int,
    rating: json['rating'] as int,
    comment: json['comment'] as String?,
    clientName: json['clientName'] as String,
    creationDate: json['creationDate'] as String,
  );

  final int reviewId;
  final int rating;
  final String? comment;
  final String clientName;
  final String creationDate;
}

/// Parâmetros das avaliações de um Prestador (E15); com `pageSize` `null`, a
/// API usa o tamanho por omissão.
typedef ReviewsParams = ({int professionalProfileId, int page, int? pageSize});

/// Corpo da criação (E12) e da edição (E14) do perfil profissional.
class ProfileInput {
  const ProfileInput({
    required this.introduction,
    required this.contactDetails,
    required this.experience,
    required this.serviceCategoryIds,
    required this.address,
    required this.serviceRadiusKm,
  });

  final String introduction;
  final String contactDetails;
  final String experience;
  final List<int> serviceCategoryIds;
  final String address;
  final int serviceRadiusKm;

  Map<String, Object?> toJson() => {
    'introduction': introduction,
    'contactDetails': contactDetails,
    'experience': experience,
    'serviceCategoryIds': serviceCategoryIds,
    'address': address,
    'serviceRadiusKm': serviceRadiusKm,
  };
}

/// Prestador resumido nas solicitações diretas e nas propostas de um serviço.
class ProviderRef {
  const ProviderRef({
    required this.professionalProfileId,
    required this.name,
    required this.averageRating,
    required this.reviewCount,
  });

  factory ProviderRef.fromJson(Map<String, dynamic> json) => ProviderRef(
    professionalProfileId: json['professionalProfileId'] as int,
    name: json['name'] as String,
    averageRating: (json['averageRating'] as num?)?.toDouble(),
    reviewCount: json['reviewCount'] as int,
  );

  final int professionalProfileId;
  final String name;
  final double? averageRating;
  final int reviewCount;
}

/// Prestador na pesquisa, com a distância à localização de referência
/// e se esta fica dentro do raio de atuação.
class ProviderSearchItem {
  const ProviderSearchItem({
    required this.professionalProfileId,
    required this.name,
    required this.serviceCategories,
    required this.averageRating,
    required this.reviewCount,
    required this.distanceKm,
    required this.serviceRadiusKm,
    required this.withinServiceRadius,
  });

  factory ProviderSearchItem.fromJson(Map<String, dynamic> json) =>
      ProviderSearchItem(
        professionalProfileId: json['professionalProfileId'] as int,
        name: json['name'] as String,
        serviceCategories: [
          for (final category in json['serviceCategories'] as List)
            CategoryRef.fromJson(category as Map<String, dynamic>),
        ],
        averageRating: (json['averageRating'] as num?)?.toDouble(),
        reviewCount: json['reviewCount'] as int,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        serviceRadiusKm: json['serviceRadiusKm'] as int,
        withinServiceRadius: json['withinServiceRadius'] as bool,
      );

  final int professionalProfileId;
  final String name;
  final List<CategoryRef> serviceCategories;
  final double? averageRating;
  final int reviewCount;
  final double distanceKm;
  final int serviceRadiusKm;
  final bool withinServiceRadius;
}

/// Parâmetros da pesquisa de Prestadores; sem [address], o backend usa a
/// localização registada do Cliente autenticado.
typedef SearchProvidersParams = ({
  int serviceCategoryId,
  String? address,
  String? name,
  int page,
});
