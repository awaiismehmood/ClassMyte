// ignore_for_file: deprecated_member_use
import 'package:url_launcher/url_launcher.dart';

class WhatsAppMessaging {
  Future<void> sendWhatsAppMessageIndividually(String phoneNumber) async {
      String url = "https://wa.me/$phoneNumber";

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    
  }
  }

