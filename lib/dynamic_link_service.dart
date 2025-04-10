import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkService {
  static Future<String> createDynamicLink(String guardianId, String studentId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: "https://autocaller.page.link",
      link: Uri.parse("https://autocaller.com/invite?guardianId=$guardianId&studentId=$studentId"),
      androidParameters: AndroidParameters(
        packageName: "com.example.autocaller",
        minimumVersion: 1,
      ),
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }
}