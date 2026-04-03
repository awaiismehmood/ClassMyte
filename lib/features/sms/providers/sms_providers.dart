import 'dart:async';
import 'dart:convert';
import 'package:classmyte/features/students/models/student_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/features/sms/data/sms_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classmyte/main.dart'; // import talker
import 'package:classmyte/core/database/database_provider.dart';
import 'package:classmyte/core/database/local_database.dart' hide Student;
import 'package:classmyte/core/providers/device_provider.dart' as dev;

class SmsProgressState {
  final String status; // 'idle', 'sending', 'completed', 'cancelled'
  final int total;
  final int sent;
  final int failed;
  final int currentIndex;
  final String currentName;
  final String currentNumber;
  final String lastMessage;
  final List<Map<String, String>> failedList;
  final String tag; 

  final String deviceId;
  final String deviceName;

  SmsProgressState({
    this.status = 'idle',
    this.total = 0,
    this.sent = 0,
    this.failed = 0,
    this.currentIndex = 0,
    this.currentName = '',
    this.currentNumber = '',
    this.lastMessage = '',
    this.failedList = const [],
    this.tag = 'General',
    this.deviceId = '',
    this.deviceName = '',
  });

  Map<String, dynamic> toJson() => {
    'status': status,
    'total': total,
    'sent': sent,
    'failed': failed,
    'currentIndex': currentIndex,
    'currentName': currentName,
    'currentNumber': currentNumber,
    'lastMessage': lastMessage,
    'failedList': failedList,
    'tag': tag,
    'deviceId': deviceId,
    'deviceName': deviceName,
  };

  factory SmsProgressState.fromJson(Map<String, dynamic> json) => SmsProgressState(
    status: json['status'] ?? 'idle',
    total: json['total'] ?? 0,
    sent: json['sent'] ?? 0,
    failed: json['failed'] ?? 0,
    currentIndex: json['currentIndex'] ?? 0,
    currentName: json['currentName'] ?? '',
    currentNumber: json['currentNumber'] ?? '',
    lastMessage: json['lastMessage'] ?? '',
    tag: json['tag'] ?? 'General',
    deviceId: json['deviceId'] ?? '',
    deviceName: json['deviceName'] ?? '',
    failedList: json['failedList'] != null 
        ? List<Map<String, String>>.from((json['failedList'] as List).map((e) => Map<String, String>.from(e)))
        : [],
  );

  SmsProgressState copyWith({
    String? status,
    int? total,
    int? sent,
    int? failed,
    int? currentIndex,
    String? currentName,
    String? currentNumber,
    String? lastMessage,
    List<Map<String, String>>? failedList,
    String? tag,
    String? deviceId,
    String? deviceName,
  }) {
    return SmsProgressState(
      status: status ?? this.status,
      total: total ?? this.total,
      sent: sent ?? this.sent,
      failed: failed ?? this.failed,
      currentIndex: currentIndex ?? this.currentIndex,
      currentName: currentName ?? this.currentName,
      currentNumber: currentNumber ?? this.currentNumber,
      lastMessage: lastMessage ?? this.lastMessage,
      failedList: failedList ?? this.failedList,
      tag: tag ?? this.tag,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
    );
  }
}

class SmsProgressNotifier extends StateNotifier<SmsProgressState> {
  static const _eventChannel = EventChannel('com.alnoor.sms/progress');
  static const _prefKey = 'sms_progress_state';
  final SharedPreferences _prefs;
  final LocalDatabase _localDb;
  final Ref _ref;
  StreamSubscription? _subscription;
  StreamSubscription? _cloudSubscription;
  DateTime _lastCloudUpdate = DateTime.now();

  SmsProgressNotifier(this._prefs, this._localDb, this._ref) : super(SmsProgressState()) {
    _loadState();
    _startCloudListener();
  }

