class WeatherConditionModel {
  final int id;
  final String? weatherCondition;

  WeatherConditionModel({required this.id, this.weatherCondition});

  factory WeatherConditionModel.fromJson(Map<String, dynamic> json) {
    return WeatherConditionModel(
      id: json["id"] ?? 0,
      weatherCondition: json["weather"]?.toString(),
    );
  }
}
