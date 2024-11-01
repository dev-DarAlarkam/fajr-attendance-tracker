import 'package:attendance_tracker/models/attendace.dart';
import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceServices {

  // Create attendance record
  Future<void> createAttendance(String userId, Attendance attendance) async {
    try {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      await userDoc.collection('attendance').add(attendance.toFirestore());
    } catch (e) {
      throw Exception('Failed to create attendance record: $e');
    }
  }

  Stream<bool> attendanceExists(String userId, DateTime date) {
    String attendanceId = DateFormatUtils.formatDate(date);
    DocumentReference attendanceDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .doc(attendanceId);

    return attendanceDoc.snapshots().map((docSnapshot) => docSnapshot.exists);
  }

  // Read attendance records
  Future<List<Attendance>> fetchAttendanceRecords(String userId) async {
    try {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
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
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      String attendanceId = attendance.attendanceId;
      
      // Use set() to create or overwrite the attendance record
      await userDoc.collection('attendance').doc(attendanceId).set(attendance.toFirestore());
    } catch (e) {
      throw Exception('Failed to create or update attendance record: $e');
    }
  }


  // Delete attendance record
  Future<void> deleteAttendance(String userId, String attendanceId) async {
    try {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      await userDoc.collection('attendance').doc(attendanceId).delete();
    } catch (e) {
      throw Exception('Failed to delete attendance record: $e');
    }
  }
}