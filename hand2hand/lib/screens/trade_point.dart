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

    final screenHeight = MediaQuery.of(context).size.height;

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
            Navigator.pop(context);
          },
        ),
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: center, initialZoom: 13.0),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),

          /*
          Stack(
            children: [
              item['image'] != null
                  ? Image.network(
                    item['image'],
                    height: screenHeight * 0.25,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                  : Container(height: screenHeight * 0.25, color: Colors.grey),
              Positioned(
                bottom: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? "Item",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        color: Color.fromARGB(255, 66, 66, 66),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          */
          CircleLayer(
            circles: [
              CircleMarker(
                point: center,
                color: Color.fromARGB(76, 0, 0, 255),
                borderStrokeWidth: 2,
                borderColor: Colors.blue,
                useRadiusInMeter: true,
                radius: 2000,
              ),
            ],
          ),

          MarkerLayer(
            markers: [
              Marker(
                point: center,
                width: 50,
                height: 50,
                child: Icon(
                  Icons.location_on,
                  color: Color.fromARGB(255, 222, 79, 79), // Red color
                  size: 40, // Adjust size as needed
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
