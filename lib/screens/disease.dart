import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  XFile? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _diseaseData;
  final ImagePicker _picker = ImagePicker();
  final Random _random = Random();
  Uint8List? _webImage;

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
          _diseaseData = null;
        });
        if (kIsWeb) {
          var bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
        }
        _detectDisease();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _detectDisease() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API delay
    await Future.delayed(Duration(seconds: 2));

    // Predefined list of common plant diseases
    final diseases = [
      {
        'name': 'Early Blight',
        'probability': 0.85,
        'disease_details': {
          'description':
              'Early blight is a fungal disease that affects various plants, particularly tomatoes and potatoes. It causes dark spots with concentric rings on leaves, which can lead to leaf yellowing and defoliation.',
          'treatment':
              'Remove infected leaves, improve air circulation between plants, avoid overhead watering, and apply appropriate fungicides. Maintain good garden hygiene and rotate crops annually.'
        }
      },
      {
        'name': 'Powdery Mildew',
        'probability': 0.92,
        'disease_details': {
          'description':
              'Powdery mildew appears as white, powdery spots on leaves and stems. It can affect plant growth and yield, particularly in humid conditions with poor air circulation.',
          'treatment':
              'Improve air circulation, reduce humidity, remove infected parts, and apply fungicides. Consider using resistant varieties in future plantings.'
        }
      },
      {
        'name': 'Leaf Spot Disease',
        'probability': 0.78,
        'disease_details': {
          'description':
              'Leaf spot diseases cause spots of various colors and sizes on leaves. These spots can merge, causing leaves to yellow and fall off prematurely.',
          'treatment':
              'Remove and destroy infected leaves, avoid overhead watering, improve air circulation, and apply appropriate fungicides when necessary.'
        }
      },
      {
        'name': 'Root Rot',
        'probability': 0.88,
        'disease_details': {
          'description':
              'Root rot is caused by various fungi that attack plant roots, leading to wilting, yellowing leaves, and stunted growth. It often occurs in poorly drained soils.',
          'treatment':
              'Improve soil drainage, avoid overwatering, ensure proper planting depth, and consider using disease-resistant varieties. Remove severely affected plants.'
        }
      },
      {
        'name': 'Bacterial Wilt',
        'probability': 0.82,
        'disease_details': {
          'description':
              'Bacterial wilt causes rapid wilting and death in plants. Infected plants may show wilting even when soil is moist, and stems may show brown discoloration.',
          'treatment':
              'Remove and destroy infected plants, rotate crops, control insect vectors, and maintain good garden sanitation. Use disease-resistant varieties when available.'
        }
      }
    ];

    // Randomly select 1-2 diseases
    final numDiseases = _random.nextInt(2) + 1;
    final selectedDiseases = List.from(diseases)..shuffle();
    selectedDiseases.length = numDiseases;

    setState(() {
      _diseaseData = {
        'health_assessment': {'diseases': selectedDiseases}
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isSmallScreen ? 150.0 : 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Plant Disease Detection',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green[700]!,
                      Colors.green[500]!,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.eco,
                    size: isSmallScreen ? 60 : 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_image != null) ...[
                    Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          height: isSmallScreen ? 200 : 300,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: kIsWeb
                              ? _webImage != null
                                  ? Image.memory(
                                      _webImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return _buildErrorWidget();
                                      },
                                    )
                                  : _buildErrorWidget()
                              : Image.file(
                                  File(_image!.path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildErrorWidget();
                                  },
                                ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      height: isSmallScreen ? 150 : 200,
                      margin: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: isSmallScreen ? 48 : 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 16),
                          Text(
                            'Select or take a photo of your plant',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8.0 : 16.0,
                      vertical: isSmallScreen ? 8.0 : 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _getImage(ImageSource.camera),
                            icon: Icon(Icons.camera_alt,
                                size: isSmallScreen ? 20 : 24),
                            label: Text(
                              'Camera',
                              style:
                                  TextStyle(fontSize: isSmallScreen ? 14 : 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 8 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _getImage(ImageSource.gallery),
                            icon: Icon(Icons.photo_library,
                                size: isSmallScreen ? 20 : 24),
                            label: Text(
                              'Gallery',
                              style:
                                  TextStyle(fontSize: isSmallScreen ? 14 : 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 8 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                            strokeWidth: isSmallScreen ? 3 : 4,
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 16),
                          Text(
                            'Analyzing plant health...',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8.0 : 16.0,
                      ),
                      child: _buildDiseaseInfo(isSmallScreen),
                    ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseInfo([bool isSmallScreen = false]) {
    if (_diseaseData == null) return Container();

    var diseases = _diseaseData!['health_assessment']['diseases'] as List;
    if (diseases.isEmpty) {
      return Center(
        child: Text(
          'No diseases detected',
          style: GoogleFonts.poppins(fontSize: isSmallScreen ? 16 : 18),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: diseases.length,
      itemBuilder: (context, index) {
        var disease = diseases[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.green[50]!,
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          disease['name'] ?? 'Unknown Disease',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12,
                          vertical: isSmallScreen ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${((disease['probability'] as double) * 100).toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildInfoSection(
                    'Description',
                    disease['disease_details']['description'],
                    Icons.info_outline,
                    isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildInfoSection(
                    'Treatment',
                    disease['disease_details']['treatment'],
                    Icons.healing,
                    isSmallScreen,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon,
      [bool isSmallScreen = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green[700], size: isSmallScreen ? 20 : 24),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50,
            ),
            SizedBox(height: 8),
            Text(
              'Error loading image',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
