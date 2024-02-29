import 'package:flutter/material.dart';
import 'package:app_am/providers/gps_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

final appKey = GlobalKey();

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {

  @override
  Widget build(BuildContext context) {
    GPSController gpsController = Provider.of<GPSController>(context);
    debugPrint(gpsController.lat.toString());
    debugPrint(gpsController.long.toString());

    return Scaffold(
        key: appKey,
        appBar: AppBar(
          title: const Text('Localização'),
          centerTitle: true,
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(gpsController.lat, gpsController.long),
            zoom: 18,
          ),
          zoomControlsEnabled: true,
          mapType: MapType.normal,
          myLocationEnabled: true,
          onMapCreated: gpsController.onMapCreated,
          markers: gpsController.markers,
        ),
      );
  }
}