import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert' show utf8;

class Group {
  final String groupId;              
  final String groupName;
  final String gradeLevel;           // Grade level associated with the group
  final List<String> members;        // List of user IDs
  final String teacherId;            // teacher ID

  Group({
    required this.groupId,
    required this.groupName,
    required this.gradeLevel,
    required this.members,
    required this.teacherId,
  });

  factory Group.fromFirestore(Map<String, dynamic> data) {
    return Group(
      groupId: data['groupId'] ?? '',
      groupName: data['groupName'] ?? 'None',
      gradeLevel: data['gradeLevel'] ?? 'None',
      members: List<String>.from(data['members'] ?? []),
      teacherId: data['teacherId'] ?? 'None',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'gradeLevel': gradeLevel,
      'members': members,
      'teacherId': teacherId,
    };
  }

  static String generateGroupJoinMessage(Group group){
    String message = '${Dictionary.welcome} \nإنضم لمجموعة ${group.groupName} في برنامج الفجر الجديد \nرمز المجموعة: ${group.groupId}';
    return message;
  }

  static String generateGroupId() {
    String start = DateTime.now().microsecondsSinceEpoch.toString();
    final bytes = utf8.encode(start); // Encode input as bytes
    final hash = sha256.convert(bytes); // Create SHA-256 hash
    String id = hash.toString().substring(0, 5).toUpperCase(); // Truncate and uppercase
    return 'group_$id';
  }
}
