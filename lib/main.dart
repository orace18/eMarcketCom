import 'dart:convert';
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
  final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('ws://$baseUrl/')); // Assurez-vous que la variable baseUrl est correctement définie

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
            title: Text("Permission Required"),
            content: Text("This app requires access to your location."),
            actions: [
              ElevatedButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Si l'autorisation est accordée, initialisez la surveillance de la position
      _initLocationUpdates();
    }
  }

  void _initLocationUpdates() async {
    Geolocator.getPositionStream().listen((Position position) {
      // Envoie les données de localisation au backend sous forme d'un objet JSON
      final Map<String, dynamic> data = {
        'userId': '1', // Remplacez '123' par l'ID de l'utilisateur
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
        title: Text('Location Updates'),
      ),
      body: Center(
        child: Text('Sending location updates to backend...'),
      ),
    );
  }
}


/* 
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
     return MaterialApp(
         home: Home()
      );
  }
}

class Home extends  StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
       String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

   @override
  void initState() {
    checkGps();
    super.initState();
  }

  checkGps() async {
      servicestatus = await Geolocator.isLocationServiceEnabled();
      if(servicestatus){
            permission = await Geolocator.checkPermission();
          
            if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                    print('Location permissions are denied');
                }else if(permission == LocationPermission.deniedForever){
                    print("'Location permissions are permanently denied");
                }else{
                   haspermission = true;
                }
            }else{
               haspermission = true;
            }

            if(haspermission){
                setState(() {
                  //refresh the UI
                });

                getLocation();
            }
      }else{
        print("GPS Service is not enabled, turn on GPS location");
      }

      setState(() {
         //refresh the UI
      });
  }

  getLocation() async {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
         //refresh UI
      });

      LocationSettings locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high, //accuracy of the location data
            distanceFilter: 100, //minimum distance (measured in meters) a 
                                 //device must move horizontally before an update event is generated;
      );

      StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
            locationSettings: locationSettings).listen((Position position) {
            print(position.longitude); //Output: 80.24599079
            print(position.latitude); //Output: 29.6593457

            long = position.longitude.toString();
            lat = position.latitude.toString();

            setState(() {
              //refresh UI on update
            });
      });
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
         appBar: AppBar(
            title: Text("Get GPS Location"),
            backgroundColor: Colors.redAccent
         ),
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(50),
             child: Column(
                children: [ 

                     Text(servicestatus? "GPS is Enabled": "GPS is disabled."),
                     Text(haspermission? "GPS is Enabled": "GPS is disabled."),
                     
                     Text("Longitude: $long", style:TextStyle(fontSize: 20)),
                     Text("Latitude: $lat", style: TextStyle(fontSize: 20),)

                ]
              )
          )
    );
  } 
} */