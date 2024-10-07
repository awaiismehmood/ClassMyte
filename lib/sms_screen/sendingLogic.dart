// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageSender {
  static const platform = MethodChannel('com.example.sms/sendSMS');
  static const String ongoingProcessKey = 'ongoingProcess';

  static Future<bool> checkSmsPermission() async {
    final PermissionStatus status = await Permission.sms.status;
    if (status.isDenied) {
      final PermissionStatus permissionStatus = await Permission.sms.request();
      return permissionStatus.isGranted;
    }
    return true;
  }

 static Future<void> sendMessages(
  List<String> phoneNumbers,
  String message,
  int delay,
  ValueNotifier<bool> sendingMessage,
  ValueNotifier<String> messageStatus,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(ongoingProcessKey, true);
  sendingMessage.value = true;
  messageStatus.value = 'Sending Messages...';

  if (phoneNumbers.isNotEmpty) {
    try {
      await _startForegroundService(phoneNumbers, message, delay);
      await Future.delayed(Duration(seconds: delay * phoneNumbers.length));
      messageStatus.value = 'Messages sent successfully!';
    } catch (error) {
      messageStatus.value = 'Failed to send messages: $error';
    } finally {
      await prefs.setBool(ongoingProcessKey, false);
      sendingMessage.value = false;
    }
  } else {
    messageStatus.value = 'No contacts available to send the message.';
    await prefs.setBool(ongoingProcessKey, false);
    sendingMessage.value = false;
  }
}



  static Future<void> cancelMessageSending(
  ValueNotifier<bool> sendingMessage,
  ValueNotifier<String> messageStatus,
) async {
  if (sendingMessage.value) {
    sendingMessage.value = false;
    messageStatus.value = 'Message sending cancelled.';
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ongoingProcessKey, false);
    await _stopForegroundService(); // Stop the service immediately
  }
}


  static Future<void> _stopForegroundService() async {
    try {
      await platform.invokeMethod('stopService');
      print('Service stopped.');
    } on PlatformException catch (e) {
      print("Failed to stop service: '${e.message}'");
    }
  }

  static Future<void> _startForegroundService(
      List<String> phoneNumbers, String message, int delay) async {
    try {
      final result = await platform.invokeMethod('sendSMS', {
        'phoneNumbers': phoneNumbers,
        'message': message,
        'delay': delay,
      });
      print('Service started: $result');
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'");
    }
  }
}
