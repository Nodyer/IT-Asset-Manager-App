import 'package:app_am/pages/location.dart';
import 'package:app_am/pages/update_location.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GPSController extends ChangeNotifier {
  double lat = 0.0;
  double long = 0.0;
  String error = '';
  Set<Marker> markers = <Marker>{};
  late GoogleMapController _mapsController;

  // GPSController(){
  //   getPosition();
  // }

  get mapsController => _mapsController;

  onMapCreated(GoogleMapController gmc) async {
    _mapsController = gmc;
    getPosition();
    loadITAsset();
  }

  loadITAsset(){
    double itassetsLat = -23.554132;
    double itassetsLong = -46.628629;
    markers.add(Marker(
      markerId: const MarkerId('TESTE'),
      position: LatLng(itassetsLat, itassetsLong),
      onTap: () => {
            showModalBottomSheet(
              context: appKey.currentState!.context,
              builder: (context) => const UpdateLocation()
              )
            },
    ));
    notifyListeners();
  }

  // -23.554132, -46.628629

  getPosition() async {
    try{
      Position position = await _currentPosition();
      lat = position.latitude;
      long = position.longitude;
      _mapsController.animateCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
    } catch (e){
      error = e.toString();
    }
    notifyListeners();
  }

  Future<Position> _currentPosition() async {
    LocationPermission permission;
    bool enable = await Geolocator.isLocationServiceEnabled();

    if(! enable){
      return Future.error('Por favor, habilite a localização no smartphone.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
       if (permission == LocationPermission.denied){
        return Future.error('Você precisa autorizar o acesso à localização.');
      }
    }

    if (permission == LocationPermission.deniedForever){
      return Future.error('Você precisa autorizar o acesso à localização.');
    }

    return await Geolocator.getCurrentPosition(); 
  }
}