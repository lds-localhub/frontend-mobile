/// Morada correspondente à posição do dispositivo (E35).
class ReverseGeocodingResult {
  const ReverseGeocodingResult({required this.address});

  factory ReverseGeocodingResult.fromJson(Map<String, dynamic> json) =>
      ReverseGeocodingResult(address: json['address'] as String);

  final String address;
}

/// Corpo da definição da localização do Cliente (E16).
class LocationInput {
  const LocationInput({required this.address});

  final String address;

  Map<String, Object?> toJson() => {'address': address};
}
