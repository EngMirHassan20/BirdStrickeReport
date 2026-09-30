class AirlinesOperatorModel {
  final int id;
  final String operatorName;

  AirlinesOperatorModel({required this.id, required this.operatorName});

  factory AirlinesOperatorModel.fromJson(Map<String, dynamic> json) {
    return AirlinesOperatorModel(
      id: json["airlineOperatorID"] ?? 0,
      operatorName: json["nameOfAirlineOperator"] ?? "",
    );
  }
}
