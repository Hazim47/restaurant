import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static Future<Map<String, dynamic>?> getLocation({
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ استخدم الكاش فقط إذا ما طلبت تحديث
    if (!forceRefresh) {
      final lat = prefs.getDouble("lat");
      final lng = prefs.getDouble("lng");
      final address = prefs.getString("address");

      if (lat != null && lng != null && address != null) {
        return {"lat": lat, "lng": lng, "address": address};
      }
    }

    try {
      // 🔐 الصلاحيات
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // 📍 جلب الموقع بدقة عالية
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double lat = position.latitude;
      double lng = position.longitude;

      // 🧠 تحويل لإسم منطقة
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      String city = "";
      String area = "";

      for (var place in placemarks) {
        if (city.isEmpty && place.locality != null) {
          city = place.locality!;
        }

        if (area.isEmpty &&
            place.subLocality != null &&
            place.subLocality!.isNotEmpty) {
          area = place.subLocality!;
        }

        if (city.isNotEmpty && area.isNotEmpty) break;
      }

      String locationName;

      if (area.isNotEmpty && city.isNotEmpty) {
        locationName = "$city - $area";
      } else if (city.isNotEmpty) {
        locationName = city;
      } else {
        locationName = "موقع غير معروف";
      }

      // 💾 تخزين بالكاش
      await prefs.setDouble("lat", lat);
      await prefs.setDouble("lng", lng);
      await prefs.setString("address", locationName);

      // 🔍 للتأكد (اختياري احذفه بعدين)
      print("LAT: $lat");
      print("LNG: $lng");

      return {"lat": lat, "lng": lng, "address": locationName};
    } catch (e) {
      print("Location Error: $e");
      return null;
    }
  }
}
