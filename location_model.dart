class LocationModel {
  final String id;
  final String airportName;
  final double latitude;
  final double longitude;

  LocationModel({
    required this.id,
    required this.airportName,
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json["id"]?.toString() ?? "",
      airportName: json["airporT_NAME"]?.toString() ?? "",
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
    );
  }
}
