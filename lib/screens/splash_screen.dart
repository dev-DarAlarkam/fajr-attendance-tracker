import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>_SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _handleNavigation();
    });
  }

  Future<void> _handleNavigation() async {
    final authProvider = context.read<AuthProvider>();
    final userProfileProvider = context.read<UserProfileProvider>();
    // Check authentication status
    if (authProvider.isAuthenticated) {
      if (authProvider.isEmailVerified) {
        try {
          await userProfileProvider.fetchUserProfile();
          if (_hasNavigated) return;

          final profile = userProfileProvider.userProfile;
          if (profile != null) {
            setState(() => _hasNavigated = true);
            final routeName = profile.isAdmin ? '/admin' : '/user';
            Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
          } else {
            setState(() => _hasNavigated = true);
            Navigator.pushNamedAndRemoveUntil(context, '/create-profile', (route) => false);
          }
        } catch (e) {
          showSnackBar(context, 'Error loading profile: $e');
        }
      } else {
        _navigateTo('/login');
      }
    } else {
      _navigateTo('/login');
    }
  }

  void _navigateTo(String routeName) {
    if (!_hasNavigated) {
      setState(() => _hasNavigated = true);
      Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundPrimaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: AppConstants.padding,
            margin: AppConstants.margin,
            decoration: AppConstants.boxDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppConstants.logo,
                Text(
                  AppConstants.appTitle,
                  style: AppConstants.titleTextStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}