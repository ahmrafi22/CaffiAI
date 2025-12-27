import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationStateService extends ChangeNotifier {
  static const String _latKey = 'user_latitude';
  static const String _lngKey = 'user_longitude';
  static const String _addressKey = 'user_address';
  static const String _cityKey = 'user_city';

  double? _latitude;
  double? _longitude;
  String? _address;
  String? _city;
  bool _isLoading = false;
  String? _errorMessage;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get address => _address;
  String? get city => _city;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLocation => _latitude != null && _longitude != null;

  LocationStateService() {
    _loadSavedLocation();
    fetchCurrentLocation();
  }

  /// Load saved location from local storage
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _latitude = prefs.getDouble(_latKey);
      _longitude = prefs.getDouble(_lngKey);
      _address = prefs.getString(_addressKey);
      _city = prefs.getString(_cityKey);

      if (hasLocation) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  /// Save location to local storage
  Future<void> _saveLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_latitude != null) {
        await prefs.setDouble(_latKey, _latitude!);
      }
      if (_longitude != null) {
        await prefs.setDouble(_lngKey, _longitude!);
      }
      if (_address != null) {
        await prefs.setString(_addressKey, _address!);
      }
      if (_city != null) {
        await prefs.setString(_cityKey, _city!);
      }
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  /// Fetch current location
  Future<void> fetchCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permission denied';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permission permanently denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Get address from coordinates
      await _fetchAddress();

      // Save to local storage
      await _saveLocation();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error fetching location: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch address from coordinates
  Future<void> _fetchAddress() async {
    if (_latitude == null || _longitude == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _latitude!,
        _longitude!,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
          _city = place.locality;
        }

        _address = addressParts.isNotEmpty ? addressParts.join(', ') : null;
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
    }
  }

  /// Get location summary for AI context
  String getLocationSummary() {
    if (_city != null) {
      return _city!;
    } else if (_address != null) {
      return _address!;
    } else if (hasLocation) {
      return 'Lat: ${_latitude!.toStringAsFixed(2)}, Lng: ${_longitude!.toStringAsFixed(2)}';
    }
    return 'Unknown location';
  }
}
