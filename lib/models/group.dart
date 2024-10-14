class Group {
  final String groupId;              // Firestore-generated group ID
  final String groupName;
  final String description;
  final String gradeLevel;           // Grade level associated with the group
  final List<String> members;        // List of user IDs

  Group({
    required this.groupId,
    required this.groupName,
    required this.description,
    required this.gradeLevel,
    required this.members,
  });

  factory Group.fromFirestore(Map<String, dynamic> data) {
    return Group(
      groupId: data['groupId'] ?? '',
      groupName: data['groupName'] ?? '',
      description: data['description'] ?? '',
      gradeLevel: data['gradeLevel'] ?? 'None',
      members: List<String>.from(data['members'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'description': description,
      'gradeLevel': gradeLevel,
      'members': members,
    };
  }
}
