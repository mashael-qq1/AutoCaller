import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GeofenceManager {
  static double schoolLatitude =24.738483176290046;//24.723505426774846;  46.61349771880103
  static double schoolLongitude = 46.61349771880103;//46.63647225854474;
  static double geofenceRadius = 200.0;
  static StreamSubscription<Position>? _positionSubscription;

  // Start monitoring location
  static void startGeofenceMonitoring() async {
    await _positionSubscription?.cancel();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print("❌ Location permission denied.");
      return;
    }
    print("📍 Starting geofence monitoring...");
    print("📍 School location: (\$schoolLatitude, \$schoolLongitude)");
    print("📏 Geofence radius: \$geofenceRadius meters");
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position? position) async {
      if (position == null) {
        print("❌ Position is null.");
        return;
      }
      final userLat = position.latitude;
      final userLng = position.longitude;
      print("📍 User location: (${userLat}, ${userLng})");
      double distance;
      try {
        distance = Geolocator.distanceBetween(userLat, userLng, schoolLatitude, schoolLongitude);
      } catch (e) {
        print("❌ Error calculating distance: \$e");
        return;
      }
      print("📏 Distance to school: \${distance.toStringAsFixed(2)} meters");
      if (distance <= geofenceRadius) {
        print("✅ User is INSIDE the geofence.");
        await _updateGuardianStatus(true);
      } else {
        print("❌ User is OUTSIDE the geofence.");
        await _updateGuardianStatus(false);
      }
    });
  }

  static Future<void> _updateGuardianStatus(bool arrived) async {
    print("🔁 _updateGuardianStatus called with arrived = ${arrived}");

    String guardianId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (guardianId.isEmpty) {
      print("❌ No signed-in user.");
      return;
    }

    DocumentSnapshot guardianSnapshot = await FirebaseFirestore.instance
        .collection("Primary Guardian")
        .doc(guardianId)
        .get();

    if (!guardianSnapshot.exists) {
      guardianSnapshot = await FirebaseFirestore.instance
          .collection("Secondary Guardian")
          .doc(guardianId)
          .get();
    }

    if (!guardianSnapshot.exists) {
      print("❌ Guardian not found in Firestore.");
      return;
    }

    print("📝 Updating Guardian status in Firestore...");
    Timestamp currentTimestamp = Timestamp.now();
    await guardianSnapshot.reference.update({
      "arrived": arrived,
      "timestamp": FieldValue.serverTimestamp(),
    });
final data = guardianSnapshot.data() as Map<String, dynamic>?;

List<dynamic> children = [];
if (data != null && data.containsKey('children')) {
  children = data['children'] ?? [];
}


    
    for (var childRef in children) {
      if (childRef is DocumentReference) {
        print("🧒 Updating child document: \${childRef.path}");
        await childRef.update({"readyForPickup": arrived});
        await childRef.update({"timestamp": currentTimestamp});
        
      }
    }
  }

  static void updateSchoolLocation(double latitude, double longitude) async {
    schoolLatitude = latitude;
    schoolLongitude = longitude;

    print("📍 School location manually updated to: (\$latitude, \$longitude)");
    startGeofenceMonitoring();

    // Immediately check user's current location against the new geofence center
    Position currentPosition = await Geolocator.getCurrentPosition();
    double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      schoolLatitude,
      schoolLongitude,
    );

    print("📏 Distance to new school location: \${distance.toStringAsFixed(2)} meters");

    if (distance <= geofenceRadius) {
      print("✅ User is INSIDE the new geofence.");
      await _updateGuardianStatus(true);
    } else {
      print("❌ User is OUTSIDE the new geofence.");
      await _updateGuardianStatus(false);
    }
  }
} 