  void _loadState() {
    final String? jsonStr = _prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        state = SmsProgressState.fromJson(json.decode(jsonStr));
        if (state.status == 'sending') {
          startListening();
          // Double check if native service is still alive
          MessageSender.isServiceRunning().then((isRunning) {
            if (!isRunning && state.status == 'sending') {
               state = state.copyWith(status: 'idle');
               _saveState();
            }
          });
        }
      } catch (e, s) {
        talker.error("Error loading SMS state", e, s);
      }
    }
  }

  void _saveState() {
    _prefs.setString(_prefKey, json.encode(state.toJson()));
  }

  void setLastMessage(String msg) {
    state = state.copyWith(lastMessage: msg);
    _saveState();
  }

  void setTag(String tag) {
    state = state.copyWith(tag: tag);
    _saveState();
  }

  void startListening() {
    _subscription?.cancel();
    _subscription = _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final data = Map<String, dynamic>.from(event);
        final bool isTaskDone = data['status'] == 'completed' || data['status'] == 'cancelled';
        
        if (data['status'] == 'completed' && state.status == 'sending') {
          _saveToHistory(state.copyWith(
            sent: data['sent'],
            failed: data['failed'],
            total: data['total'],
          ));
        }

        // Only update local ID info if it matches OR if it's our own local sending process
        state = state.copyWith(
          status: data['status'],
          total: data['total'],
          sent: data['sent'],
          failed: data['failed'],
          currentIndex: data['index'],
          currentName: data['currentName'],
          currentNumber: data['currentNumber'],
          failedList: data['failedList'] != null 
              ? List<Map<String, String>>.from(
                  (data['failedList'] as List).map((e) => Map<String, String>.from(e)))
              : null,
        );

        _saveState();
        
        // Update Cloud Process periodically
        _syncToCloud();
        
        if (isTaskDone) {
          _clearCloudProcess();
        }
      }
    });
  }

  void _startCloudListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _cloudSubscription?.cancel();
    _cloudSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('status')
        .doc('active_process')
        .snapshots()
        .listen((snapshot) async {
       if (snapshot.exists) {
         final data = snapshot.data() as Map<String, dynamic>;
         final remoteDeviceId = data['deviceId'];
         
         // Only adopt cloud progress if it's NOT our local device
         // This provides the "Live Progress View" for Phone B
         final localDevice = await _ref.read(dev.deviceInfoProvider.future);
         if (remoteDeviceId != localDevice.id && data['status'] == 'sending') {
           state = state.copyWith(
             status: 'sending',
             total: data['total'],
             sent: data['sent'],
             failed: data['failed'],
             currentIndex: data['index'],
             currentName: data['currentName'],
             currentNumber: data['currentNumber'],
             deviceId: remoteDeviceId,
             deviceName: data['deviceName'],
             tag: data['tag'],
             lastMessage: data['lastMessage'],
           );
           _saveState();
         }
       } else if (state.deviceId.isNotEmpty) {
         // Process cleared from cloud, if we were tracking it, idle now
         final localDevice = await _ref.read(dev.deviceInfoProvider.future);
         if (state.deviceId != localDevice.id) {
           state = state.copyWith(status: 'idle', deviceId: '', deviceName: '');
           _saveState();
         }
       }
    });
  }

  Future<void> _syncToCloud() async {
    // Throttling: Only sync every 5 seconds or every 5 messages
    final now = DateTime.now();
    if (now.difference(_lastCloudUpdate).inSeconds < 5 && state.currentIndex % 5 != 0) return;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final localDevice = await _ref.read(dev.deviceInfoProvider.future);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('status')
          .doc('active_process')
          .set({
            'status': state.status,
            'total': state.total,
            'sent': state.sent,
            'failed': state.failed,
            'index': state.currentIndex,
            'currentName': state.currentName,
            'currentNumber': state.currentNumber,
            'deviceId': localDevice.id,
            'deviceName': localDevice.name,
            'tag': state.tag,
            'lastMessage': state.lastMessage,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      _lastCloudUpdate = now;
    } catch (e) {
      talker.error("Failed to sync progress to cloud: $e");
    }
  }

  Future<void> _clearCloudProcess() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final localDevice = await _ref.read(dev.deviceInfoProvider.future);
      
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('status')
          .doc('active_process')
          .get();
          
      if (doc.exists && doc.data()?['deviceId'] == localDevice.id) {
        await doc.reference.delete();
      }
    } catch (e) {
      talker.error("Failed to clear cloud process: $e");
    }
  }

  Future<void> _saveToHistory(SmsProgressState finalProgress) async {
    try {
      // 1. Save locally (always works offline)
      await _localDb.into(_localDb.smsHistoryTable).insert(
        SmsHistoryTableCompanion.insert(
          tag: finalProgress.tag,
          message: finalProgress.lastMessage,
          totalRecipients: finalProgress.total,
          sentCount: finalProgress.sent,
          failedCount: finalProgress.failed,
        ),
      );
      talker.log("Saved SMS to local history");

      // 2. Save to Firestore (works offline with Firestore persistence, but let's be explicit)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('sms_history')
            .add({
          'message': finalProgress.lastMessage,
          'tag': finalProgress.tag,
          'timestamp': Timestamp.now(),
          'totalRecipients': finalProgress.total,
          'sentCount': finalProgress.sent,
          'failedCount': finalProgress.failed,
        });
        talker.log("Saved SMS to Firestore history");
      }
    } catch (e, s) {
      talker.error("Error saving history", e, s);
    }
  }

  void reset() {
    state = SmsProgressState();
    _prefs.remove(_prefKey);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final smsProgressProvider = StateNotifierProvider<SmsProgressNotifier, SmsProgressState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final db = ref.watch(localDatabaseProvider);
  return SmsProgressNotifier(prefs, db, ref);
});

