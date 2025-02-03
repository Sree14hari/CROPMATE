import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import 'crop_selection.dart';
import 'package:cropmate/screens/crop_selection.dart';
import 'soilmanagement.dart';
import 'disease.dart';
import 'best_practice.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatbot.dart';
import 'crop_prices.dart';
import '../widgets/weather_widget.dart';
import '../widgets/aqi_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.contact_support, color: Color(0xFF4CAF50)),
              SizedBox(width: 10),
              Text('Contact Us'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.email, color: Color(0xFF4CAF50)),
                title: Text('Email'),
                subtitle: Text('sreehari14shr@gmail.com'),
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Color(0xFF4CAF50)),
                title: Text('Phone'),
                subtitle: Text('+91 9946582510'),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Color(0xFF4CAF50)),
                title: Text('Address'),
                subtitle: Text(
                    'Sree Buddha College of engineering\nPattoor, Kerala\nIndia'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 104, 19),
        toolbarHeight: isSmallScreen ? 80 : 100,
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/crop.svg',
              height: isSmallScreen ? 40 : 60,
              fit: BoxFit.contain,
            ),
            SizedBox(width: isSmallScreen ? 8 : 10),
            Text(
              "CROPMATE",
              style: TextStyle(
                fontSize: isSmallScreen ? 32 : 50,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 255, 255, 255),
                fontFamily: GoogleFonts.cuteFont().fontFamily,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isSmallScreen ? 4 : 8),
            child: IconButton(
              icon: Icon(
                Icons.currency_rupee,
                color: Colors.white,
                size: isSmallScreen ? 24 : 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CropPricesScreen()),
                );
              },
              tooltip: 'Crop Prices',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: isSmallScreen ? 8 : 16),
            child: IconButton(
              icon: Icon(
                Icons.call,
                color: Colors.white,
                size: isSmallScreen ? 24 : 28,
              ),
              onPressed: () => _showContactDialog(context),
              tooltip: 'Contact Us',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color.fromARGB(238, 255, 255, 255),
          ),
          const FallingLeaves(),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white.withOpacity(0.8),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 6 : 24),
                        child: isSmallScreen
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome to CropMate",
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          fontFamily:
                                              GoogleFonts.cuteFont().fontFamily,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Your one-stop solution for all farming needs",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color.fromARGB(
                                              255, 22, 48, 17),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: AQIWidget()),
                                      SizedBox(width: 6),
                                      Expanded(child: WeatherWidget()),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    child: SoilConditionWidget(),
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Welcome to CropMate",
                                          style: TextStyle(
                                            fontSize: 90,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: GoogleFonts.cuteFont()
                                                .fontFamily,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Your one-stop solution for all farming needs",
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: const Color.fromARGB(
                                                255, 22, 48, 17),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(child: AQIWidget()),
                                  SizedBox(width: 16),
                                  Expanded(child: WeatherWidget()),
                                  SizedBox(width: 16),
                                  Expanded(child: SoilConditionWidget()),
                                ],
                              ),
                      ),
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                _getCrossAxisCount(constraints.maxWidth),
                            childAspectRatio: isSmallScreen ? 1.0 : 1.2,
                            crossAxisSpacing: isSmallScreen ? 12 : 16,
                            mainAxisSpacing: isSmallScreen ? 12 : 16,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return _buildCard(context, index);
                          },
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 16 : 24,
                          horizontal: isSmallScreen ? 6 : 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(
                                //   Icons.eco,
                                //   color: Color.fromARGB(255, 0, 139, 62),
                                //   size: isSmallScreen ? 20 : 24,
                                // ),
                                SvgPicture.asset(
                                  'assets/crop.svg',
                                  height: isSmallScreen ? 20 : 24,
                                  color: Color.fromARGB(255, 0, 139, 62),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'CropMate',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 139, 62),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Developed by Team NOVASPARKS',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sreehari R | Abhinav R | Neeraj Sukumaran | Kalidas V.S',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            // Text(
                            //   ' ${DateTime.now().year} All rights reserved',
                            //   style: TextStyle(
                            //     fontSize: isSmallScreen ? 12 : 14,
                            //     color: Colors.grey[600],
                            //   ),
                            // ),
                          ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatBotScreen()),
          );
        },
        label: Text('Ask AI Assistant',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
            )),
        icon: Icon(
          Icons.smart_toy,
          color: Colors.white,
          size: isSmallScreen ? 20 : 24,
        ),
        backgroundColor: Color.fromARGB(255, 0, 104, 19),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  Widget _buildCard(BuildContext context, int index) {
    Color color = Color.fromARGB(255, 255, 255, 255);
    final cards = [
      {
        'title': 'Crop Selection',
        'icon': Icons.grass,
        'color': Color.fromARGB(255, 0, 139, 62),
        'screen': CropSelectionScreen(),
      },
      {
        'title': 'Soil Management',
        'icon': Icons.terrain,
        'color': Color.fromARGB(255, 0, 139, 62),
        'screen': SoilManagementScreen(),
      },
      {
        'title': 'Disease Identification',
        'icon': Icons.science,
        'color': Color.fromARGB(255, 0, 139, 62),
        'screen': DiseaseDetectionScreen(),
      },
      {
        'title': 'Best Practices',
        'icon': Icons.agriculture,
        'color': Color.fromARGB(255, 0, 139, 62),
        'screen': BestPracticesScreen(),
      },
    ];

    final card = cards[index];
    return CustomCard(
      title: card['title'] as String,
      icon: card['icon'] as IconData,
      color: card['color'] as Color,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => card['screen'] as Widget),
      ),
    );
  }
}

