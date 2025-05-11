import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/screens/navController.dart'; // Import the correct HomePage class

class TradePoint extends StatelessWidget {
  final double latitude; // Latitude parameter
  final double longitude; // Longitude parameter

  const TradePoint({Key? key, required this.latitude, required this.longitude})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug: Print latitude and longitude to the console
    print('Latitude: $latitude, Longitude: $longitude');

    // Create LatLng object from latitude and longitude
    final LatLng center = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Trade Point Map",
          style: GoogleFonts.outfit(
            fontSize: 24,
            color: Color.fromARGB(255, 222, 79, 79),
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color.fromARGB(223, 255, 213, 63),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 222, 79, 79)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ), // Navigate to HomePage
            );
          },
        ),
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: center, initialZoom: 18.0),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}
