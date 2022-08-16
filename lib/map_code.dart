import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentAddress = 'My Address';
  Position? currentposition;
  LatLng? latlong;

//  static double ?lat;
// static double ?long;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('\\\\\\\\\\\\\\\\\\\\\\\\');

    //   lat=position.latitude;
    //  long=position.longitude;

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        currentposition = position;
        currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}, ${place.name},${place.street}";
        latlong = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\$e");
    }
  }

  late GoogleMapController myController;
  Set<Marker> markers = {};

  // final LatLng _center = const LatLng(23.8103, 90.4125);

  void _onMapCreated(GoogleMapController controller) {
    myController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Maps Demo'),
          backgroundColor: Colors.green,
        ),
        body: Column(
          children: [
            Text(currentAddress),
            currentposition != null
                ? Text('Latitude = ${currentposition!.latitude}')
                : Container(),
            currentposition != null
                ? Text('Longitude = ${currentposition!.longitude}')
                : Container(),
            TextButton(
                onPressed: () {
                  currentposition==null?CircularProgressIndicator():
                  _determinePosition();
                },
                child: Text('Locate me')),
            Expanded(
              child: latlong == null
                  ? Container(child: Text('Please Click Locate Me Button'))
                  : Stack(
                      children: <Widget>[
                        GoogleMap(
                          markers: markers,
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: latlong!,
                            zoom: 15,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: FloatingActionButton(
                              onPressed: () {
                                markers.clear();

                                markers.add(Marker(
                                    markerId: const MarkerId('currentLocation'),
                                    position: latlong!));

                                setState(() {});
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              backgroundColor: Colors.green,
                              child: const Icon(Icons.location_city,size: 30.0),
                            ),
                          ),
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
