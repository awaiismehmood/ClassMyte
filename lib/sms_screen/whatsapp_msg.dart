// whatsapp_messaging.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppMessaging {
  // Function to send WhatsApp messages individually
  Future<void> sendWhatsAppMessageIndividually(String phoneNumber) async {
      // String url = "https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}";
      String url = "https://wa.me/$phoneNumber";

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    
  }
  }

