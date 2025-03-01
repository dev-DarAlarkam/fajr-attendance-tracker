import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChecklistRedirectScreen extends StatefulWidget {
  const ChecklistRedirectScreen({super.key});

  @override
  State<ChecklistRedirectScreen> createState() =>_ChecklistRedirectScreenState();
}

class _ChecklistRedirectScreenState extends State<ChecklistRedirectScreen> {
  
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
  
      await authProvider.signOut();
      userProfileProvider.clearProfile();
    });
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
                  "تم تسجيل برنامجك بنجاح",
                  style: AppConstants.titleTextStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}