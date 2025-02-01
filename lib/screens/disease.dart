import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({Key? key}) : super(key: key);

  @override
  _DiseaseDetectionScreenState createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  XFile? _image;
  final picker = ImagePicker();
  String _result = '';
  bool _isAnalyzing = false;
  final String _backendUrl = 'http://localhost:8000'; // Python backend URL

  Future<void> getImage() async {
    try {
      // Create file input element
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();

      // Wait for file to be selected
      await input.onChange.first;
      if (input.files!.isEmpty) return;

      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);

      await reader.onLoad.first;
      final encoded = reader.result as String;
      final stripped =
          encoded.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');

      setState(() {
        _image = XFile.fromData(
          base64Decode(stripped),
          name: file.name,
          mimeType: file.type,
        );
      });

      await analyzePlantDisease();
    } catch (e) {
      setState(() {
        _result = 'Error picking image: $e';
      });
    }
  }

  Future<void> analyzePlantDisease() async {
    if (_image == null) return;

    setState(() {
      _isAnalyzing = true;
      _result = 'Analyzing image...';
    });

    try {
      // Read image as bytes and convert to base64
      final imageBytes = await _image!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Send to Python backend
      final response = await http
          .post(
            Uri.parse('$_backendUrl/predict_base64'),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
            body: json.encode({
              'image': base64Image,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Request timed out. Please try again.'),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final disease = data['disease'] as String;
          final confidence = (data['confidence'] * 100).toStringAsFixed(1);
          final recommendations = data['recommendations'] as String;

          setState(() {
            _result = '''
Disease Detection Results:
Disease: $disease
Confidence: $confidence%

Recommended Actions:
$recommendations''';
          });
        } else {
          throw Exception(data['error'] ?? 'Unknown error occurred');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _result = '''Error analyzing image: ${e.toString()}

Troubleshooting steps:
1. Ensure the Python backend is running (python main.py)
2. Check if backend URL is correct (http://localhost:8000)
3. Try uploading a different image
4. Make sure the image is clear and well-lit''';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PLANT DISEASE DETECTION',
            style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontFamily: GoogleFonts.cuteFont().fontFamily,
                fontWeight: FontWeight.w600)),
        backgroundColor: Color.fromARGB(255, 0, 104, 19),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'AI-Powered Plant Disease Detection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (_image == null)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('No image selected'),
                ),
              )
            else
              FutureBuilder<Uint8List>(
                future: _image!.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          snapshot.data!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : getImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            if (_isAnalyzing)
              Column(
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 10),
                  Text('Analyzing image with AI...'),
                ],
              )
            else if (_result.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('• Take clear, well-lit photos'),
                      Text('• Focus on affected areas'),
                      Text('• Include both healthy and diseased parts'),
                      Text('• Take multiple angles if needed'),
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