class SmsSessionState {
  final List<String> selectedClasses;
  final int selectedDelay;
  final bool excludeInactive;
  final bool includePersonalization;
  final bool inlinePrefix;
  final bool inlineSuffix;
  final String tag;

  SmsSessionState({
    this.selectedClasses = const [],
    this.selectedDelay = 30,
    this.excludeInactive = false,
    this.includePersonalization = false,
    this.inlinePrefix = false,
    this.inlineSuffix = false,
    this.tag = 'General',
  });

  SmsSessionState copyWith({
    List<String>? selectedClasses,
    int? selectedDelay,
    bool? excludeInactive,
    bool? includePersonalization,
    bool? inlinePrefix,
    bool? inlineSuffix,
    String? tag,
  }) {
    return SmsSessionState(
      selectedClasses: selectedClasses ?? this.selectedClasses,
      selectedDelay: selectedDelay ?? this.selectedDelay,
      excludeInactive: excludeInactive ?? this.excludeInactive,
      includePersonalization: includePersonalization ?? this.includePersonalization,
      inlinePrefix: inlinePrefix ?? this.inlinePrefix,
      inlineSuffix: inlineSuffix ?? this.inlineSuffix,
      tag: tag ?? this.tag,
    );
  }
}

class SmsSessionNotifier extends StateNotifier<SmsSessionState> {
  SmsSessionNotifier() : super(SmsSessionState());

  void setClasses(List<String> classes) => state = state.copyWith(selectedClasses: classes);
  void toggleClass(String className) {
    final current = List<String>.from(state.selectedClasses);
    if (current.contains(className)) {
      current.remove(className);
    } else {
      current.add(className);
    }
    state = state.copyWith(selectedClasses: current);
  }
  
  void setDelay(int delay) => state = state.copyWith(selectedDelay: delay);
  void setExcludeInactive(bool val) => state = state.copyWith(excludeInactive: val);
  void setPersonalization(bool val) => state = state.copyWith(includePersonalization: val);
  void setInlinePrefix(bool val) => state = state.copyWith(inlinePrefix: val);
  void setInlineSuffix(bool val) => state = state.copyWith(inlineSuffix: val);
  void setTag(String tag) => state = state.copyWith(tag: tag);
  
  void reset() => state = SmsSessionState();
}

final smsSessionProvider = StateNotifierProvider<SmsSessionNotifier, SmsSessionState>((ref) => SmsSessionNotifier());


/// Holds a pre-selected list of contacts passed from the Students screen.
/// When non-null, the SMS screen sends ONLY to these contacts (premium feature).
final preSelectedContactsProvider = StateProvider.autoDispose<List<Student>?>((ref) => null);
