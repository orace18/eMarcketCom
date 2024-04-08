import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


class LocationUpdates extends StatefulWidget {
  @override
  _LocationUpdatesState createState() => _LocationUpdatesState();
}

class _LocationUpdatesState extends State<LocationUpdates> {
  Position _lastPosition = Position(
  latitude: 0.0,
  longitude: 0.0,
  timestamp: DateTime.now(), // Fournir une valeur pour timestamp
  accuracy: 0.0, // Fournir une valeur pour accuracy
  altitude: 0.0, // Fournir une valeur pour altitude
  altitudeAccuracy: 0.0, // Fournir une valeur pour altitudeAccuracy
  heading: 0.0,
  headingAccuracy: 0.0,
  speed: 0.0,
  speedAccuracy: 0.0
);


  @override
  void initState() {
    super.initState();
    _initLocationUpdates();
  }

  void _initLocationUpdates() async {
    Geolocator.getPositionStream(
      /* desiredAccuracy: LocationAccuracy.best,
      distanceFilter: 10, */
    ).listen((Position position) {
      setState(() {
        _lastPosition = position;
      });
      // Utilisez position pour faire ce que vous voulez
      print("New position: ${position.latitude}, ${position.longitude}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Updates'),
      ),
      body: Center(
        child: _lastPosition != null
            ? Text('Latitude: ${_lastPosition.latitude}, Longitude: ${_lastPosition.longitude}')
            : CircularProgressIndicator(),
      ),
    );
  }
}
