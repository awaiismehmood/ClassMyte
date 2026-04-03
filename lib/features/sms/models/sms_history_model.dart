import 'package:cloud_firestore/cloud_firestore.dart';

class SmsHistory {
  final String id;
  final String message;
  final String tag; // 'General', 'Attendance', 'Fees', 'Event'
  final DateTime timestamp;
  final int totalRecipients;
  final int sentCount;
  final int failedCount;
  final List<String> recipients;

  SmsHistory({
    required this.id,
    required this.message,
    this.tag = 'General',
    required this.timestamp,
    required this.totalRecipients,
    required this.sentCount,
    required this.failedCount,
    required this.recipients,
  });

  factory SmsHistory.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SmsHistory(
      id: doc.id,
      message: data['message'] ?? '',
      tag: data['tag'] ?? 'General',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      totalRecipients: data['totalRecipients'] ?? 0,
      sentCount: data['sentCount'] ?? 0,
      failedCount: data['failedCount'] ?? 0,
      recipients: List<String>.from(data['recipients'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'tag': tag,
      'timestamp': Timestamp.fromDate(timestamp),
      'totalRecipients': totalRecipients,
      'sentCount': sentCount,
      'failedCount': failedCount,
      'recipients': recipients,
    };
  }
}
