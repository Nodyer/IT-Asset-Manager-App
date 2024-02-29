import 'package:app_am/pages/location.dart';
import 'package:app_am/pages/update_location.dart';
import 'package:app_am/providers/url_server.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class GPSController extends ChangeNotifier {
  double lat = 0.0;
  double long = 0.0;
  double itassetLat = 0.0;
  double itassetLong = 0.0;
  String itassetCode = '';
  String error = '';
  Set<Marker> markers = <Marker>{};
  late GoogleMapController _mapsController;

  get mapsController => _mapsController;

  onMapCreated(GoogleMapController gmc) async {
    _mapsController = gmc;
    getPosition();
    loadITAsset(itassetLat, itassetLong);
  }

  void updateITAssetLocation(String code, double latitude, double longitude) {
    itassetCode = code;
    itassetLat = latitude;
    itassetLong = longitude;
    notifyListeners();
  }

  loadITAsset(double itassetsLat, double itassetsLong) {
    markers.clear();
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

Future<void> updateLocationAPI(BuildContext context) async {
    try {
      Map<String, dynamic> requestBody = {
        'latitude': lat,
        'longitude': long,
      };

      final urlProvider = Provider.of<UrlProvider>(context, listen: false).baseUrl;
      var url = Uri.https(urlProvider, '/it_asset/$itassetCode');
      
      var response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint('Localização do ativo atualizada com sucesso na API.');
        itassetLat = lat;
        itassetLong = long;
        loadITAsset(itassetLat, itassetLong); 
        notifyListeners();
      } else {
        debugPrint('Falha ao atualizar a localização do ativo na API. Status code: ${response.statusCode}');
        debugPrint('Mensagem de erro: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar a localização do ativo na API: $e');
    }
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