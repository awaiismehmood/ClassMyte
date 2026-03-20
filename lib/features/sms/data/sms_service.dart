// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageSender {
  static const platform = MethodChannel('com.alnoor.sms/sendSMS');
  static const String ongoingProcessKey = 'ongoingProcess';

  static Future<bool> checkSmsPermission() async {
    final PermissionStatus status = await Permission.sms.status;
    if (status.isDenied) {
      final PermissionStatus permissionStatus = await Permission.sms.request();
      return permissionStatus.isGranted;
    }
    return true;
  }

  static Future<void> sendMessages({
    required List<String> phoneNumbers,
    required List<String> names,
    required String message,
    required int delay,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ongoingProcessKey, true);

    if (phoneNumbers.isNotEmpty) {
      try {
        await _startForegroundService(phoneNumbers, names, message, delay);
      } catch (error) {
        print('Failed to start native service: $error');
      }
    }
  }

  static Future<void> cancelMessageSending() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ongoingProcessKey, false);
    await _stopForegroundService();
  }

  static Future<void> _stopForegroundService() async {
    try {
      await platform.invokeMethod('stopService');
      print('Cancel action sent to service');
    } on PlatformException catch (e) {
      print("Failed to stop service: '${e.message}'");
    }
  }

  static Future<void> _startForegroundService(
      List<String> phoneNumbers, List<String> names, String message, int delay) async {
    try {
      final result = await platform.invokeMethod('sendSMS', {
        'phoneNumbers': phoneNumbers,
        'names': names,
        'message': message,
        'delay': delay,
      });
      print('Service started: $result');
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'");
    }
  }

  static Future<bool> isServiceRunning() async {
    try {
      final bool? isRunning = await platform.invokeMethod('isServiceRunning');
      return isRunning ?? false;
    } on PlatformException catch (e) {
      print("Failed to check service status: ${e.message}");
      return false;
    }
  }
}

