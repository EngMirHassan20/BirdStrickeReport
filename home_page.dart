import 'package:birdhitting_app/models/airlines_operator_model.dart';
import 'package:birdhitting_app/pages/info_card_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:birdhitting_app/services/api_service.dart';
import 'package:birdhitting_app/models/bird_strike_model.dart';
import 'package:birdhitting_app/models/location_model.dart';
import 'package:birdhitting_app/models/weatherConditions_model.dart';
import 'package:birdhitting_app/models/phase_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: BirdStrikeForm());
  }
}

List<BirdStrikeModel> birdStrikes = [];
bool isLoading = true;

// ================= FORM PAGE =================

class BirdStrikeForm extends StatefulWidget {
  const BirdStrikeForm({super.key});

  @override
  State<BirdStrikeForm> createState() => _BirdStrikeFormState();
}

class _BirdStrikeFormState extends State<BirdStrikeForm> {
  final _formKey = GlobalKey<FormState>();

  // ================= MODEL LISTS =================
  List<BirdStrikeModel> birds = [];
  List<LocationModel> locations = [];
  List<PhaseOfFlightModel> phasesModels = [];
  List<WeatherConditionModel> weatherConditions = [];
  List<AirlinesOperatorModel> operators = [];

  // ================= STRING LISTS =================
  List<String> aerodromeList = [];
  List<String> weatherList = [];
  List<String> operatorList = [];
  List<String> airports = [];
  List<String> runways = [];
  List<String> phaseList = [];
  List<String> birdSpeciesList = [];
  List<String> timeSlots = [];
  bool isLoading = true;

  // ================= SELECTED VALUES =================
  String? selectedLocation;
  String? selectedWeather;
  String? selectedPhase;
  String? operatorName;
  String? fromAirport;
  String? toAirport;

  // VARIABLES
  String? aerodrome,
      operator,
      aircraftType,
      weather,
      runway,
      phase,
      birdSpecies,
      location,
      cautionBirds,
      delay,
      aircraftCategory,
      utcTime;

  String effect = "None";
  String verification = "Suspected";
  String birdsSeen = "1";
  String birdsStruck = "1";
  String birdSize = "Small";

  bool reported = false;
  String? selectedFileName;

  // CONTROLLERS
  final phaseNameController = TextEditingController();
  final aerodromeNameController = TextEditingController();
  final aircraftRegController = TextEditingController();
  final callSignController = TextEditingController();
  final dateController = TextEditingController();
  final heightController = TextEditingController();
  final speedController = TextEditingController();
  final affectedPartsController = TextEditingController();
  final remarksController = TextEditingController();
  final reporterEmailController = TextEditingController();

  // ================= INIT STATE =================

  @override
  void initState() {
    super.initState();
    loadBirdStrikes();
    loadWeatherConditions();
    loadLocations();
    loadPhases();
    loadOperators();
  }

