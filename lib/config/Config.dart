import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Config {
  static late Map<String, dynamic> _config;

  static Future<void> loadConfig() async {
    String jsonString = await rootBundle.loadString('assets/config.json');
    _config = json.decode(jsonString) as Map<String, dynamic>;
  }

  static String get apiBaseUrl => _config['apiBaseUrl'];
}