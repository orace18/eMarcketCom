import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_app/constantes.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationUpdates(),
    );
  }
}

class LocationUpdates extends StatefulWidget {
  @override
  _LocationUpdatesState createState() => _LocationUpdatesState();
}

class _LocationUpdatesState extends State<LocationUpdates> {
  final WebSocketChannel channel = WebSocketChannel.connect(Uri.parse(
      'ws://$baseUrl/')); // Assurez-vous que la variable baseUrl est correctement définie

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  void _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Permission Requise"),
            content: Text(
                "Voulez-vous autoriser cette application à utiliser votre position ?"),
            actions: [
              ElevatedButton(
                child: Text("Non"),
                onPressed: () {
                  Navigator.of(context).pop();
                  exit(0);
                },
              ),
              ElevatedButton(
                child: Text("Oui"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  LocationPermission permission =
                      await Geolocator.requestPermission();
                  if (permission == LocationPermission.denied ||
                      permission == LocationPermission.deniedForever) {
                    // Traitement si la permission est refusée
                    exit(0);
                  } else {
                    // Si la permission est accordée, initialisez la surveillance de la position
                    _initLocationUpdates();
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      // Si la permission est déjà accordée, initialisez la surveillance de la position
      _initLocationUpdates();
    }
  }

  void _initLocationUpdates() async {
    Geolocator.getPositionStream().listen((Position position) {
      // Envoie les données de localisation au backend sous forme d'un objet JSON
      final Map<String, dynamic> data = {
        'userId': '1', // Remplacez '1' par l'ID de l'utilisateur
        'longitude': position.longitude,
        'latitude': position.latitude,
      };
      channel.sink.add(jsonEncode(data));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mise à jour de la position'),
      ),
      body: Center(
        child: Text('Envoie de la position au backend...'),
      ),
    );
  }
}
