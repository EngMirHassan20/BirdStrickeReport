class BirdStrikeModel {
  final int id;
  final String airportName;
  final String operatorName;
  final String aircraftRegNo;
  final String aircraftType;
  final String aircraftCategory;
  final String flightNo;
  final String flightFrom;
  final String flightTo;
  final DateTime incidentDate;
  final String incidentTime;
  final String incidentDayTime;
  final String? weather;
  final String runmayUsed;
  final String groundLocation;
  final String height;
  final String speed;
  final String phase;
  final String reportedOnRT;
  final String incidentLocation;
  final String effectOnFlight;
  final String damageConfirmation;
  final String incidentSpecies;
  final String incidentSeen;
  final String incidentStruck;
  final String incidentSize;
  final String pilotWarning;
  final String partsOfAircraftEffected;
  final String delay;
  final String remarks;
  final String reportedByEmail;
  final String isImage;

  BirdStrikeModel({
    required this.id,
    required this.airportName,
    required this.operatorName,
    required this.aircraftRegNo,
    required this.aircraftType,
    required this.aircraftCategory,
    required this.flightNo,
    required this.flightFrom,
    required this.flightTo,
    required this.incidentDate,
    required this.incidentTime,
    required this.incidentDayTime,
    required this.weather,
    required this.runmayUsed,
    required this.groundLocation,
    required this.height,
    required this.speed,
    required this.phase,
    required this.reportedOnRT,
    required this.incidentLocation,
    required this.effectOnFlight,
    required this.damageConfirmation,
    required this.incidentSpecies,
    required this.incidentSeen,
    required this.incidentStruck,
    required this.incidentSize,
    required this.pilotWarning,
    required this.partsOfAircraftEffected,
    required this.delay,
    required this.remarks,
    required this.reportedByEmail,
    required this.isImage,
  });

  factory BirdStrikeModel.fromJson(Map<String, dynamic> json) {
    return BirdStrikeModel(
      id: json["id"] ?? 0,
      airportName: json["airportName"] ?? "",
      operatorName: json["operatorName"] ?? "",
      aircraftRegNo: json["aircraftRegNo"] ?? "",
      aircraftType: json["aircraftType"] ?? "",
      aircraftCategory: json["aircraftCategory"] ?? "",
      flightNo: json["flightNo"] ?? "",
      flightFrom: json["flightFrom"] ?? "",
      flightTo: json["flightTo"] ?? "",
      incidentDate: DateTime.parse(json["incidentDate"]),
      incidentTime: json["incidentTime"] ?? "",
      incidentDayTime: json["incidentDayTime"] ?? "",
      weather: json["weather"]?.toString(),
      runmayUsed: json["runwayUsed"] ?? "",
      groundLocation: json["groungLocation"] ?? "",
      height: json["height"] ?? "",
      speed: json["speed"] ?? "",
      phase: json["phase"] ?? "",
      reportedOnRT: json["reportedOnRT"] ?? "",
      incidentLocation: json["incidentLocation"] ?? "",
      effectOnFlight: json["effectOnFlight"] ?? "",
      damageConfirmation: json["damageConfirmation"] ?? "",
      incidentSpecies: json["incidentSpecies"] ?? "",
      incidentSeen: json["incidentSeen"] ?? "",
      incidentStruck: json["incidentStruck"] ?? "",
      incidentSize: json["incidentSize"] ?? "",
      pilotWarning: json["pilotWarning"] ?? "",
      partsOfAircraftEffected: json["partsOfAircraftEffected"] ?? "",
      delay: json["delay"] ?? "",
      remarks: json["remarks"] ?? "",
      reportedByEmail: json["reportedByEmail"] ?? "",
      isImage: json["isImage"] ?? "",
    );
  }
}
