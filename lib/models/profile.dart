import 'package:localhub/models/category.dart';

/// Perfil profissional de um Prestador.
class Profile {
  const Profile({
    required this.professionalProfileId,
    required this.name,
    required this.introduction,
    required this.contactDetails,
    required this.experience,
    required this.address,
    required this.serviceRadiusKm,
    required this.averageRating,
    required this.reviewCount,
    required this.serviceCategories,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    professionalProfileId: json['professionalProfileId'] as int,
    name: json['name'] as String,
    introduction: json['introduction'] as String,
    contactDetails: json['contactDetails'] as String,
    experience: json['experience'] as String,
    address: json['address'] as String,
    serviceRadiusKm: json['serviceRadiusKm'] as int,
    averageRating: (json['averageRating'] as num?)?.toDouble(),
    reviewCount: json['reviewCount'] as int,
    serviceCategories: [
      for (final c in json['serviceCategories'] as List)
        CategoryRef.fromJson(c as Map<String, dynamic>),
    ],
  );

  final int professionalProfileId;
  final String name;
  final String introduction;
  final String contactDetails;
  final String experience;
  final String address;
  final int serviceRadiusKm;
  final double? averageRating;
  final int reviewCount;
  final List<CategoryRef> serviceCategories;
}

/// Corpo da criação e da edição do perfil profissional.
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
