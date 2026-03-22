// ignore_for_file: deprecated_member_use
import 'package:url_launcher/url_launcher.dart';

Future<void> makeCall(String phoneNumber) async {
  final Uri call = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );

  if (await canLaunch(call.toString())) {
    await launch(call.toString());
  }
}

Future<void> sendSMS(String phoneNumber) async {
  final Uri sms = Uri(
    scheme: 'sms',
    path: phoneNumber,
  );

  if (await canLaunch(sms.toString())) {
    await launch(sms.toString());
  }
}



