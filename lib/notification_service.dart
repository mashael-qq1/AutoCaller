import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class NotificationService {
  static const String projectId = 'autocaller-196cc';

  /// Call Cloud Run Function to notify Primary Guardian
  static Future<void> callSecondaryGuardianArrival({
    required String primaryGuardianID,
    required String secondaryGuardianName,
  }) async {
    final url = Uri.parse(
        'https://us-central1-autocaller-196cc.cloudfunctions.net/onSecondaryGuardianArrival');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'primaryGuardianID': primaryGuardianID,
          'secondaryGuardianName': secondaryGuardianName,
        }),
      );

      print('🌐 Cloud Function Response Code: ${response.statusCode}');
      print('🌐 Cloud Function Response Body: ${response.body}');
    } catch (e) {
      print('❌ Error calling Cloud Run Function: $e');
    }
  }

  /// Generate Auth Client for sending FCM Notification
  static Future<AutoRefreshingAuthClient> _getAuthClient() async {
    final serviceAccountJson =
        await rootBundle.loadString('assets/service-account.json');

    final accountCredentials =
        ServiceAccountCredentials.fromJson(serviceAccountJson);

    return clientViaServiceAccount(
      accountCredentials,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );
  }

  /// Send FCM Notification directly (using service account)
  static Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      final client = await _getAuthClient();

      final response = await client.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "message": {
            "token": token,
            "notification": {
              "title": title,
              "body": body,
            },
          },
        }),
      );

      print('✅ Notification Status Code: ${response.statusCode}');
      print('✅ Notification Body: ${response.body}');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }
}