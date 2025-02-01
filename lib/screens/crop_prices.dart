import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropPricesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 104, 19),
        title: Text(
          'Crop Prices',
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: GoogleFonts.cuteFont().fontFamily,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildPriceCard('Rice', '₹21.24/kg'),
          _buildPriceCard('Barley', '₹16.50/kg'),
          _buildPriceCard('Tea', '₹150/kg'),
          _buildPriceCard('Coffee', '₹120/kg'),
          _buildPriceCard('Rubber', '₹130/kg'),
          _buildPriceCard('Pepper', '₹800/kg'),
          _buildPriceCard('Cardamom', '₹1500/kg'),
          _buildPriceCard('Coconut', '₹35/kg'),
          _buildPriceCard('Tapioca', '₹20/kg'),
          _buildPriceCard('Potato', '₹15/kg'),
          _buildPriceCard('Onion', '₹20/kg'),
          _buildPriceCard('Tomato', '₹25.90/kg'),
          _buildPriceCard('Mango', '₹50/kg'),
          _buildPriceCard('Banana', '₹80/kg'),
          Text("For more crop prices, ask CROPMATE AI ASSISTANT.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              )),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String cropName, String price) {
    return Container(
      height: 80,
      child: Card(
        elevation: 5,
        margin: EdgeInsets.only(bottom: 16),
        child: ListTile(
          leading: Image(
            image: AssetImage('assets/crop.png'),
            height: 50,
          ),
          title: Text(
            cropName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Text(
            price,
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 0, 104, 19),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
