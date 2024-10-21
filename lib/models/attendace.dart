import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String attendanceId;         // Firestore-generated document ID
  final String userId;               // Firebase UID of the user
  final DateTime date;               // Date of attendance
  final String attendanceLocation;   // 'home', 'mosque1', 'mosque2', 'mosque3', or 'mosque4'
  final String otherLocation;
  final int score;

  Attendance({
    required this.attendanceId,
    required this.userId,
    required this.date,
    required this.attendanceLocation,
    required this.otherLocation,
    required this.score
  });

  factory Attendance.fromFirestore(Map<String, dynamic> data) {
    return Attendance(
      attendanceId: data['attendanceId'] ?? '',
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      attendanceLocation: data['attendanceLocation'] ?? 'home',
      otherLocation: data['otherLocation'] ?? 'none',
      score: data['score'] ?? 0
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'attendanceId': attendanceId,
      'userId': userId,
      'date': date,
      'attendanceLocation': attendanceLocation,
      'otherLocation' : otherLocation,
      'score' : score
    };
  }

  //TODO: change it based on your mousque list
  static Map<String,String> get mousqueList => {
    "home" : "البيت",
    "mosque_1" : "مسجد الفردوس - الظهرات",
    "mosque_2" : "مسجد الهدى القديم",
    "mosque_3" : "مسجد التقوى",
    "mosque_4" : "مسجد الرحمة",
    "other" : "آخر",
  };

  //TODO: change the values based on your preference
  static int calculateScore(String location) {
    switch (location) {
      //حاضر
      case "home":
        return 1;
      //جماعة
      case "mosque_1" :
      case "mosque_2" :
      case "mosque_3" :
      case "mosque_4" :
      case "other" :
        return 2;  
      //خطأ
      default:
        return 0;
    }
  }

}
