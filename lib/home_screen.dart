import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final double _apploreLatitude = 28.6044354;
  final double _apploreLongitude = 77.3898763;
  double? _latitude;
  double? _longitude;
  String _locationStatus = "Press the button to get location";
  double _distance = 0;

  double calculateDistanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371; // Earth radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distanceKm = earthRadiusKm * c;
    double distanceMeters = distanceKm * 1000;

    return distanceMeters;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationStatus = "Location services are disabled.";
      });
      return;
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationStatus = "Location permission denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationStatus =
            "Location permission permanently denied. Please enable from settings.";
      });
      return;
    }

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 200,
    );

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _distance = calculateDistanceInMeters(
        _latitude!,
        _longitude!,
        _apploreLatitude,
        _apploreLongitude,
      );
      _locationStatus = "Location fetched successfully!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GeoLocator")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(
              _locationStatus,
              style: GoogleFonts.varelaRound(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text("Applore Technologies", style: GoogleFonts.varelaRound()),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Latitude: $_apploreLatitude"),
                  Text("Longitude: $_apploreLongitude"),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),
          Text("Current Location", style: GoogleFonts.varelaRound()),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Latitude: ${_latitude ?? "--"}"),
                  Text("Longitude: ${_longitude ?? "--"}"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            "${_distance.toStringAsFixed(2)} meters from Applore Technologies",
            style: GoogleFonts.varelaRound(
              color: Colors.red,
              fontSize: 20,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
