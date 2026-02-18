import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/screens/groups/groups_screen.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/navigation_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
   bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserProfile();
    });
  }

  Future<void> _fetchUserProfile() async {
    final userProfileProvider = context.read<UserProfileProvider>(); // Non-listening access

    try {
      await userProfileProvider.fetchUserProfile();
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final userProfileProvider = context.watch<UserProfileProvider>(); // Listening access
    final profile = userProfileProvider.userProfile;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                margin: AppConstants.margin,
                decoration: AppConstants.boxDecoration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Back Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await AuthProvider().signOut().then((value){
                              userProfileProvider.clearProfile();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => SplashScreen()),
                              );
                            });
                          }, 
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
              GroupsDashboard(),
            ],
          ),
        )
      ),
    );
  }
  }


class GroupsDashboard extends StatelessWidget {
  const GroupsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: AppConstants.padding,
      margin: EdgeInsets.fromLTRB(30,5,30,40),
      decoration: AppConstants.boxDecoration,
      child: Column(
        children: [
          Text(
            "المجموعات التربوية",
            style: AppConstants.titleTextStyle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20,),
          ElevatedNavButton(text: "ادارة مجموعاتك", nextScreen: GroupsScreen()),
        ],
      )
    );  
  }
}