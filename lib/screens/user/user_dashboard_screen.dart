import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/screens/user/attendance_dashboard.dart';
import 'package:attendance_tracker/screens/user/checklist_navigation.dart';
import 'package:attendance_tracker/screens/user/group_dashboard.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {

  final EdgeInsets margin = EdgeInsets.symmetric(vertical: 5, horizontal: 30);

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
  
    await authProvider.signOut().then((_) { 
      userProfileProvider.clearProfile();
      // Navigate to SplashScreen after sign out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, value, child) {
      bool isAuth = value.isAuthenticated;

      if (!isAuth) {
        // Redirect to SplashScreen after this build cycle
        Future.microtask(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SplashScreen()),
          );
        });

        // Return an empty widget to avoid rendering the rest of the screen
        return const SizedBox();
      }
      final userProfileProvider = context.watch<UserProfileProvider>(); // Listening access

      return Scaffold(
        backgroundColor: AppConstants.backgroundPrimaryColor,
        body: Center(
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: userProfileProvider.fetchUserProfileById(value.uid!), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                else if (snapshot.hasError) {
                  return _buildErrorBlock(snapshot.error.toString());
                } else {
                  
                  final profile = snapshot.data;
                  if (profile == null) return _buildErrorBlock('User profile not found');

                  return _buildUserScreen(profile);
                }
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildUserScreen(UserProfile profile) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 400,
              padding: AppConstants.padding,
              margin: margin,
              decoration: AppConstants.boxDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Back Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: _signOut, 
                        icon: Icon(Icons.exit_to_app)
                      ),
                    ],
                  ),
                  // Logo Section
                  AppConstants.logo,
                  // Title
                  Text(
                    "${Dictionary.welcome} ${profile.firstName}",
                    style: AppConstants.titleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            GroupDashboard(),
            
            AttendanceDashboard(userId: profile.uid),

            ChecklistNavigation(userId: profile.uid),

          ],
    );
  }

  Widget _buildErrorBlock(String error) {
    return Container(
      width: 400,
      padding: AppConstants.padding,
      margin: margin,
      decoration: AppConstants.boxDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        // Back Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _signOut, 
                icon: Icon(Icons.exit_to_app)
              ),
            ],
          ),
          // Logo Section
          AppConstants.logo,
          // Title
          Text('Error: $error'),
        ],
      ),
    );
  }
}
