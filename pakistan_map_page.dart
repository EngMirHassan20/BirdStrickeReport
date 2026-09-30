import 'package:birdhitting_app/models/location_model.dart';
import 'package:birdhitting_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bird_strike_model.dart';

class PakistanMapPage extends StatefulWidget {
  const PakistanMapPage({super.key});

  @override
  State<PakistanMapPage> createState() => _PakistanMapPageState();
}

class _PakistanMapPageState extends State<PakistanMapPage> {
  List<BirdStrikeModel> birdStrikes = [];
  List<LocationModel> locations = [];
  List<BirdStrikeModel> selectedAirportBirdStrikes = [];

  bool isLoading = false;
  DateTime? fromDate;
  DateTime? toDate;
  BirdStrikeModel? selectedBirdStrike;
  String? selectedAirportName;
  double selectedLatitude = 0;
  double selectedLongitude = 0;

  @override
  void initState() {
    super.initState();
    loadLocations();
    loadDefaultOneYearData();
  }

  final List<String> mainAirports = [
    "KARACHI",
    "LAHORE",
    "ISLAMABAD INTERNATIONAL AIRPORT",
    "PESHAWAR",
    "QUETTA",
    "MULTAN",
    "FAISALABAD",
    "SIALKOT",
    "SUKKUR",
    "CATI HYDERABAD",
    "GWADAR",
  ];

  Map<String, int> airportStrikeCount = {};
  static const double minLat = 23.5;
  static const double maxLat = 37.1;
  static const double minLng = 60.8;
  static const double maxLng = 77.9;

  double getX(double longitude, double mapWidth) {
    const double imagePadding = 20;

    final usableWidth = mapWidth - (imagePadding * 2);

    return imagePadding +
        ((longitude - minLng) / (maxLng - minLng)) * usableWidth;
  }

  double getY(double latitude, double mapHeight) {
    const double imagePadding = 20;

    final usableHeight = mapHeight - (imagePadding * 2);

    return imagePadding +
        ((maxLat - latitude) / (maxLat - minLat)) * usableHeight;
  }

  void calculateAirportStrikeCount() {
    airportStrikeCount.clear();

    for (var bird in birdStrikes) {
      final airport = bird.airportName.trim();

      if (airport.isEmpty) continue;

      airportStrikeCount[airport] = (airportStrikeCount[airport] ?? 0) + 1;
    }

    debugPrint(airportStrikeCount.toString());
  }

  Future<void> loadLocations() async {
    try {
      final data = await ApiService.getLocations();

      setState(() {
        locations = data;
      });

      debugPrint("Locations Loaded: ${locations.length}");

      for (var l in locations) {
        debugPrint("${l.airportName}  ${l.latitude}  ${l.longitude}");
      }
    } catch (e) {
      debugPrint("Location Error: $e");
    }
  }

  Future<void> loadDefaultOneYearData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final DateTime now = DateTime.now();
      final DateTime oneYearAgo = now.subtract(const Duration(days: 365));

      fromDate = oneYearAgo;
      toDate = now;

