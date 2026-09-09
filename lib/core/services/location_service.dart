import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return null;
    }
  }

  PrayerTimes? getPrayerTimes(Position position) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    
    // Set parameters using Umm al-Qura calculation method (highly popular in Islamic world)
    final params = CalculationMethod.umm_al_qura.getParameters();
    params.madhab = Madhab.shafi;

    final dateComponents = DateComponents.from(DateTime.now());
    return PrayerTimes(coordinates, dateComponents, params);
  }

  // Calculate direction of Qibla (Kaaba) in degrees from True North
  // Kaaba location: Latitude: 21.4225, Longitude: 39.8262
  double calculateQiblaDirection(double latitude, double longitude) {
    const double kaabaLat = 21.422487;
    const double kaabaLng = 39.826206;

    double latRad = latitude * math.pi / 180.0;
    double lngRad = longitude * math.pi / 180.0;
    double kLatRad = kaabaLat * math.pi / 180.0;
    double kLngRad = kaabaLng * math.pi / 180.0;

    double diffLng = kLngRad - lngRad;

    double y = math.sin(diffLng);
    double x = math.cos(latRad) * math.tan(kLatRad) - math.sin(latRad) * math.cos(diffLng);

    double qiblaRad = math.atan2(y, x);
    double qiblaDeg = qiblaRad * 180.0 / math.pi;

    return (qiblaDeg + 360.0) % 360.0;
  }

  Stream<CompassEvent>? getCompassStream() {
    return FlutterCompass.events;
  }
}
