import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/group.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GroupProvider();

  // Create a new group
  Future<void> createGroup(Group group) async {
    try {
      await _firestore.collection('groups').doc(group.groupId).set(group.toFirestore());
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  Future<String> fetchGroupName(String groupId) async {
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


  // Delete an existing group
  Future<void> deleteGroup(String groupId) async {
    try {
      // Fetch group data to get the list of members
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      final groupData = groupDoc.data();

      if (groupData != null && groupData.containsKey('members')) {
        List<String> members = List<String>.from(groupData['members']);
        
        // Remove group reference from each user
        for (String userId in members) {
          await _firestore.collection('users').doc(userId).update({
            'groupId': 'None',
          });
        }
      }
      // Finally, delete the group document itself
      await _firestore.collection('groups').doc(groupId).delete();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  // Add a user to a group and update UserProfileProvider
  Future<void> addUserToGroup(String userId, String groupId) async {
    try {
      DocumentReference groupDoc = _firestore.collection('groups').doc(groupId);
      await groupDoc.update({
        'members': FieldValue.arrayUnion([userId]),
      });

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
      DocumentReference groupDoc = _firestore.collection('groups').doc(groupId);
      await groupDoc.update({
        'members': FieldValue.arrayRemove([userId]),
      });

      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      await userDoc.update({
        'groupId': 'None',
      });
    } catch (e) {
      throw Exception('Failed to remove user from group: $e');
    }
  }
}
