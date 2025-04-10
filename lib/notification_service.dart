import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  // Your Server Key from Firebase Cloud Messaging
  static const String serverKey =
      'BLCIoXmBAMnLvvq9bTvqNxqJUWc4aY8mXrYyce8p--KTJ5LK-aS65KAz70vHtC_0oYlqrm7IjVqldpbbd12k72E';

  static Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully.');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}