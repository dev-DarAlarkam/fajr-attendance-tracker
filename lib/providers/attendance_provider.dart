import 'package:attendance_tracker/models/attendace.dart';
import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create attendance record
  Future<void> createAttendance(String userId, Attendance attendance) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      await userDoc.collection('attendance').add(attendance.toFirestore());
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create attendance record: $e');
    }
  }

  // Check if an attendance record exists for a specific date
  Future<bool> attendanceExists(String userId, DateTime date) async {
    try {
      String attendanceId =DateFormatUtils.formatDate(date);
      DocumentReference attendanceDoc = _firestore.collection('users').doc(userId).collection('attendance').doc(attendanceId);
      
      DocumentSnapshot docSnapshot = await attendanceDoc.get();
      return docSnapshot.exists;
    } catch (e) {
      throw Exception('Failed to check attendance record: $e');
    }
  }

  // Read attendance records
  Future<List<Attendance>> fetchAttendanceRecords(String userId) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      QuerySnapshot snapshot = await userDoc.collection('attendance').get();
      
      return snapshot.docs.map((doc) {
        return Attendance.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch attendance records: $e');
    }
  }

  Future<void> createOrUpdateAttendance(String userId, Attendance attendance) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      String attendanceId = attendance.attendanceId;
      
      // Use set() to create or overwrite the attendance record
      await userDoc.collection('attendance').doc(attendanceId).set(attendance.toFirestore());
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create or update attendance record: $e');
    }
  }


  // Delete attendance record
  Future<void> deleteAttendance(String userId, String attendanceId) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      await userDoc.collection('attendance').doc(attendanceId).delete();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete attendance record: $e');
    }
  }
}
