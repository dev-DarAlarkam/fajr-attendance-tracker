import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/screens/user/attendance_dashboard.dart';
import 'package:attendance_tracker/screens/user/checklist_screen.dart';
import 'package:attendance_tracker/screens/user/group_dashboard.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/navigation_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  
  @override
  void initState() {
    super.initState();
  }

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
  
    await authProvider.signOut();
    userProfileProvider.clearProfile();

    // Navigate to SplashScreen after sign out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, value, child) {
      bool isAuth = value.isAuthenticated;
      EdgeInsets margin = EdgeInsets.symmetric(vertical: 5, horizontal: 30);

      if (!isAuth) {
        print("is heere???");
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
      final profile = userProfileProvider.userProfile;

      if (profile == null) {
        return const Scaffold(
          body: Center(child: Text('Profile not found')),
        );
      }

      return Scaffold(
        backgroundColor: AppConstants.backgroundPrimaryColor,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
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

                ElevatedNavButton(text: "محاسبة", nextScreen: ChecklistScreen(userId: profile.uid))

              ],
            ),
          )
        ),
      );
    });
  }
}
