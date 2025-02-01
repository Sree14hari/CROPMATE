import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CropSelectionScreen extends StatefulWidget {
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
        Uri.parse('http://localhost:8000/predict_crops'),
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

  Widget _buildWeatherInfo() {
    if (_weatherData == null) return SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.blue.shade700],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Weather',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _weatherInfoItem(
                    Icons.thermostat,
                    '${_weatherData!['temperature'].toStringAsFixed(1)}°C',
                    'Temperature',
                    Colors.white,
                  ),
                  _weatherInfoItem(
                    Icons.water_drop,
                    '${_weatherData!['humidity']}%',
                    'Humidity',
                    Colors.white,
                  ),
                  _weatherInfoItem(
                    Icons.umbrella,
                    '${_weatherData!['rainfall'].toStringAsFixed(1)}mm',
                    'Rainfall',
                    Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _weatherInfoItem(
                    Icons.air,
                    '${_weatherData!['wind_speed']?.toStringAsFixed(1) ?? 'N/A'} km/h',
                    'Wind Speed',
                    Colors.white,
                  ),
                  _weatherInfoItem(
                    Icons.wb_sunny,
                    '${_weatherData!['uv_index']?.toString() ?? 'N/A'}',
                    'UV Index',
                    Colors.white,
                  ),
                  _weatherInfoItem(
                    Icons.compress,
                    '${_weatherData!['pressure']?.toString() ?? 'N/A'} hPa',
                    'Pressure',
                    Colors.white,
                  ),
                ],
              ),
              Divider(color: Colors.white.withOpacity(0.5), height: 32),
              Text(
                'Weather: ${_weatherData!['description']}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              if (_season != null) ...[
                SizedBox(height: 8),
                Text(
                  'Season: $_season',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _weatherInfoItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.8),
              ),
        ),
      ],
    );
  }

  Widget _buildCropList() {
    if (_suitableCrops == null || _suitableCrops!.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Crops',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _suitableCrops!.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final crop = _suitableCrops![index];
                final confidence = _confidenceScores?[crop] ?? 0.0;

                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.grass, color: Colors.green),
                  ),
                  title: Text(
                    crop,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: confidence / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Confidence Score'),
                    ],
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${confidence.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    // TODO: Navigate to detailed crop information
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Selection'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting location and weather data...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _getCurrentLocation,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildWeatherInfo(),
                        _buildCropList(),
                      ],
                    ),
                  ),
                ),
    );
  }
}
