import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Timer? _inactivityTimer;

  AuthProvider() {
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? user) {
      notifyListeners(); // Trigger updates on auth state changes
      _resetInactivityTimer(); // Reset inactivity timer if needed
    });
  }

  // Direct access to Firebase's currentUser
  User? get user => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Sign up with email and password
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await sendEmailVerification();
      _resetInactivityTimer();
      notifyListeners(); // Ensure listeners are updated after sign-up
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!_auth.currentUser!.emailVerified) {
        throw Exception('Please verify your email first.');
      }
      _resetInactivityTimer();
      notifyListeners(); // Ensure listeners are updated after sign-in
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
        _resetInactivityTimer();
        notifyListeners(); // Ensure listeners are updated after Google sign-in
      }
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _cancelInactivityTimer();
      notifyListeners(); // Ensure listeners are updated after sign-out
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Send email verification to the current user
  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send email verification: $e');
    }
  }

  // Inactivity timer methods
  void _resetInactivityTimer() {
    _cancelInactivityTimer();
    _inactivityTimer = Timer(Duration(hours: 2), () {
      signOut();
    });
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
  }

  void resetTimerOnUserActivity() {
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    _cancelInactivityTimer();
    super.dispose();
  }
}
