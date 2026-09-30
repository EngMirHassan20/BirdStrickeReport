// class PhaseOfFlightModel {
//   final int id;
//   final String? phaseOfFlight;

//   PhaseOfFlightModel({required this.id, this.phaseOfFlight});

//   factory PhaseOfFlightModel.fromJson(Map<String, dynamic> json) {
//     return PhaseOfFlightModel(
//       id: json["id"] ?? 0,
//       phaseOfFlight: json["phaseName"]?.toString(),
//     );
//   }
// }

// class PhaseOfFlightModel {
//   int? id;
//   String? phaseName;

//   PhaseOfFlightModel({this.id, this.phaseName});

//   factory PhaseOfFlightModel.fromJson(Map<String, dynamic> json) {
//     return PhaseOfFlightModel(id: json["id"], phaseName: json["phaseName"]);
//   }
// }

class PhaseOfFlightModel {
  int? id;
  String? phaseOfFlight;

  PhaseOfFlightModel({this.id, this.phaseOfFlight});

  factory PhaseOfFlightModel.fromJson(Map<String, dynamic> json) {
    return PhaseOfFlightModel(
      id: json["id"],
      phaseOfFlight: json["phaseName"], // API field
    );
  }
}