      final uri = Uri.parse(
        "http://localhost:5046/api/BirdStrike/search"
        "?FromDate=${fromDate!.toIso8601String()}"
        "&ToDate=${toDate!.toIso8601String()}",
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          birdStrikes = data.map((e) => BirdStrikeModel.fromJson(e)).toList();

          calculateAirportStrikeCount();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return "";

    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> pickDate(bool isFrom) async {
    final DateTime now = DateTime.now();

    DateTime initialDate = isFrom ? (fromDate ?? now) : (toDate ?? now);
    DateTime firstDate = DateTime(2010, 1, 1);
    DateTime lastDate = DateTime(now.year, 12, 31);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        fromDate = picked;
      } else {
        if (fromDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select From Date first.")),
          );
          return;
        }

        if (picked.isBefore(fromDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("To Date cannot be before From Date."),
            ),
          );
          return;
        }
        toDate = picked;
      }
    });
  }

  Widget airportBox(int count) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        "$count",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Future<void> searchData() async {
    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select From Date and To Date")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final uri = Uri.parse(
        "http://localhost:5046/api/BirdStrike/search"
        "?FromDate=${fromDate!.toIso8601String()}"
        "&ToDate=${toDate!.toIso8601String()}",
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          birdStrikes = data.map((e) => BirdStrikeModel.fromJson(e)).toList();

          calculateAirportStrikeCount();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("API Error")));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("Search Error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void resetData() async {
    setState(() {
      fromDate = null;
      toDate = null;
      airportStrikeCount.clear();
    });

    await loadDefaultOneYearData();
  }

  Widget filterButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 8, 143, 8),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Pakistan Bird Strike Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        //SingleChildScrollView
        padding: const EdgeInsets.all(15),
        child: Column(
          //child
          children: [
            Row(
              children: [
                Expanded(
                  child: filterButton(
                    text: fromDate == null ? "From Date" : formatDate(fromDate),
                    icon: Icons.calendar_today,
                    onTap: () => pickDate(true),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: filterButton(
                    text: toDate == null ? "To Date" : formatDate(toDate),
                    icon: Icons.calendar_month,
                    onTap: () => pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: filterButton(
                    text: "Search",
                    icon: Icons.search,
                    color: const Color.fromARGB(255, 23, 141, 27),
                    onTap: searchData,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: filterButton(
                    text: "Reset",
                    icon: Icons.refresh,
                    color: const Color.fromARGB(255, 23, 141, 27),
                    onTap: resetData,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    height: 500,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),

                      border: Border.all(color: Colors.grey),
                    ),
                    // new code
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final mapWidth = constraints.maxWidth;
                        final mapHeight = constraints.maxHeight;

                        return SizedBox(
                          width: mapWidth,
                          height: mapHeight,
                          child: Stack(
                            children: [
                              // Pakistan Map
                              Positioned.fill(
                                child: Image.asset(
                                  "assets/images/pakistanmap8.png",
                                  fit: BoxFit.cover,
                                ),
                              ),

                              // Airport Boxes
                              ...locations
                                  .where(
                                    (location) => mainAirports.contains(
                                      location.airportName.toUpperCase(),
                                    ),
                                  )
                                  .map((location) {
                                    final count =
                                        airportStrikeCount[location
                                            .airportName] ??
                                        0;
                                    // new code
                                    return Positioned(
                                      left:
                                          getX(location.longitude, mapWidth) -
                                          12,
                                      top:
                                          getY(location.latitude, mapHeight) -
                                          12,
                                      child: GestureDetector(
                                        onTap: () {
                                          debugPrint(
                                            "Marker Clicked : ${location.airportName}",
                                          );

                                          final airportData = birdStrikes
                                              .where(
                                                (e) =>
                                                    e.airportName
                                                        .trim()
                                                        .toUpperCase() ==
                                                    location.airportName
                                                        .trim()
                                                        .toUpperCase(),
                                              )
                                              .toList();

                                          debugPrint(
                                            "Records : ${airportData.length}",
                                          );

                                          setState(() {
                                            selectedAirportBirdStrikes =
                                                airportData;

                                            if (airportData.isNotEmpty) {
                                              selectedBirdStrike =
                                                  airportData.first;
                                            }
                                            selectedLatitude =
                                                location.latitude;
                                            selectedLongitude =
                                                location.longitude;
                                          });
                                        },
                                        child: Tooltip(
                                          message:
                                              "${location.airportName}\nBird Strikes: $count",
                                          child: airportBox(count),
                                        ),
                                      ),
                                    );
                                    // new code
                                  })
                                  .toList(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 15),
            if (selectedBirdStrike != null) buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryCard() {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedAirportBirdStrikes.length,
              itemBuilder: (context, index) {
                final bird = selectedAirportBirdStrikes[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bird.airportName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const Divider(),
                        //new code
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Operator :     ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${bird.operatorName}"),
                            ],
                          ),
                        ),

                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Aircraft Type :    ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${bird.aircraftType}"),
                            ],
                          ),
                        ),

                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Date :          ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${bird.incidentDate}"),
                            ],
                          ),
                        ),

                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Flight No :    ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${bird.flightNo}"),
                            ],
                          ),
                        ),

                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Flight From :    ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${bird.flightFrom}"),
                            ],
                          ),
                        ),

                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Flight To :    ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${bird.flightTo}"),
                            ],
                          ),
                        ),

                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Weather :    ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${bird.weather}"),
                            ],
                          ),
                        ),

                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Location :    ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${bird.incidentLocation}"),
                            ],
                          ),
                        ),

                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Remarks :    ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "${bird.remarks}"),
                            ],
                          ),
                        ),

                        //new code
                        if (index == selectedAirportBirdStrikes.length - 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  selectedBirdStrike = null;
                                  selectedAirportBirdStrikes.clear();
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
