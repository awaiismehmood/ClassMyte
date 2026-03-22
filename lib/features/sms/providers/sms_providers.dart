import 'dart:async';
import 'dart:convert';
import 'package:classmyte/features/students/models/student_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/features/sms/data/sms_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    );
  }
}

class SmsProgressNotifier extends StateNotifier<SmsProgressState> {
  static const _eventChannel = EventChannel('com.alnoor.sms/progress');
  static const _prefKey = 'sms_progress_state';
  final SharedPreferences _prefs;
  StreamSubscription? _subscription;

  SmsProgressNotifier(this._prefs) : super(SmsProgressState()) {
    _loadState();
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
      } catch (e) {
        print("Error loading SMS state: $e");
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

  void startListening() {
    _subscription?.cancel();
    _subscription = _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final data = Map<String, dynamic>.from(event);
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
      }
    });
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
  return SmsProgressNotifier(prefs);
});


/// Holds a pre-selected list of contacts passed from the Students screen.
/// When non-null, the SMS screen sends ONLY to these contacts (premium feature).
final preSelectedContactsProvider = StateProvider<List<Student>?>((ref) => null);