class SoilConditionWidget extends StatefulWidget {
  const SoilConditionWidget({super.key});

  @override
  _SoilConditionWidgetState createState() => _SoilConditionWidgetState();
}

class _SoilConditionWidgetState extends State<SoilConditionWidget> {
  bool isLoading = true;
  Map<String, dynamic>? soilData;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSoilData();
  }

  Future<void> fetchSoilData() async {
    // Simulated data fetch - in real app, this would come from soil sensors
    await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      setState(() {
        soilData = {
          'moisture': '65%',
          'ph': '6.5',
          'temperature': '22°C',
        };
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isLoading) {
      return SizedBox(
        width: 160,
        height: 180,
        child: Center(
            child: CircularProgressIndicator(
          color: Color.fromARGB(255, 0, 139, 62),
        )),
      );
    }

    if (error != null) {
      return SizedBox(
        width: 160,
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
              Icon(
                Icons.water_drop,
                color: Color.fromARGB(255, 0, 139, 62),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Soil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 139, 62),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Icon(
            Icons.grass,
            size: 40,
            color: Color.fromARGB(255, 0, 139, 62),
          ),
          SizedBox(height: 16),
          _buildSoilInfo('Moisture', soilData!['moisture']),
          SizedBox(height: 8),
          _buildSoilInfo('pH', soilData!['ph']),
          SizedBox(height: 8),
          _buildSoilInfo('Temp', soilData!['temperature']),
        ],
      ),
    );
  }

  Widget _buildSoilInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class FallingLeaf extends StatefulWidget {
  final double left;
  final double top;

  const FallingLeaf({
    super.key,
    required this.left,
    required this.top,
  });

  @override
  State<FallingLeaf> createState() => _FallingLeafState();
}

class _FallingLeafState extends State<FallingLeaf>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _rotationStart;
  late double _horizontalMovement;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 5 + math.Random().nextInt(5)),
      vsync: this,
    );

    _rotationStart = math.Random().nextDouble() * 360;
    _horizontalMovement = (math.Random().nextDouble() - 0.5) * 200;

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final endTop = MediaQuery.of(context).size.height + 50;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final top = widget.top + (endTop - widget.top) * progress;
        final horizontalOffset =
            math.sin(progress * math.pi * 2) * _horizontalMovement;
        final rotation = _rotationStart + progress * 360;

        return Positioned(
          left: widget.left + horizontalOffset,
          top: top,
          child: Transform.rotate(
            angle: rotation * math.pi / 180,
            child: Icon(
              Icons.eco,
              color: Color.fromARGB(255, 0, 172, 6).withOpacity(1.0),
              size: isSmallScreen ? 30 : 40,
            ),
          ),
        );
      },
    );
  }
}

class FallingLeaves extends StatelessWidget {
  const FallingLeaves({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final random = math.Random();
    final isSmallScreen = screenWidth < 600;

    return Stack(
      children: List.generate(isSmallScreen ? 8 : 15, (index) {
        return FallingLeaf(
          left: random.nextDouble() * screenWidth,
          top: -50 - random.nextDouble() * screenHeight,
        );
      }),
    );
  }
}
