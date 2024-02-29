import 'package:flutter/material.dart';

class UrlProvider extends ChangeNotifier {
  late String _baseUrl;

  UrlProvider(String baseUrl) {
    _baseUrl = baseUrl;
  }

  String get baseUrl => _baseUrl;

  set baseUrl(String newUrl) {
    _baseUrl = newUrl;
    notifyListeners();
  }
}