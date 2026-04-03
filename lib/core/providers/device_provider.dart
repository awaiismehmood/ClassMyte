import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceInfo {
  final String id;
  final String name;

  DeviceInfo({required this.id, required this.name});
}

final deviceInfoProvider = FutureProvider<DeviceInfo>((ref) async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  String name = 'Unknown Device';
  String id = 'unknown-id';

  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      name = '${androidInfo.manufacturer} ${androidInfo.model}';
      id = androidInfo.id; // Usually returns hardware ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      name = iosInfo.name;
      id = iosInfo.identifierForVendor ?? 'unknown-ios-id';
    }
  } catch (e) {
    // Fallback
  }

  return DeviceInfo(id: id, name: name);
});
