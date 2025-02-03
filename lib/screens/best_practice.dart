import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BestPracticesScreen extends StatelessWidget {
  const BestPracticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isSmallScreen ? 150.0 : 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Farming Best Practices',
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
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
              children: [
                _buildSection(
                  'Soil Management',
                  [
                    _buildPractice(
                      'Soil Testing',
                      'Regular soil testing helps determine nutrient levels and pH balance. Test soil every 2-3 years.',
                      Icons.science,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Crop Rotation',
                      'Rotate crops to prevent soil depletion and reduce pest/disease problems. Plan 3-4 year rotation cycles.',
                      Icons.rotate_right,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Cover Crops',
                      'Plant cover crops during off-seasons to prevent erosion and add organic matter to soil.',
                      Icons.grass,
                      isSmallScreen,
                    ),
                  ],
                ),
                _buildSection(
                  'Water Management',
                  [
                    _buildPractice(
                      'Irrigation Timing',
                      'Water early morning or late evening to minimize evaporation. Monitor soil moisture levels regularly.',
                      Icons.water_drop,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Drip Irrigation',
                      'Use drip irrigation for efficient water use. Maintain system regularly to prevent clogs.',
                      Icons.water,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Mulching',
                      'Apply organic mulch to retain moisture, suppress weeds, and improve soil health.',
                      Icons.layers,
                      isSmallScreen,
                    ),
                  ],
                ),
                _buildSection(
                  'Pest Management',
                  [
                    _buildPractice(
                      'Integrated Pest Management',
                      'Use biological controls, crop rotation, and resistant varieties before chemical pesticides.',
                      Icons.bug_report,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Beneficial Insects',
                      'Attract and preserve beneficial insects by maintaining diverse plantings and avoiding broad-spectrum pesticides.',
                      Icons.pets,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Monitoring',
                      'Regular crop monitoring helps identify pest problems early. Keep detailed records of observations.',
                      Icons.visibility,
                      isSmallScreen,
                    ),
                  ],
                ),
                _buildSection(
                  'Nutrient Management',
                  [
                    _buildPractice(
                      'Organic Fertilizers',
                      'Use compost and organic fertilizers to improve soil structure and provide balanced nutrition.',
                      Icons.compost,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Timing Applications',
                      'Apply fertilizers based on crop growth stages and soil test results.',
                      Icons.timer,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Record Keeping',
                      'Maintain detailed records of all fertilizer applications and crop responses.',
                      Icons.note_alt,
                      isSmallScreen,
                    ),
                  ],
                ),
                _buildSection(
                  'Sustainable Practices',
                  [
                    _buildPractice(
                      'Biodiversity',
                      'Maintain diverse plantings and habitat areas to support beneficial insects and wildlife.',
                      Icons.park,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Energy Efficiency',
                      'Use energy-efficient equipment and consider renewable energy sources when possible.',
                      Icons.energy_savings_leaf,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Waste Management',
                      'Implement recycling and composting programs to minimize waste and create valuable resources.',
                      Icons.recycling,
                      isSmallScreen,
                    ),
                  ],
                ),
                _buildSection(
                  'Record Keeping',
                  [
                    _buildPractice(
                      'Field Records',
                      'Maintain detailed records of planting dates, varieties, and field operations.',
                      Icons.edit_note,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Weather Data',
                      'Record weather conditions and their effects on crop growth and management decisions.',
                      Icons.wb_sunny,
                      isSmallScreen,
                    ),
                    _buildPractice(
                      'Financial Records',
                      'Keep accurate financial records to track costs and returns for each crop.',
                      Icons.attach_money,
                      isSmallScreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> practices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ),
        ...practices,
        Divider(height: 32, thickness: 1),
      ],
    );
  }

  Widget _buildPractice(
      String title, String description, IconData icon, bool isSmallScreen) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: isSmallScreen ? 24 : 32,
                  color: Colors.green[700],
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
