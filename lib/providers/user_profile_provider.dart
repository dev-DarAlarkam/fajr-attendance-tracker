import 'package:attendance_tracker/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

class UserProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider authProvider;
  UserProfile? _userProfile;

  UserProfileProvider({required this.authProvider});

  UserProfile? get userProfile => _userProfile ?? null;

  // Check if a user's profile document exists
  Future<bool> doesProfileExist({String? uid}) async {
    final userId = uid ?? authProvider.uid;
    if (userId == null) return false;

    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists;
  }

  Future<UserProfile?> fetchUserProfileById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _userProfile = UserProfile.fromFirestore(doc.data()!);
        return _userProfile;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Fetch a user profile; if uid is null, fetch the current user's profile
  Future<void> fetchUserProfile({String? uid}) async {
    final userId = uid ?? authProvider.uid;
    if (userId == null) {
      _userProfile = null;
      notifyListeners();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _userProfile = UserProfile.fromFirestore(doc.data()!);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Save (create or update) a user profile; if uid is null, save for the current user
  Future<void> saveUserProfile(UserProfile profile, {String? uid}) async {
    final userId = uid ?? authProvider.uid;
    if (userId == null) throw Exception('User ID is required to save profile.');

    try {
      await _firestore.collection('users').doc(userId).set(profile.toFirestore());
      if (uid == null) _userProfile = profile; // Update local profile only if it's the current user
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Delete a user profile; if uid is null, delete the current user's profile
  Future<void> deleteUserProfile({String? uid}) async {
    final userId = uid ?? authProvider.uid;
    if (userId == null) throw Exception('User ID is required to delete profile.');

    try {
      await _firestore.collection('users').doc(userId).delete();
      if (uid == null) _userProfile = null; // Clear local profile only if it's the current user
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  Future<void> joinGroup(String groupId) async {
    final userId = authProvider.uid;
    if (userId == null) throw Exception('User ID is required to save profile.');

    try {
      // Update group document
      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([userId]),
      });

      // Update user document to reflect new groupId
      await _firestore.collection('users').doc(userId).update({
        'groupId': groupId,
      });

      
      fetchUserProfile(); //To notify the listeners

    } catch (e) {
      throw Exception('Failed to add user to group: $e');
    }

  }

  // Optional: Clear the local profile data
  void clearProfile() {
    _userProfile = null;
    notifyListeners();
  }
}
