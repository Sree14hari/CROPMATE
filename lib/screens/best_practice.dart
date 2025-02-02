import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BestPracticesScreen extends StatelessWidget {
  const BestPracticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Agricultural Best Practices",
          style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.cuteFont().fontFamily),
        ),
        backgroundColor: Color.fromARGB(255, 0, 104, 19),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   "Top Agricultural Best Practices",
            //   style: TextStyle(
            //     fontSize: MediaQuery.of(context).size.width * 0.06,
            //     fontWeight: FontWeight.bold,
            //     color: Color.fromARGB(255, 0, 104, 19),
            //   ),
            // ),
            Text(
              "For Sustainable Farming",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.03,
                color: Colors.grey[600],
                fontFamily: GoogleFonts.oswald().fontFamily,
              ),
            ),
            SizedBox(height: 20),
            ExpandablePracticeCard(
              title: "Crop Rotation",
              shortDescription: "Maintain soil health and reduce pest buildup",
              imagePath: "assets/rot.jpg",
              detailedInfo: [
                PracticeDetail(
                  title: "Benefits",
                  content: "• Improves soil structure and fertility\n"
                      "• Reduces pest and disease problems\n"
                      "• Helps in weed control\n"
                      "• Reduces dependency on fertilizers",
                  size: 20,
                ),
                PracticeDetail(
                  title: "Implementation",
                  content: "1. Plan your rotation sequence\n"
                      "2. Alternate between different crop families\n"
                      "3. Include cover crops in rotation\n"
                      "4. Consider market demand when planning",
                  size: 20,
                ),
                PracticeDetail(
                  title: "Best Time",
                  content: "• Plan rotations seasonally\n"
                      "• Consider crop growing seasons\n"
                      "• Align with local climate patterns",
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 20),
            ExpandablePracticeCard(
              title: "Efficient Water Usage",
              shortDescription: "Optimize irrigation for better crop yield",
              imagePath: "assets/wat.jpg",
              detailedInfo: [
                PracticeDetail(
                  title: "Techniques",
                  content: "• Drip irrigation systems\n"
                      "• Sprinkler systems\n"
                      "• Soil moisture sensors\n"
                      "• Rainwater harvesting",
                  size: 20,
                ),
                PracticeDetail(
                  title: "Water Management",
                  content: "1. Monitor soil moisture levels\n"
                      "2. Water during early morning or evening\n"
                      "3. Use mulching to retain moisture\n"
                      "4. Maintain irrigation equipment",
                  size: 20,
                ),
                PracticeDetail(
                  title: "Conservation Tips",
                  content: "• Fix leaks promptly\n"
                      "• Use drought-resistant crops\n"
                      "• Implement water recycling\n"
                      "• Schedule irrigation properly",
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 20),
            ExpandablePracticeCard(
              title: "Organic Farming",
              shortDescription: "Promote environmental sustainability",
              imagePath: "assets/org.jpg",
              detailedInfo: [
                PracticeDetail(
                  title: "Organic Methods",
                  content: "• Natural pest control\n"
                      "• Composting techniques\n"
                      "• Crop diversity\n"
                      "• Soil enrichment",
                  size: 20,
                ),
                PracticeDetail(
                  title: "Benefits",
                  content: "1. Better soil quality\n"
                      "2. Reduced environmental impact\n"
                      "3. Healthier produce\n"
                      "4. Premium market prices",
                  size: 20,
                ),
                PracticeDetail(
                  title: "Getting Started",
                  content: "Start with soil testing\n"
                      " Plan crop rotation\n"
                      " Create compost systems\n"
                      " Learn natural pest control",
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandablePracticeCard extends StatefulWidget {
  final String title;
  final String shortDescription;
  final String imagePath;
  final List<PracticeDetail> detailedInfo;

  const ExpandablePracticeCard({
    Key? key,
    required this.title,
    required this.shortDescription,
    required this.imagePath,
    required this.detailedInfo,
  }) : super(key: key);

  @override
  _ExpandablePracticeCardState createState() => _ExpandablePracticeCardState();
}

class _ExpandablePracticeCardState extends State<ExpandablePracticeCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
            if (isExpanded) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          });
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.imagePath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 104, 19),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.shortDescription,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns:
                        Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Color.fromARGB(255, 0, 104, 19),
                    ),
                  ),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: widget.detailedInfo.map((detail) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (detail.title == "Getting Started")
                                Icon(
                                  Icons.arrow_right,
                                  color: Color.fromARGB(255, 0, 104, 19),
                                  size: 24,
                                ),
                              Text(
                                detail.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 104, 19),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.only(
                              left: detail.title == "Getting Started"
                                  ? 24.0
                                  : 0.0,
                            ),
                            child: Text(
                              detail.content,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                          ),
                          if (detail != widget.detailedInfo.last)
                            Divider(height: 24),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PracticeDetail {
  final String title;
  final String content;

  PracticeDetail({
    required this.title,
    required this.content,
    required int size,
  });
}
