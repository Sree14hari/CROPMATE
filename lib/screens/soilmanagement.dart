import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<void> _analyzeSoil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/analyze_soil'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nitrogen': double.parse(_nitrogenController.text),
          'phosphorus': double.parse(_phosphorusController.text),
          'potassium': double.parse(_potassiumController.text),
          'ph': double.parse(_phController.text),
          'rainfall': double.parse(_rainfallController.text),
          'temperature': double.parse(_temperatureController.text),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _analysisResult = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to analyze soil data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInputField(
      String label, TextEditingController controller, String suffix) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffix: Text(suffix),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildResults() {
    if (_analysisResult == null) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soil Health: ${_analysisResult!['soil_health']}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text(
              'Nutrient Status:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ..._analysisResult!['nutrient_status'].entries.map<Widget>((entry) {
              return Padding(
                padding: EdgeInsets.only(left: 16, top: 8),
                child: Text('${entry.key}: ${entry.value}'),
              );
            }).toList(),
            SizedBox(height: 16),
            Text(
              'Recommendations:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ..._analysisResult!['recommendations']
                .map<Widget>((recommendation) {
              return Padding(
                padding: EdgeInsets.only(left: 16, top: 8),
                child: Text('• $recommendation'),
              );
            }).toList(),
            SizedBox(height: 16),
            Text(
              'Suitable Crops:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ..._analysisResult!['suitable_crops'].map<Widget>((crop) {
              return Padding(
                padding: EdgeInsets.only(left: 16, top: 8),
                child: Text('• $crop'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soil Management'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Soil Parameters',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              _buildInputField('Nitrogen', _nitrogenController, 'kg/ha'),
              _buildInputField('Phosphorus', _phosphorusController, 'kg/ha'),
              _buildInputField('Potassium', _potassiumController, 'kg/ha'),
              _buildInputField('pH Level', _phController, ''),
              _buildInputField('Rainfall', _rainfallController, 'mm'),
              _buildInputField('Temperature', _temperatureController, '°C'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _analyzeSoil,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Analyze Soil'),
              ),
              _buildResults(),
            ],
          ),
        ),
      ),
    );
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
