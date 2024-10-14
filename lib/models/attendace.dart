import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String attendanceId;         // Firestore-generated document ID
  final String userId;               // Firebase UID of the user
  final String groupId;              // Group ID if applicable
  final DateTime date;               // Date of attendance
  final String attendanceLocation;   // 'home', 'mosque1', 'mosque2', 'mosque3', or 'mosque4'

  Attendance({
    required this.attendanceId,
    required this.userId,
    required this.groupId,
    required this.date,
    required this.attendanceLocation,
  });

  factory Attendance.fromFirestore(Map<String, dynamic> data) {
    return Attendance(
      attendanceId: data['attendanceId'] ?? '',
      userId: data['userId'] ?? '',
      groupId: data['groupId'] ?? 'None',
      date: (data['date'] as Timestamp).toDate(),
      attendanceLocation: data['attendanceLocation'] ?? 'home',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'attendanceId': attendanceId,
      'userId': userId,
      'groupId': groupId,
      'date': date,
      'attendanceLocation': attendanceLocation,
    };
  }
}
