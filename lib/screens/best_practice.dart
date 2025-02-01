import 'package:flutter/material.dart';

class BestPracticesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agricultural Best Practices"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Top Agricultural Best Practices for Sustainable Farming",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            // Best Practice 1
            _buildBestPracticeCard(
              title: "1. Crop Rotation",
              description:
                  "Rotating crops in different seasons helps maintain soil health and reduce pest buildup.",
              imagePath: "assets/rot.jpg", // Replace with your asset path
            ),
            SizedBox(height: 20),
            // Best Practice 2
            _buildBestPracticeCard(
              title: "2. Efficient Water Usage",
              description:
                  "Use drip irrigation and other water-saving techniques to optimize water usage and reduce wastage.",
              imagePath: "assets/wat.jpg", // Replace with your asset path
            ),
            SizedBox(height: 20),
            // Best Practice 3
            _buildBestPracticeCard(
              title: "3. Organic Farming",
              description:
                  "Use organic fertilizers and avoid harmful pesticides to promote healthier crops and the environment.",
              imagePath: "assets/org.jpg", // Replace with your asset path
            ),
            SizedBox(height: 20),
            // Add more practices as needed
          ],
        ),
      ),
    );
  }

  // Method to build a Best Practice Card
  Widget _buildBestPracticeCard({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Image on the left side
            Image.asset(
              imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 16),
            // Text on the right side
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.justify,
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
