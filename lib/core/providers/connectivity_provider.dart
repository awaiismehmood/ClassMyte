import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { isOnline, isOffline }

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityNotifier() : super(ConnectivityStatus.isOnline) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.none)) {
        state = ConnectivityStatus.isOffline;
      } else {
        state = ConnectivityStatus.isOnline;
      }
    });

    // Initial check
    Connectivity().checkConnectivity().then((result) {
      if (result.contains(ConnectivityResult.none)) {
        state = ConnectivityStatus.isOffline;
      } else {
        state = ConnectivityStatus.isOnline;
      }
    });
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});
