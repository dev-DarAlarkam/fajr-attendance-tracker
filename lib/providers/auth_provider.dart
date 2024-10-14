import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  Timer? _inactivityTimer;
  bool _isOperationInProgress = false;

  AuthProvider() {
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
      _resetInactivityTimer();
    });
  }

  bool get isAuthenticated => _user != null;
  User? get user => _user;

  // General function to check if another operation is in progress
  bool _startOperation() {
    if (_isOperationInProgress) return false; // If an operation is ongoing, return false
    _isOperationInProgress = true;
    notifyListeners();
    return true;
  }

  void _endOperation() {
    _isOperationInProgress = false;
    notifyListeners();
  }

  // Sign up with email and password
  Future<void> signUpWithEmail(String email, String password) async {
    if (!_startOperation()) return; // Prevent method from executing if another operation is ongoing
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await sendEmailVerification();
      _resetInactivityTimer();
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    } finally {
      _endOperation();
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    if (!_startOperation()) return;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!_auth.currentUser!.emailVerified) {
        throw Exception('Please verify your email first.');
      }
      _resetInactivityTimer();
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    } finally {
      _endOperation();
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    if (!_startOperation()) return;
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
      }
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    } finally {
      _endOperation();
    }
  }

  // Regular sign out
  Future<void> signOut() async {
    if (!_startOperation()) return;
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _cancelInactivityTimer();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    } finally {
      _endOperation();
    }
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    if (!_startOperation()) return;
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    } finally {
      _endOperation();
    }
  }

  // Send email verification to the current user
  Future<void> sendEmailVerification() async {
    if (!_startOperation()) return;
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send email verification: $e');
    } finally {
      _endOperation();
    }
  }

  // Private methods for inactivity timer
  void _resetInactivityTimer() {
    _cancelInactivityTimer();
    _inactivityTimer = Timer(Duration(minutes: 30), () {
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
