import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import 'crop_selection.dart';
import 'soilmanagement.dart';
import 'disease.dart';
import 'best_practice.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatbot.dart';
import 'crop_prices.dart';
import '../widgets/weather_widget.dart';
import '../widgets/aqi_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                subtitle: Text('support@cropmate.com'),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 104, 19),
        toolbarHeight: 100,
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/crop.svg',
              height: 60.0,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10.0),
            Text(
              "CROPMATE",
              style: TextStyle(
                fontSize: 50.0,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 255, 255, 255),
                fontFamily: GoogleFonts.cuteFont().fontFamily,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.currency_rupee,
                color: Colors.white,
                size: 28,
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
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.call,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => _showContactDialog(context),
              tooltip: 'Contact Us',
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(238, 255, 255, 255),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isSmallScreen = constraints.maxWidth < 600;

            return SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    if (isSmallScreen) ...[
                      // Mobile layout
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome to CropMate!",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Your one-stop solution for all farming needs",
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color.fromARGB(255, 22, 48, 17),
                              ),
                            ),
                            // SizedBox(height: 8),
                            // Text(
                            //   "Select an option below to get started",
                            //   style: TextStyle(
                            //     fontSize: 14,
                            //     color: Colors.grey,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Weather and AQI widgets in a row for mobile
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: AQIWidget(),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: WeatherWidget(),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Desktop/tablet layout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome to CropMate!",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Your one-stop solution for all farming needs",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        const Color.fromARGB(255, 22, 48, 17),
                                  ),
                                ),
                                // SizedBox(height: 10),
                                // Text(
                                //   "Select an option below to get started",
                                //   style: TextStyle(
                                //     fontSize: 16,
                                //     color: Colors.grey,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: AQIWidget(),
                          ),
                          SizedBox(width: 24),
                          Padding(
                            padding: EdgeInsets.only(right: 24),
                            child: WeatherWidget(),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: isSmallScreen ? 32 : 48),
                    Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatBotScreen()),
          );
        },
        label: Text('Ask AI Assistant', style: TextStyle(color: Colors.white)),
        icon: Icon(
          Icons.smart_toy,
          color: Colors.white,
        ),
        backgroundColor: Color.fromARGB(255, 0, 104, 19),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 1; // Mobile phones
    if (width < 900) return 2; // Tablets
    if (width < 1200) return 3; // Small desktop
    return 4; // Large desktop
  }

  Widget _buildCard(BuildContext context, int index) {
    Color color = Color.fromARGB(255, 255, 255, 255); // Green
    final cards = [
      {
        'title': 'Crop Selection',
        'icon': Icons.grass,
        'color': Color.fromARGB(255, 0, 139, 62), // Cyan
        'screen': CropSelectionScreen(),
      },
      {
        'title': 'Soil Management',
        'icon': Icons.terrain,
        'color': Color.fromARGB(255, 0, 139, 62), // Brown
        'screen': SoilManagementScreen(),
      },
      {
        'title': 'Disease Identification',
        'icon': Icons.science,
        'color': Color.fromARGB(255, 0, 139, 62), // Red
        'screen': DiseaseDetectionScreen(),
      },
      {
        'title': 'Best Practices',
        'icon': Icons.agriculture,
        'color': Color.fromARGB(255, 0, 139, 62), // Green
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
