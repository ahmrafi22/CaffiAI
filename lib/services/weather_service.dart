import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final String condition;
  final String description;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final String icon;
  final String cityName;

  WeatherData({
    required this.condition,
    required this.description,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.icon,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];

    return WeatherData(
      condition: weather['main'] as String,
      description: weather['description'] as String,
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: main['humidity'] as int,
      icon: weather['icon'] as String,
      cityName: json['name'] as String,
    );
  }

  /// Get a human-readable weather summary for AI context
  String getSummaryForAI() {
    String tempDescription;
    if (temperature < 10) {
      tempDescription = 'cold';
    } else if (temperature < 20) {
      tempDescription = 'cool';
    } else if (temperature < 28) {
      tempDescription = 'warm';
    } else {
      tempDescription = 'hot';
    }

    return 'The current weather in $cityName is $description with a temperature of ${temperature.round()}°C (feels like ${feelsLike.round()}°C). It is $tempDescription with $humidity% humidity.';
  }

  /// Get coffee recommendation context based on weather
  String getCoffeeRecommendationContext() {
    final buffer = StringBuffer();
    buffer.writeln(getSummaryForAI());
    buffer.writeln();
    buffer.write('Based on this weather, suggest appropriate coffee drinks. ');

    if (temperature < 15) {
      buffer.write(
        'Since it is cold, warm and comforting drinks like hot lattes, cappuccinos, hot chocolate, or spiced drinks would be ideal. ',
      );
    } else if (temperature < 22) {
      buffer.write(
        'The weather is pleasant, so a variety of options work well - classic hot coffee, warm lattes, or light iced options. ',
      );
    } else if (temperature < 30) {
      buffer.write(
        'It is warm, so refreshing iced coffees, cold brews, iced lattes, or frappuccinos would be great choices. ',
      );
    } else {
      buffer.write(
        'It is very hot, so focus on cold and refreshing drinks like iced cold brew, iced americano, frozen drinks, or smoothies. ',
      );
    }

    if (condition.toLowerCase().contains('rain') ||
        description.toLowerCase().contains('rain')) {
      buffer.write(
        'Since it is rainy, cozy warm drinks are especially appealing. ',
      );
    }

    return buffer.toString();
  }
}

class WeatherService {
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  static WeatherData? _cachedWeather;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 30);

  /// Fetch weather data for given coordinates
  static Future<WeatherData?> getWeather(
    double latitude,
    double longitude,
  ) async {
    debugPrint(
      'WeatherService.getWeather called with lat: $latitude, lng: $longitude',
    );

    // Return cached data if still valid
    if (_cachedWeather != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        debugPrint('Returning cached weather data');
        return _cachedWeather;
      }
    }

    try {
      final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
      debugPrint(
        'OpenWeather API key present: ${apiKey != null && apiKey.isNotEmpty}',
      );

      if (apiKey == null ||
          apiKey.isEmpty ||
          apiKey == 'your_openweather_api_key_here') {
        debugPrint('OpenWeather API key not configured');
        return null;
      }

      final url = Uri.parse(
        '$_baseUrl?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric',
      );
      debugPrint('Weather API URL: $url');

      final response = await http.get(url);
      debugPrint('Weather API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Weather API response: ${response.body}');
        _cachedWeather = WeatherData.fromJson(data);
        _cacheTime = DateTime.now();
        return _cachedWeather;
      } else {
        debugPrint(
          'Weather API error: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      return null;
    }
  }

  /// Clear cached weather data
  static void clearCache() {
    _cachedWeather = null;
    _cacheTime = null;
  }
}
