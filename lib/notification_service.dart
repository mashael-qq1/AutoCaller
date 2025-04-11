import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class NotificationService {
  static const String projectId = 'autocaller-196cc';

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

  static Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      final client = await _getAuthClient();

      final response = await client.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
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