import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import 'crop_selection.dart';
import 'soilmanagement.dart';
import 'disease.dart';
import 'best_practice.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 45, 11),
        title: Row(
          children: [
            Image.asset(
              'assets/log.png', // Replace with your image path
              height: 40.0,
            ),
            SizedBox(width: 10.0),
            Text("CropMate",
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 229, 254, 229))),
          ],
        ),
      ),
      body: Container(
        color: const Color.fromARGB(239, 212, 246, 210),
        child: Column(
          children: [
            SizedBox(height: 40),
            Column(
              children: [
                Text(
                  "Welcome to CropMate!",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("Your one-stop solution for all farming needs",
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 22, 48, 17),
                    )),
                SizedBox(height: 10),
                Text(
                  "Select an option below to get started",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 88, 88, 88),
                  ),
                ),
              ],
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                padding: EdgeInsets.all(16.0),
                children: [
                  CustomCard(
                    title: "Crop Selection",
                    icon: Icons.grass,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CropSelectionScreen()),
                    ),
                    color: Colors.cyan,
                  ),
                  CustomCard(
                    title: "Soil Management",
                    icon: Icons.terrain,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SoilManagementScreen()),
                    ),
                    color: Colors.brown,
                  ),
                  CustomCard(
                    title: "Disease Identification",
                    icon: Icons.science,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DiseaseDetectionScreen()),
                    ),
                    color: Colors.red,
                  ),
                  CustomCard(
                    title: "Best Practices",
                    icon: Icons.agriculture,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BestPracticesScreen()),
                    ),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
