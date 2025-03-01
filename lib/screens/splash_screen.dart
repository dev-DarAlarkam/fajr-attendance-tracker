import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _handleNavigation();
    });
  }

  Future<void> _handleNavigation() async {
    if (_hasNavigated) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await Future.delayed(const Duration(seconds: 2));

      if (!authProvider.isAuthenticated || !authProvider.isEmailVerified) {
        return _navigateTo('/login');
      }

      final userProfileProvider = context.read<UserProfileProvider>();
      await userProfileProvider.fetchUserProfile();
      
      if (_hasNavigated) return;
      
      final profile = userProfileProvider.userProfile;
      final routeName = profile != null ? '/${profile.rule}' : '/create-profile';
      _navigateTo(routeName);

    } catch (e) {
      print('Error: $e');
      _navigateTo('/login');
    }
  }

  void _navigateTo(String routeName) {
    if (_hasNavigated) return;
    _hasNavigated = true;
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
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