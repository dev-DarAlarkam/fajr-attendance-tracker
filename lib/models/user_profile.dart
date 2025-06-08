enum Gender {male , female}

class UserProfile {
  final String uid;             // Firebase unique user ID
  final String firstName;
  final String fatherName;
  final String lastName;
  final String gender;
  final String birthday;
  final String grade;           
  final String groupId;         // "None" if user has no group
  final String rule;            // "user","teacher" or "admin"

  UserProfile({
    required this.uid,
    required this.firstName,
    required this.fatherName,
    required this.lastName,
    required this.gender,
    required this.birthday,
    required this.grade,
    required this.groupId,
    required this.rule,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] ?? '',
      firstName: data['firstName'] ?? '',
      fatherName: data['fatherName'] ?? '',
      lastName: data['lastName'] ?? '',
      gender: data['gender'] ?? '',
      birthday: data['birthday'] ?? '',
      grade: data['grade'] ?? 'None',
      groupId: data['groupId'] ?? 'None',
      rule: data['rule'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'firstName': firstName,
      'fatherName': fatherName,
      'lastName': lastName,
      'gender': gender,
      'birthday': birthday,
      'grade': grade,
      'groupId': groupId,
      'rule': rule,
    };
  }

  String get fullName => "$firstName $fatherName $lastName";

  static List<String> rules = ["user","teacher","admin"];


}