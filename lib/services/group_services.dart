import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/group.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupServices{
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new group
  Future<void> createGroup(Group group) async {
    try {
      await _firestore.collection('groups').doc(group.groupId).set(group.toFirestore());
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  // Fetch a group by its ID
  Future<Group> fetchGroup(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (doc.exists) {
        return Group.fromFirestore(doc.data()!);
      } else {
        throw Exception('Failed to fetch group');
      }
    } catch (e) {
      throw Exception('Failed to fetch group: $e');
    }
  }

  Future<String> fetchGroupName(String groupId) async {
    if (groupId == AppConstants.none) {
      return AppConstants.none;
    }

    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (doc.exists) {
        final group = Group.fromFirestore(doc.data()!);
        return group.groupName;
      } else {
        throw Exception('Failed to fetch group');
      }
    } catch (e) {
      throw Exception('Failed to fetch group: $e');
    }
  }

  Future<Map<String,String>> fetchGroupNames() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('groups').get();
      Map<String,String> groupNames = {};

      for(var doc in snapshot.docs) {
        final group = Group.fromFirestore(doc.data() as Map<String, dynamic>);
        final groupName = <String,String>{group.groupId: group.groupName};
        groupNames.addEntries(groupName.entries);
      }

      return groupNames;

    } catch (e) {
      throw Exception('Failed to fetch attendance records: $e');
    }
  }

  // Delete an existing group
  Future<void> deleteGroup(String groupId) async {
    try {
      // Fetch group data to get the list of members
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      final doc = groupDoc.data();

      if (doc != null && doc.containsKey('members')) {
        List<String> members = List<String>.from(doc['members']);
        
        // Remove group reference from each user
        for (String userId in members) {
          await _firestore.collection('users').doc(userId).update({
            'groupId': 'None',
          });
        }
      }
      // Finally, delete the group document itself
      await _firestore.collection('groups').doc(groupId).delete();
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  // Add a user to a group and update UserProfileProvider
  Future<void> addUserToGroup(String userId, String groupId) async {
    try {

      // Updating the group members list
      DocumentReference groupDoc = _firestore.collection('groups').doc(groupId);
      await groupDoc.update({
        'members': FieldValue.arrayUnion([userId]),
      });
      
      // Updating the user's group ID
      DocumentReference userDoc = _firestore.collection('users').doc(userId);

      final doc = await _firestore.collection('users').doc(userId).get();
      UserProfile? userProfile = UserProfile.fromFirestore(doc.data()!);

      if(userProfile.groupId != AppConstants.none){
        await removeUserFromGroup(userProfile.uid, userProfile.grade);
      }

      await userDoc.update({
        'groupId': groupId,
      });
    } catch (e) {
      throw Exception('Failed to add user to group: $e');
    }
  }

  // Remove a user from a group and update UserProfileProvider
  Future<void> removeUserFromGroup(String userId, String groupId) async {
    try {
      // Updating the group members list
      DocumentReference groupDoc = _firestore.collection('groups').doc(groupId);
      await groupDoc.update({
        'members': FieldValue.arrayRemove([userId]),
      });

      // Updating the user's group ID
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      await userDoc.update({
        'groupId': 'None',
      });
    } catch (e) {
      throw Exception('Failed to remove user from group: $e');
    }
  }


  Future<void> assignTeachertoGroup(String teacherId, String groupId) async {
    try {

      // Updating the group's teacherId
      final doc = await _firestore.collection('groups').doc(groupId).get();

      if (doc.exists) {
        Group? group = Group.fromFirestore(doc.data()!);
        if (group.teacherId != 'None') {
          await removeTeacherFromGroup(group.teacherId, groupId);
        }
      }

      DocumentReference groupDoc = _firestore.collection('groups').doc(groupId);
      await groupDoc.update({
        'teacherId': teacherId,
      });

      // Updating Teacher's group list
      DocumentReference userDoc = _firestore.collection('users').doc(teacherId);
      await userDoc.update({
        'groupsId': FieldValue.arrayUnion([groupId]),
      });
    } catch (e) {
      throw Exception('Failed to assign teacher to group: $e');
    }
  }

  Future<void> removeTeacherFromGroup(String teacherId, String groupId) async {
    try {
      DocumentReference groupDoc = _firestore.collection('groups').doc(groupId);
      await groupDoc.update({
        'teacher': 'None',
      });

      DocumentReference userDoc = _firestore.collection('users').doc(teacherId);
      await userDoc.update({
        'groupsId': FieldValue.arrayRemove([groupId]),
      });
    } catch (e) {
      throw Exception('Failed to remove teacher from group: $e');
    }
  }


  Future<int> fetchGroupCountByDate(String groupId, DateTime  date) async {
    try {
      final snapshot = await _firestore.collection('counts').doc(groupId).get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey(DateFormatUtils.formatDate(date))) {
          return data[date.toString()];
        }
      }
      return 0;
    } catch (e) {
      throw Exception('Failed to fetch group count: $e');
    }
  }
}
