import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';

class SoilManagementScreen extends StatefulWidget {
  @override
  _SoilManagementScreenState createState() => _SoilManagementScreenState();
}

class _SoilManagementScreenState extends State<SoilManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();

  Map<String, dynamic>? _analysisResult;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 104, 19),
        title: Text(
          'SOIL MANAGEMENT',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: GoogleFonts.cuteFont().fontFamily,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 0, 104, 19).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(),
                  SizedBox(height: 24),
                  _buildInputSection(),
                  SizedBox(height: 24),
                  _buildAnalyzeButton(),
                  SizedBox(height: 24),
                  if (_isLoading) _buildLoadingIndicator(),
                  if (_analysisResult != null) _buildResults(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.eco,
              size: 48,
              color: Color.fromARGB(255, 0, 104, 19),
            ),
            SizedBox(height: 16),
            Text(
              'Soil Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 104, 19),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Enter your soil parameters below for a comprehensive analysis of soil health and recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'Nitrogen',
                    _nitrogenController,
                    'mg/kg',
                    Icons.science,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    'Phosphorus',
                    _phosphorusController,
                    'mg/kg',
                    Icons.science,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'Potassium',
                    _potassiumController,
                    'mg/kg',
                    Icons.science,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    'pH Level',
                    _phController,
                    'pH',
                    Icons.water_drop,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'Rainfall',
                    _rainfallController,
                    'mm',
                    Icons.water,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    'Temperature',
                    _temperatureController,
                    '°C',
                    Icons.thermostat,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String suffix,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: Color.fromARGB(255, 0, 104, 19)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color.fromARGB(255, 0, 104, 19)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (double.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _analyzeSoil,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 0, 104, 19),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        'Analyze Soil',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 0, 104, 19)),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis Results',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 104, 19),
              ),
            ),
            Divider(height: 32),
            _buildResultItem(
              'Soil Health',
              _analysisResult!['soil_health'],
              Icons.favorite,
            ),
            _buildResultItem(
              'Recommended Crops',
              _analysisResult!['recommended_crops'].join(', '),
              Icons.grass,
            ),
            _buildResultItem(
              'Fertilizer Recommendation',
              _analysisResult!['fertilizer_recommendation'],
              Icons.science,
            ),
            _buildResultItem(
              'Additional Notes',
              _analysisResult!['additional_notes'],
              Icons.note,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color.fromARGB(255, 0, 104, 19)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeSoil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });

    try {
      // Get values from controllers
      double nitrogen = double.parse(_nitrogenController.text);
      double phosphorus = double.parse(_phosphorusController.text);
      double potassium = double.parse(_potassiumController.text);
      double ph = double.parse(_phController.text);
      double rainfall = double.parse(_rainfallController.text);
      double temperature = double.parse(_temperatureController.text);

      // Local analysis logic
      String soilHealth =
          _determineSoilHealth(nitrogen, phosphorus, potassium, ph);
      List<String> recommendedCrops = _getRecommendedCrops(
          nitrogen, phosphorus, potassium, ph, rainfall, temperature);
      String fertilizerRecommendation =
          _getFertilizerRecommendation(nitrogen, phosphorus, potassium);
      String additionalNotes = _getAdditionalNotes(ph, rainfall, temperature);

      setState(() {
        _analysisResult = {
          'soil_health': soilHealth,
          'recommended_crops': recommendedCrops,
          'fertilizer_recommendation': fertilizerRecommendation,
          'additional_notes': additionalNotes,
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing soil data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _determineSoilHealth(double n, double p, double k, double ph) {
    // Simplified soil health determination
    int score = 0;

    // Check Nitrogen levels (ideal range: 140-280 mg/kg)
    if (n >= 140 && n <= 280)
      score += 2;
    else if (n >= 100 && n <= 320) score += 1;

    // Check Phosphorus levels (ideal range: 20-40 mg/kg)
    if (p >= 20 && p <= 40)
      score += 2;
    else if (p >= 10 && p <= 50) score += 1;

    // Check Potassium levels (ideal range: 180-360 mg/kg)
    if (k >= 180 && k <= 360)
      score += 2;
    else if (k >= 120 && k <= 400) score += 1;

    // Check pH levels (ideal range: 6.0-7.5)
    if (ph >= 6.0 && ph <= 7.5)
      score += 2;
    else if (ph >= 5.5 && ph <= 8.0) score += 1;

    if (score >= 7) return 'Excellent';
    if (score >= 5) return 'Good';
    if (score >= 3) return 'Fair';
    return 'Poor';
  }

  List<String> _getRecommendedCrops(
      double n, double p, double k, double ph, double rainfall, double temp) {
    List<String> crops = [];

    // Basic crop recommendations based on soil parameters
    if (ph >= 6.0 && ph <= 7.0 && n >= 140) {
      crops.add('Rice');
    }
    if (ph >= 6.0 && ph <= 7.5 && p >= 20 && k >= 180) {
      crops.add('Wheat');
    }
    if (ph >= 5.5 && ph <= 7.0 && rainfall >= 700) {
      crops.add('Cotton');
    }
    if (ph >= 6.0 && ph <= 7.0 && temp >= 20 && temp <= 30) {
      crops.add('Sugarcane');
    }
    if (ph >= 5.5 && ph <= 7.0 && n >= 120) {
      crops.add('Vegetables');
    }
    if (ph >= 6.0 && ph <= 7.5 && rainfall >= 500) {
      crops.add('Pulses');
    }

    if (crops.isEmpty) {
      crops.add('Consider soil treatment before planting');
    }

    return crops;
  }

  String _getFertilizerRecommendation(double n, double p, double k) {
    List<String> recommendations = [];

    // Nitrogen recommendation
    if (n < 140) {
      recommendations
          .add('Add nitrogen-rich fertilizers like Urea or Ammonium Sulfate');
    } else if (n > 280) {
      recommendations.add('Reduce nitrogen application');
    }

    // Phosphorus recommendation
    if (p < 20) {
      recommendations.add(
          'Add phosphorus-rich fertilizers like DAP or Single Super Phosphate');
    } else if (p > 40) {
      recommendations.add('Reduce phosphorus application');
    }

    // Potassium recommendation
    if (k < 180) {
      recommendations
          .add('Add potassium-rich fertilizers like Muriate of Potash');
    } else if (k > 360) {
      recommendations.add('Reduce potassium application');
    }

    if (recommendations.isEmpty) {
      return 'Current nutrient levels are optimal. Maintain regular fertilization schedule.';
    }

    return recommendations.join('. ');
  }

  String _getAdditionalNotes(double ph, double rainfall, double temp) {
    List<String> notes = [];

    // pH recommendations
    if (ph < 6.0) {
      notes
          .add('Soil is acidic. Consider adding agricultural lime to raise pH');
    } else if (ph > 7.5) {
      notes.add('Soil is alkaline. Consider adding sulfur to lower pH');
    }

    // Rainfall considerations
    if (rainfall < 500) {
      notes.add(
          'Low rainfall area. Consider drought-resistant crops and irrigation systems');
    } else if (rainfall > 2000) {
      notes.add(
          'High rainfall area. Ensure good drainage and consider raised beds');
    }

    // Temperature considerations
    if (temp < 15) {
      notes.add(
          'Cool climate. Consider cold-resistant crops and greenhouse cultivation');
    } else if (temp > 35) {
      notes.add('Hot climate. Implement proper irrigation and mulching');
    }

    if (notes.isEmpty) {
      return 'Environmental conditions are favorable for most crops';
    }

    return notes.join('. ');
  }

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }
}
