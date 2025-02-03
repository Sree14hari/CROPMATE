import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants.dart';

class CropSelectionScreen extends StatefulWidget {
  const CropSelectionScreen({super.key});

  @override
  _CropSelectionScreenState createState() => _CropSelectionScreenState();
}

class _CropSelectionScreenState extends State<CropSelectionScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _weatherData;
  List<String>? _suitableCrops;
  String? _season;
  Map<String, dynamic>? _confidenceScores;
  String? _error;
  String? _selectedSoilType;

  Map<String, List<String>> soilToCrops = {
    'Clay': ['Rice', 'Wheat', 'Cabbage', 'Broccoli'],
    'Sandy': ['Carrots', 'Potatoes', 'Peanuts', 'Watermelon'],
    'Loamy': ['Corn', 'Tomatoes', 'Soybeans', 'Cotton'],
    'Silty': ['Vegetables', 'Roses', 'Tulips', 'Bamboo'],
  };

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
      // Request location permission
      var status = await Permission.location.request();
      if (status.isDenied) {
        throw Exception('Location permission denied');
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _getPredictions(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getPredictions(double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.cropsEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _weatherData = data['weather'];
          _suitableCrops = List<String>.from(data['suitable_crops']);
          _season = data['season'];
          _confidenceScores =
              Map<String, dynamic>.from(data['confidence_scores']);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to get predictions');
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _updateCropSuggestions() {
    if (_selectedSoilType == null) return;

    List<String> soilBasedCrops = soilToCrops[_selectedSoilType!] ?? [];
    Map<String, double> scores = {};

    // Calculate confidence scores based on weather conditions and soil type
    for (String crop in soilBasedCrops) {
      double score = 0.0;

      // Temperature factor
      double tempC =
          double.tryParse(_weatherData!['temperature'].toString()) ?? 0;
      if (tempC >= 15 && tempC <= 25) {
        score += 40;
      } else if (tempC >= 10 && tempC <= 30) {
        score += 20;
      }

      // Humidity factor
      double humidity =
          double.tryParse(_weatherData!['humidity'].toString()) ?? 0;
      if (humidity >= 40 && humidity <= 70) {
        score += 40;
      } else if (humidity >= 30 && humidity <= 80) {
        score += 20;
      }

      // Season factor
      if (_season == 'Summer' &&
          ['Watermelon', 'Tomatoes', 'Cotton'].contains(crop)) {
        score += 20;
      } else if (_season == 'Winter' &&
          ['Wheat', 'Cabbage', 'Broccoli'].contains(crop)) {
        score += 20;
      }

      scores[crop] = score;
    }

    // Sort crops by confidence score
    var sortedCrops = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _suitableCrops = sortedCrops.take(3).map((e) => e.key).toList();
      _confidenceScores = Map.fromEntries(sortedCrops.take(3));
    });
  }

  Widget _buildWeatherInfo() {
    if (_weatherData == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[400]!,
            Colors.blue[300]!,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weather Conditions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _season ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.wb_sunny,
                color: Colors.white,
                size: 40,
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(
                icon: Icons.thermostat,
                value: '${_weatherData!['temperature']}°C',
                label: 'Temperature',
              ),
              _buildWeatherDetail(
                icon: Icons.water_drop,
                value: '${_weatherData!['humidity']}%',
                label: 'Humidity',
              ),
              _buildWeatherDetail(
                icon: Icons.air,
                value: '${_weatherData!['windSpeed']} km/h',
                label: 'Wind',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSoilSelection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.landscape,
                color: Colors.green[800],
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Soil Type',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              value: _selectedSoilType,
              hint: Text(
                'Select soil type',
                style: TextStyle(color: Colors.grey[600]),
              ),
              isExpanded: true,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.green[800]),
              items: ['Clay', 'Sandy', 'Loamy', 'Silty']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSoilType = newValue;
                  _updateCropSuggestions();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropList() {
    if (_suitableCrops == null || _suitableCrops!.isEmpty) {
      return Center(
        child: Text(
          'Select soil type to see crop suggestions',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco,
                color: Colors.green[800],
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Recommended Crops',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          ...List.generate(_suitableCrops!.length, (index) {
            final crop = _suitableCrops![index];
            final confidence = _confidenceScores![crop];
            return Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey[200]!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        crop,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${confidence.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[800],
        title: Text(
          'Crop Selection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[800]!,
              Colors.green[50]!,
            ],
            stops: [0.0, 0.2],
          ),
        ),
        child: Column(
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_weatherData != null)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _getCurrentLocation,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildWeatherInfo(),
                        _buildSoilSelection(),
                        _buildCropList(),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
