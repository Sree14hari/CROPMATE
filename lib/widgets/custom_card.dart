import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  CustomCard(
      {required this.title,
      required this.icon,
      required this.onTap,
      required MaterialColor color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 90, color: const Color.fromARGB(255, 2, 151, 7)),
              SizedBox(height: 10),
              Text(title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
