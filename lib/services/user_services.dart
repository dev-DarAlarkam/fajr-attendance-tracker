import 'package:attendance_tracker/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileServices {

  final _firestore = FirebaseFirestore.instance;
  
  Future<void> updateUserProfile(UserProfile profile) async {
    // Update userProfile
    try {
      // Update user profile
      final doc = await _firestore.collection('users').doc(profile.uid).get();
      
      if (doc.exists) {
        await _firestore.collection('users').doc(profile.uid).set(profile.toFirestore());
      } else {
        throw Exception('Failed to fetch user Profile');
      }

    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> changeUserRule(String userId, String rule) async {
    try {

      // Update user profile
      final doc = _firestore.collection('users').doc(userId);
      
      await doc.update({
        'rule': rule,
      });

      if (rule == UserProfile.rules[1]) {
        await doc.update({
          'groupsId': FieldValue.arrayUnion([]),
        });
      }

    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      // Delete user profile
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete userProfile: $e');
    }
  }

  Future<UserProfile> getUserProfile(String userId) async {
    // Update user profile
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserProfile.fromFirestore(doc.data()!);
      } else {
        throw Exception('Failed to fetch user Profile');
      }

    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<List<UserProfile>> getUsersProfile() async {
    // Get users
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      
      return snapshot.docs.map((doc) {
        return UserProfile.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch attendance records: $e');
    }
  }

  Stream<List<UserProfile>> getUsersProfileStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserProfile.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}