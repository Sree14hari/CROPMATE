import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AQIWidget extends StatefulWidget {
  const AQIWidget({super.key});

  @override
  _AQIWidgetState createState() => _AQIWidgetState();
}

class _AQIWidgetState extends State<AQIWidget> {
  Map<String, dynamic>? aqiData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAQI();
  }

  Future<void> fetchAQI() async {
    try {
      // Replace with your OpenWeatherMap API key
      const apiKey = 'd112bb7fbb737d73b1fdf2574fe391eb';
      // Default coordinates for Kerala
      const lat = '10.8505';
      const lon = '76.2711';

      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey'));

      if (response.statusCode == 200) {
        setState(() {
          aqiData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load AQI data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  String _getAQILevel(int aqi) {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }

  Color _getAQIColor(int aqi) {
    switch (aqi) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 160,
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return SizedBox(
        width: 160,
        height: 180,
        child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
      );
    }

    // Add null checks for the data
    if (aqiData == null ||
        aqiData!['list'] == null ||
        (aqiData!['list'] as List).isEmpty ||
        aqiData!['list'][0]['main'] == null) {
      return SizedBox(
        width: 160,
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No AQI data',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final aqi = aqiData!['list'][0]['main']['aqi'] ?? 0;
    final aqiLevel = _getAQILevel(aqi);
    final aqiColor = _getAQIColor(aqi);

    return Container(
      width: 160,
      height: 210,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.air, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                'AQI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: aqiColor.withOpacity(0.2),
              border: Border.all(color: aqiColor, width: 2),
            ),
            child: Center(
              child: Text(
                aqi.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: aqiColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            aqiLevel,
            style: TextStyle(
              fontSize: 16,
              color: aqiColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Air Quality',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
