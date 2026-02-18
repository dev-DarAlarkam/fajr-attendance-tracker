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

class Teacher extends UserProfile {
  final List<String> groupIds;

  Teacher({
    required super.uid,
    required super.firstName,
    required super.fatherName,
    required super.lastName,
    required super.gender,
    required super.birthday,
    required super.grade,
    required super.rule,
    List<String> groupIds = const [],
  })  : groupIds = groupIds,
        super(groupId: 'None');

  factory Teacher.fromFirestore(Map<String, dynamic> data) {
    final groupIdsRaw = data['groupIds'];
    final List<String> groupIds = groupIdsRaw is List
        ? groupIdsRaw.map((e) => e?.toString() ?? '').toList()
        : [];
    return Teacher(
      uid: data['uid'] ?? '',
      firstName: data['firstName'] ?? '',
      fatherName: data['fatherName'] ?? '',
      lastName: data['lastName'] ?? '',
      gender: data['gender'] ?? '',
      birthday: data['birthday'] ?? '',
      grade: data['grade'] ?? 'None',
      rule: data['rule'] ?? 'teacher',
      groupIds: groupIds,
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      ...super.toFirestore(),
      'groupId': 'None',
      'groupIds': groupIds,
    };
  }
}