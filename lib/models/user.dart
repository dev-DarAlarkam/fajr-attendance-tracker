class User {
  final String uid;             // Firebase unique user ID
  final String firstName;
  final String fatherName;
  final String lastName;
  final String grade;           // "None" if not applicable
  final String groupId;         // "None" if user has no group
  final bool isAdmin;

  User({
    required this.uid,
    required this.firstName,
    required this.fatherName,
    required this.lastName,
    required this.grade,
    required this.groupId,
    required this.isAdmin,
  });

  factory User.fromFirestore(Map<String, dynamic> data) {
    return User(
      uid: data['uid'] ?? '',
      firstName: data['firstName'] ?? '',
      fatherName: data['fatherName'] ?? '',
      lastName: data['lastName'] ?? '',
      grade: data['grade'] ?? 'None',
      groupId: data['groupId'] ?? 'None',
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'firstName': firstName,
      'fatherName': fatherName,
      'lastName': lastName,
      'grade': grade,
      'groupId': groupId,
      'isAdmin': isAdmin,
    };
  }


  get fullName => "$firstName $fatherName $lastName";
  
}
