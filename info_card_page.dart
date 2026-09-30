import 'dart:convert';
import 'package:birdhitting_app/models/location_model.dart';
import 'package:birdhitting_app/models/phase_model.dart';
import 'package:birdhitting_app/models/weatherConditions_model.dart';
import 'package:http/http.dart' as http;
import 'package:birdhitting_app/models/bird_strike_model.dart';
import 'package:birdhitting_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:birdhitting_app/pages/home_page.dart';
import 'package:birdhitting_app/pages/pakistan_map_page.dart';
import 'package:birdhitting_app/pages/login_page.dart';

class InfoCardPage extends StatefulWidget {
  const InfoCardPage({super.key});

  @override
  State<InfoCardPage> createState() => _InfoCardPageState();
}

//new code
class _InfoCardPageState extends State<InfoCardPage> {
  List<BirdStrikeModel> birdStrikes = [];
  List<BirdStrikeModel> allBirdStrikes = [];
  List<LocationModel> locations = [];
  List<WeatherConditionModel> weatherConditions = [];
  List<PhaseOfFlightModel> phaseOfFlight = [];

  BirdStrikeModel? selectedBird;
  bool isLoading = true;

  DateTime? fromDate;
  DateTime? toDate;

  String? airportCode;
  String? selectedLocation;

  @override
  void initState() {
    super.initState();
    loadBirdStrikes();
    //  loadPhaseOfFlight();
  }

  void resetFilters() {
    setState(() {
      fromDate = null;
      toDate = null;
      selectedLocation = null;
      birdStrikes = List.from(allBirdStrikes);
    });
  }

  // ================= LOAD DATA =================
  Future<void> loadBirdStrikes() async {
    try {
      final data = await ApiService.getBirdStrikes();

      if (!mounted) return;

      setState(() {
        birdStrikes = data;
        allBirdStrikes = data;
        isLoading = false;
        allBirdStrikes = List.from(data);
        birdStrikes = List.from(data);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      debugPrint("Error loading data: $e");
    }
  }

  // new code
  Future<void> loadLocations() async {
    try {
      locations = await ApiService.getLocations();

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String getAerodromeName(String airportCode) {
    try {
      final location = locations.firstWhere((e) => e.id == airportCode);

      return location.airportName;
    } catch (e) {
      return airportCode;
    }
  }

  // WEATHER CONDITIONS
  Future<void> loadWeatherConditions() async {
    try {
      weatherConditions = await ApiService.getWeatherConditions();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  String getWeatherName(dynamic id) {
    if (id == null) return "";

    for (var weather in weatherConditions) {
      if (weather.id == id) {
        return weather.weatherCondition ?? "";
      }
    }
    return "";
  }

  // ================= SEARCH API =================//
  Future<void> searchBirdStrikes() async {
    try {
      final uri = Uri.parse(
        "http://localhost:5046/api/BirdStrike/search"
        "?FromDate=${fromDate?.toIso8601String() ?? ""}"
        "&ToDate=${toDate?.toIso8601String() ?? ""}"
        "&Location=${airportCode ?? ""}",
      );

      final response = await http.get(uri);
      // debugPrint("URI = $uri");
      // debugPrint(response.body);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          birdStrikes = data.map((e) => BirdStrikeModel.fromJson(e)).toList();

          selectedBird = null;
          isLoading = false;
        });
      } else {
        throw Exception("API Error");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Search error: $e");
    }
  }

  // ================= DATE PICKER =================
  Future<void> pickDate(bool isFrom) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // ================= LOCATIONS =================//

  Future<void> showLocations() async {
    if (!mounted) return;
    final ctx = context;

    try {
      final apiLocations = await ApiService.getLocations();

      final locations = [
        LocationModel(
          id: '',
          airportName: "See All Locations",
          latitude: 0,
          longitude: 0,
        ),
        ...apiLocations.where((x) => x.airportName != "See All Locations"),
      ];

      if (!mounted) return;

      showGeneralDialog(
        context: ctx,
        barrierDismissible: true,
        barrierLabel: "Location",
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (dialogCtx, a, b) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(ctx).size.width * 0.85,
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.location_on, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "Select Location",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final location = locations[index];

                          return ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: Colors.blue,
                            ),

                            title: Text(
                              location.airportName,
                              style: const TextStyle(fontSize: 16),
                            ),

                            onTap: () {
                              setState(() {
                                selectedLocation = location.airportName;

                                if (location.airportName ==
                                    "See All Locations") {
                                  // show all cards
                                  airportCode = null;
                                } else {
                                  airportCode = location.airportName; // id
                                }
                              });

                              Navigator.pop(dialogCtx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint(e.toString());

      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text("Failed to load locations")));
    }
  }

  // ================= LIST LOGIC =================//
  List<BirdStrikeModel> get displayList {
    return birdStrikes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 245, 243),
      //new code
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 70, 145, 21),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
        ),

        title: const Text(
          "Bird Strike Information",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
        ),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == "home") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              } else if (value == "dashboard") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PakistanMapPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: "home",
                child: Row(
                  children: [
                    Icon(Icons.home, color: Colors.black),
                    SizedBox(width: 10),
                    Text("Home"),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: "dashboard",
                child: Row(
                  children: [
                    Icon(Icons.dashboard, color: Colors.black),
                    SizedBox(width: 10),
                    Text("Dashboard"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      //new code
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ================= FILTERS (UI SAME) =================
            customFilterButton(
              fromDate == null ? "From" : formatDate(fromDate),
              Icons.calendar_today_rounded,
              () => pickDate(true),
              isActive: fromDate != null,
            ),
            const SizedBox(height: 10),

            customFilterButton(
              toDate == null ? "To" : formatDate(toDate),
              Icons.calendar_month_rounded,
              () => pickDate(false),
              isActive: toDate != null,
            ),
            const SizedBox(height: 10),

            customFilterButton(
              selectedLocation ?? "Location",
              Icons.location_on_rounded,
              showLocations,
              isActive: selectedLocation != null,
            ),
            const SizedBox(height: 10),

            // ================= DASHBOARD + SEARCH + RESET BUTTON =================
            Row(
              children: [
                Expanded(
                  child: customFilterButton(
                    "Search",
                    Icons.search,
                    searchBirdStrikes,
                    isActive: true,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: customFilterButton(
                    "Reset",
                    Icons.refresh,
                    resetFilters,
                    isActive: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ================= LOADING =================
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (displayList.isEmpty)
              const Center(child: Text("Data Not Found"))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final bird = displayList[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 35, 41, 49),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            "Incident Detail ID: ${bird.id}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              infoTile(
                                "Aerodrome of Incident",
                                getAerodromeName(bird.airportName),
                              ),
                              infoTile("Operator", bird.operatorName),
                              infoTile("Aircraft Type", bird.aircraftType),
                              infoTile("Category", bird.aircraftCategory),

                              infoTile(
                                "Weather Condition",
                                bird.weather ?? "No Weather",
                              ),
                              infoTile("Date", bird.incidentDate.toString()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget customFilterButton(
    String text,
    IconData icon,
    VoidCallback onPressed, {
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromARGB(255, 70, 145, 21)
              : const Color.fromARGB(255, 252, 253, 253),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive
                  ? Colors.white
                  : const Color.fromARGB(255, 20, 20, 20),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isActive
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(255, 7, 7, 7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold, // Label Bold
                fontSize: 14,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value ?? "-",
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal, // Value Normal
              ),
            ),
          ),
        ],
      ),
    );
  }
}
