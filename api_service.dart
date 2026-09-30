import 'dart:convert';
import 'package:birdhitting_app/models/airlines_operator_model.dart';
import 'package:http/http.dart' as http;
import 'package:birdhitting_app/models/phase_model.dart';
import 'package:birdhitting_app/models/bird_strike_model.dart';
import 'package:birdhitting_app/models/location_model.dart';
import 'package:birdhitting_app/models/weatherConditions_model.dart';

class ApiService {
  static const String birdStrikeUrl = "http://localhost:5046/api/BirdStrike";
  static Future<List<BirdStrikeModel>> getBirdStrikes() async {
    final response = await http.get(Uri.parse(birdStrikeUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => BirdStrikeModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load Bird Strike data");
  }

  static const String locationUrl = "http://localhost:5046/api/Locations";

  static Future<List<LocationModel>> getLocations() async {
    final response = await http.get(Uri.parse(locationUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => LocationModel.fromJson(e)).toList();
    }

    throw Exception("Location load failed");
  }

  static const String weatherUrl = "http://localhost:5046/api/WC";

  static Future<List<WeatherConditionModel>> getWeatherConditions() async {
    final response = await http.get(Uri.parse(weatherUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // debugPrint(data.toString());

      return data.map((json) => WeatherConditionModel.fromJson(json)).toList();
    }

    throw Exception("Failed to load weather conditions");
  }

  static const String phaseUrl = "http://localhost:5046/api/Pof";

  static Future<List<PhaseOfFlightModel>> getPhases() async {
    try {
      final response = await http.get(Uri.parse(phaseUrl));
      // print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((json) => PhaseOfFlightModel.fromJson(json)).toList();
      }

      throw Exception(
        "Failed to load phases. Status Code: ${response.statusCode}",
      );
    } catch (e) {
      throw Exception("Error loading phases: $e");
    }
  }

  static Future<bool> submitForm(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5046/api/BirdStrike"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<List<AirlinesOperatorModel>> getAirlinesOperators() async {
    final response = await http.get(
      Uri.parse("http://localhost:5046/api/Airlines_Operator"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data.map((e) => AirlinesOperatorModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Operators");
    }
  }

  static Future<List<String>> getAerodromes() async {
    // call API here
    return ["Karachi", "Lahore", "Islamabad", "Hyderabad", "Jacobabad"];
  }

  static Future<List<String>> getOperators() async {
    return ["PIA", "Airblue", "Serene Air"];
  }

  static Future<List<String>> getAirports() async {
    return ["KHI", "LHE", "ISB", "PEW"];
  }

  static Future<List<String>> getRunways() async {
    return ["RWY 07L", "RWY 25R"];
  }

  static Future<List<String>> getBirdSpecies() async {
    return ["Crow", "Eagle", "Pigeon"];
  }

  static Future<List<String>> getTimeSlots() async {
    return ["08:00", "10:00", "12:00", "14:00"];
  }
}
