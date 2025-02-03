import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CropSelectionScreen extends StatefulWidget {
  const CropSelectionScreen({super.key});

  @override
  State<CropSelectionScreen> createState() => _CropSelectionScreenState();
}

class _CropSelectionScreenState extends State<CropSelectionScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _soilData;
  List<String>? _suitableCrops;
  Map<String, double>? _confidenceScores;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var status = await Permission.location.request();
      if (status.isDenied) {
        throw Exception('Location permission denied. Enable it in settings.');
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _fetchWeatherData(position.latitude, position.longitude);
      await _fetchSoilData(position.latitude, position.longitude);
      _updateCropSuggestions();
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=d112bb7fbb737d73b1fdf2574fe391eb&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _weatherData = {
            'temperature': data['main']['temp'],
            'humidity': data['main']['humidity'],
            'windSpeed': data['wind']['speed'],
            'description': data['weather'][0]['description'],
            'icon': data['weather'][0]['icon'],
          };
        });
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      setState(() {
        _error = 'Weather Error: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchSoilData(double latitude, double longitude) async {
    try {
      // Simulated soil data based on location
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      // Generate soil moisture based on latitude (just for simulation)
      double soilMoisture = (latitude.abs() % 10) / 20 + 0.2; // Range: 0.2-0.7
      double soilTemp = _weatherData?['temperature'] ?? 25.0;
      soilTemp = soilTemp -
          2; // Soil temperature is usually slightly lower than air temperature

      setState(() {
        _soilData = {
          'soilMoisture': soilMoisture,
          'soilTemperature': soilTemp,
          'pH': 6.5 + (longitude % 2), // pH between 6.5 and 8.5
          'type': _determineSoilType(soilMoisture),
        };
      });
    } catch (e) {
      setState(() {
        _error = 'Soil Data Error: ${e.toString()}';
      });
    }
  }

  String _determineSoilType(double moisture) {
    // Soil types based on region and moisture content
    Map<String, Map<String, double>> soilCharacteristics = {
      'Sandy': {'moisture_min': 0.0, 'moisture_max': 0.2},
      'Sandy Loam': {'moisture_min': 0.2, 'moisture_max': 0.3},
      'Loamy': {'moisture_min': 0.3, 'moisture_max': 0.4},
      'Clay Loam': {'moisture_min': 0.4, 'moisture_max': 0.5},
      'Clay': {'moisture_min': 0.5, 'moisture_max': 0.6},
      'Silty Clay': {'moisture_min': 0.6, 'moisture_max': 1.0},
    };

    // Find the soil type based on moisture content
    for (var entry in soilCharacteristics.entries) {
      if (moisture >= entry.value['moisture_min']! &&
          moisture < entry.value['moisture_max']!) {
        return entry.key;
      }
    }

    return 'Unknown'; // Default case
  }

  List<String> _getSuitableCrops(String soilType) {
    return {
          'Sandy': ['Carrots', 'Potatoes', 'Peanuts', 'Watermelon', 'Radishes'],
          'Sandy Loam': [
            'Sweet Potatoes',
            'Beans',
            'Lettuce',
            'Strawberries',
            'Peppers'
          ],
          'Loamy': ['Corn', 'Tomatoes', 'Soybeans', 'Cotton', 'Wheat'],
          'Clay Loam': ['Sunflowers', 'Sorghum', 'Switchgrass', 'Beans'],
          'Clay': ['Rice', 'Wheat', 'Cabbage', 'Broccoli', 'Cauliflower'],
          'Silty Clay': ['Leafy Greens', 'Rice', 'Wetland Crops', 'Bamboo'],
        }[soilType] ??
        ['Tomatoes', 'Beans', 'Lettuce']; // Default crops for unknown soil
  }

  void _updateCropSuggestions() {
    if (_soilData == null || _weatherData == null) return;

    String soilType = _soilData!['type'];
    List<String> possibleCrops = _getSuitableCrops(soilType);
    Map<String, double> scores = {};

    for (String crop in possibleCrops) {
      double score = 0.0;
      double tempC = _weatherData!['temperature'];
      double humidity = _weatherData!['humidity'];
      double soilMoisture = _soilData!['soilMoisture'];

      // Temperature scoring (0-40 points)
      if (tempC >= 15 && tempC <= 25)
        score += 40;
      else if (tempC >= 10 && tempC <= 30)
        score += 20;
      else if (tempC >= 5 && tempC <= 35) score += 10;

      // Humidity scoring (0-30 points)
      if (humidity >= 40 && humidity <= 70)
        score += 30;
      else if (humidity >= 30 && humidity <= 80)
        score += 15;
      else if (humidity >= 20 && humidity <= 90) score += 5;

      // Soil moisture scoring (0-30 points)
      if (soilMoisture >= 0.2 && soilMoisture <= 0.4)
        score += 30;
      else if (soilMoisture >= 0.1 && soilMoisture <= 0.5)
        score += 15;
      else if (soilMoisture >= 0.05 && soilMoisture <= 0.6) score += 5;

      scores[crop] = score;
    }

    var sortedCrops = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _suitableCrops = sortedCrops.take(3).map((e) => e.key).toList();
      _confidenceScores = Map.fromEntries(sortedCrops.take(3));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Crop Selection',
          style: GoogleFonts.cuteFont(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing conditions...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_weatherData != null) _buildWeatherCard(),
                        SizedBox(height: 16),
                        if (_soilData != null) _buildSoilCard(),
                        SizedBox(height: 24),
                        if (_suitableCrops != null) _buildCropSuggestions(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWeatherCard() {
    String getWeatherDescription(String code) {
      return _weatherData!['description']
          .toString()
          .split(' ')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weather Conditions',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                    'https://openweathermap.org/img/wn/${_weatherData!['icon']}@2x.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              getWeatherDescription(_weatherData!['description']),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _weatherInfoRow(
                  Icons.thermostat,
                  '${_weatherData!['temperature'].toStringAsFixed(1)}°C',
                ),
                SizedBox(height: 8),
                _weatherInfoRow(
                  Icons.water_drop,
                  '${_weatherData!['humidity']}% Humidity',
                ),
                SizedBox(height: 8),
                _weatherInfoRow(
                  Icons.air,
                  '${_weatherData!['windSpeed']} m/s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown[400]!, Colors.brown[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soil Conditions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            _soilInfoRow(
              Icons.water,
              'Moisture',
              '${(_soilData!['soilMoisture'] * 100).toStringAsFixed(1)}%',
            ),
            SizedBox(height: 8),
            _soilInfoRow(
              Icons.thermostat,
              'Temperature',
              '${_soilData!['soilTemperature'].toStringAsFixed(1)}°C',
            ),
            SizedBox(height: 8),
            _soilInfoRow(
              Icons.landscape,
              'Soil Type',
              _soilData!['type'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropSuggestions() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Crops',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 16),
            ..._suitableCrops!.map((crop) {
              double confidence = _confidenceScores![crop] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.eco, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crop,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          LinearProgressIndicator(
                            value: confidence / 100,
                            backgroundColor: Colors.grey[200],
                            color: Colors.green,
                          ),
                          Text(
                            '${confidence.toStringAsFixed(0)}% Match',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _weatherInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _soilInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