  Future<void> loadBirdStrikes() async {
    try {
      birdStrikes = await ApiService.getBirdStrikes();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  // Load Location Code
  Future<void> loadLocations() async {
    try {
      final data = await ApiService.getLocations();

      if (!mounted) return;

      setState(() {
        locations = data;

        aerodromeList = data.map((e) => e.airportName).toList();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Load Weather Condition
  Future<void> loadWeatherConditions() async {
    try {
      final List<WeatherConditionModel> data =
          await ApiService.getWeatherConditions();

      if (!mounted) return;

      setState(() {
        weatherConditions = data;
        weatherList = data.map((e) => e.weatherCondition ?? "").toList();
      });
    } catch (e) {
      print(e);
    }
  }

  // Load Phase Code
  Future<void> loadPhases() async {
    try {
      final List<PhaseOfFlightModel> data = await ApiService.getPhases();

      if (!mounted) return;

      setState(() {
        phasesModels = data;

        phaseList = data
            .map((e) => e.phaseOfFlight ?? "") //phaseOfFlight
            .where((e) => e.isNotEmpty)
            .toList();
      });

      //  debugPrint("Phase List: $phaseList");
    } catch (e) {
      //  debugPrint("Phase Error: $e");
    }
  }

  // Opreators
  Future<void> loadOperators() async {
    try {
      operators = await ApiService.getAirlinesOperators();

      operatorList = operators
          .map((e) => e.operatorName.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  // ================= MASTER LOAD DATA FUNCTION =================

  Future<void> loadAllFormData() async {
    try {
      final results = await Future.wait([
        ApiService.getBirdStrikes(),
        ApiService.getLocations(),
        ApiService.getWeatherConditions(),
        ApiService.getPhases(),
        ApiService.getAerodromes(),
        ApiService.getOperators(),
        ApiService.getAirports(),
        ApiService.getRunways(),
        ApiService.getBirdSpecies(),
        ApiService.getTimeSlots(),
      ]);

      if (!mounted) return;

      // debugPrint(results[2].toString());
      // debugPrint(weatherConditions.toString());
      // debugPrint(weatherList.toString());

      setState(() {
        birds = results[0] as List<BirdStrikeModel>;
        locations = results[1] as List<LocationModel>;
        weatherConditions = results[2] as List<WeatherConditionModel>;
        phasesModels = results[3] as List<PhaseOfFlightModel>;

        aerodromeList = results[4] as List<String>;
        operators = results[5] as List<AirlinesOperatorModel>;

        airports = results[6] as List<String>;
        runways = results[7] as List<String>;
        birdSpeciesList = results[8] as List<String>;
        timeSlots = AntiquityExtractList(results[9]);

        weatherList = weatherConditions
            .map((e) => (e.weatherCondition ?? "").trim())
            .where((e) => e.isNotEmpty)
            .toSet() // duplicate values bhi hata dega
            .toList();

        phaseList = phasesModels
            .map((e) => (e.phaseOfFlight ?? "").trim()) //phaseOfFlight
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();

        operatorList = operators
            .map((e) => (e.operatorName).trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint("Master Data Extraction Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to completely bind dropdown data structures: $e",
          ),
        ),
      );
    }
  }

  List<String> AntiquityExtractList(dynamic output) {
    if (output is List<String>) return output;
    return [];
  }

  // DATE PICKER
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 74, 151, 22),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const InfoCardPage()),
            );
          },
        ),

        title: const Text(
          "Bird Strike Form",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Image.asset("../android/assets/paalogo.png", height: 120),
                    const SizedBox(height: 10),

                    _buildHeader(),

                    // Aerodrome
                    dropdownField(
                      "Aerodrome of Incident",
                      aerodromeList,
                      (v) => setState(() {
                        aerodrome = v;
                      }),
                    ),

                    // OPERATOR
                    dropdownField("Operator Name", operatorList, (v) {
                      setState(() {
                        operatorName = v;
                      });
                    }),
                    // AIRCRAFT REG
                    textField(
                      "AircraftRegNo.",
                      controller: aircraftRegController,
                    ),

                    // AIRCRAFT TYPE
                    textField(
                      "Aircraft Type",
                      onChanged: (v) => aircraftType = v,
                    ),

                    // CATEGORY
                    dropdownField("Aircraft Category", [
                      "Passenger",
                      "Cargo",
                      "Private",
                      "Fighter",
                    ], (v) => aircraftCategory = v),

                    // CALL SIGN
                    textField("Call Sign", controller: callSignController),

                    // FROM
                    dropdownField(
                      "From",
                      locations.map((e) => e.airportName).toList(),
                      (v) => fromAirport = v,
                    ),

                    // TO
                    dropdownField(
                      "To",
                      locations.map((e) => e.airportName).toList(),
                      (v) => toAirport = v,
                    ),

                    // DATE
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: TextFormField(
                        controller: dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: const InputDecoration(
                          labelText: "Date of Incident",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Select Date";
                          }
                          return null;
                        },
                      ),
                    ),

                    // UTC TIME
                    dropdownField("UTC Time of Incident", [
                      "Dawn",
                      "Day",
                      "Dusk",
                      "Night",
                    ], (v) => utcTime = v),

                    // Weather Condition
                    dropdownField(
                      "Weather Condition",
                      weatherList,
                      (v) => setState(() {
                        weather = v;
                      }),
                    ),

                    // RUNWAY
                    dropdownField("Runway Used", [
                      "RWY 07L",
                      "RWY 07R",
                      "RWY 25L",
                    ], (v) => runway = v),

                    // HEIGHT
                    textField("Height ", controller: heightController),

                    // SPEED
                    textField("Speed ", controller: speedController),

                    dropdownField("Phase of Flight", phaseList, (v) {
                      setState(() {
                        phase = v;
                      });
                    }),

                    // REPORTED
                    _reportedSection(),

                    // LOCATION
                    _locationSection(),

                    // EFFECT
                    _effectSection(),

                    // VERIFICATION
                    _verificationSection(),

                    // BIRD SPECIES
                    dropdownField("Bird / Animal Species", [
                      "Crow",
                      "Eagle",
                      "Pigeon",
                      "Dog",
                    ], (v) => birdSpecies = v),

                    // BIRDS SEEN
                    _radioGroup(
                      "BIRDS SEEN:",
                      ["1", "2-10", "11-100", "unknown"],
                      birdsSeen,
                      (v) => setState(() => birdsSeen = v!),
                    ),

                    // BIRDS STRUCK
                    _radioGroup(
                      "BIRDS STRUCK:",
                      ["1", "2-10", "11-100", "unknown"],
                      birdsStruck,
                      (v) => setState(() => birdsStruck = v!),
                    ),

                    // BIRD SIZE
                    _radioGroup(
                      "BIRDS SIZE:",
                      ["Small", "Medium", "Large"],
                      birdSize,
                      (v) => setState(() => birdSize = v!),
                    ),

                    // CAUTION
                    buildRadio(
                      "25. CAUTION:",
                      ["Yes", "No"],
                      cautionBirds,
                      (v) => setState(() => cautionBirds = v),
                    ),

                    // PARTS AFFECTED
                    textField(
                      "26. PART(S) OF AIRCRAFT AFFECTED",
                      controller: affectedPartsController,
                    ),

                    // DELAY
                    buildRadio(
                      "27. DELAY:",
                      ["Yes", "No"],
                      delay,
                      (v) => setState(() => delay = v),
                    ),

                    // REMARKS
                    textField(
                      "Remarks",
                      controller: remarksController,
                      maxLines: 4,
                    ),

                    // EMAIL
                    textField(
                      "Reported By(Operator's Email)",
                      controller: reporterEmailController,
                    ),

                    const SizedBox(height: 10),

                    // FILE PICKER
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles();

                            if (result != null) {
                              setState(() {
                                selectedFileName = result.files.single.name;
                              });
                            }
                          },
                          icon: const Icon(Icons.attach_file),
                          label: const Text("Choose File"),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(selectedFileName ?? "No file selected"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // SUBMIT
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              Map<String, dynamic> data = {
                                "AirportName": aerodrome,

                                "OperatorName": operatorName,

                                "AircraftRegNo": aircraftRegController.text,

                                "AircraftType": aircraftType,

                                "AircraftCategory": aircraftCategory,

                                "FlightNo": callSignController.text,
                                "FlightFrom": fromAirport,
                                "FlightTo": toAirport,

                                "IncidentDate": DateTime.now().toString(),
                                "IncidentTime": utcTime,

                                "Weather": weather,

                                "RunwayUsed": runway,

                                "GroundLocatoin": location,

                                "Height": heightController.text,

                                "Speed": speedController.text,

                                "Phase": phase,

                                "ReportedOnRT": reported.toString(),

                                //   "Location": location,
                                "IncidentLocation": location,

                                "EffectOnFlight": effect,

                                "DamageConfirmation": verification,

                                "IncidentSpecies": birdSpecies,
                                "IncidentSeen": birdsSeen,
                                "IncidentStruck": birdsStruck,
                                "IncidentSize": birdSize,

                                "PilotWarning": cautionBirds,
                                "PartsOfAircraftEffected":
                                    affectedPartsController.text,

                                "Delay": delay,
                                "Remarks": remarksController.text,
                                "ReportedByEmail": reporterEmailController.text,
                                "IsImage": selectedFileName != null ? "Y" : "N",
                                "Del": "N",
                                "ActiveYN": "Y",
                              };

                              // API CALL
                              bool success = await ApiService.submitForm(data);

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Submitted Successfully"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("API Failed")),
                                );
                              }
                            }
                          },
                          child: const Text("Submit"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => const Padding(
    padding: EdgeInsets.all(10),
    child: Column(
      children: [
        Text(
          "PAKISTAN AIRPORT AUTHORITY",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "BIRD STRIKE FORM",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  // REPORTED SECTION
  Widget _reportedSection() => Row(
    children: [
      const Text("Reported ON R/T: "),

      Radio(
        value: true,
        groupValue: reported,
        onChanged: (_) => setState(() => reported = true),
      ),

      const Text("Yes"),

      Radio(
        value: false,
        groupValue: reported,
        onChanged: (_) => setState(() => reported = false),
      ),

      const Text("No"),
    ],
  );

  // LOCATION
  Widget _locationSection() => _radioGroup(
    "LOCATION:",
    ["On Airport", "Off Airport", "Near Airport"],
    location,
    (v) => setState(() => location = v),
  );

  // EFFECT
  Widget _effectSection() => _radioGroup(
    "EFFECT ON FLIGHT:",
    ["None", "Aborted", "Landing"],
    effect,
    (v) => setState(() => effect = v!),
  );

  // VERIFICATION
  Widget _verificationSection() => _radioGroup(
    "VERIFICATION OF INCIDENT:",
    ["Suspected", "Confirmed"],
    verification,
    (v) => setState(() => verification = v!),
  );

  // TEXT FIELD
  Widget textField(
    String label, {
    TextEditingController? controller,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label is required";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // DROPDOWN
  Widget dropdownField(
    String label,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        value: null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Select $label";
          }
          return null;
        },
      ),
    );
  }

  // RADIO GROUP
  Widget _radioGroup(
    String title,
    List<String> options,
    String? groupValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Row(
          children: options.map((e) {
            return Row(
              children: [
                Radio<String>(
                  value: e,
                  groupValue: groupValue,
                  onChanged: onChanged,
                ),
                Text(e),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildRadio(
    String title,
    List<String> options,
    String? groupValue,
    Function(String?) onChanged,
  ) {
    return _radioGroup(title, options, groupValue, onChanged);
  }
}
