import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

class ServerResponseProvider extends ChangeNotifier {
  Map<String, dynamic>? _serverResponse;

  Map<String, dynamic>? get serverResponse => _serverResponse;

  void setServerResponse(Uint8List response) {
    _serverResponse = jsonDecode(const Utf8Decoder().convert(response));
    notifyListeners();
  }
}