import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  final LatLng _center = LatLng(41.14961, -8.61099);
  LatLng? _selectedLocation;
  String? _selectedAddress;
  String? _locationName;
  bool _showConfirmButton = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Future<void> _getPlaceName(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          _locationName =
              "${placemarks.first.name}, ${placemarks.first.locality}";
        });
      }
    } catch (e) {
      print("Error fetching location name: $e");
    }
  }

  void _onMapTapped(LatLng tappedPoint) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      tappedPoint.latitude,
      tappedPoint.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        _selectedLocation = tappedPoint;
        _selectedAddress = "${place.name}, ${place.locality}";
      });
    }
  }

  void _confirmSelection() {
    if (_selectedAddress != null) {
      Navigator.pop(context, _selectedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Select Trade Point",
          style: GoogleFonts.outfit(
            fontSize: 24,
            color: Color.fromARGB(255, 222, 79, 79),
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color.fromARGB(223, 255, 213, 63),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                  _showConfirmButton = true;
                });
                _getPlaceName(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_pin,
                        color: Color.fromARGB(255, 222, 79, 79),
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_showConfirmButton)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(200, 222, 79, 79),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  )
                ),
                onPressed: () {
                  if (_selectedLocation != null && _locationName != null) {
                    Navigator.pop(context, _locationName);
                  }
                },
                child: Text(
                  "Confirm Trade Point",
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 66, 66, 66),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
