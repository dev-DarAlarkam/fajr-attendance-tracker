import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/screens/user/attendance_dashboard.dart';
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
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserProfile();
    });
  }

  Future<void> _fetchUserProfile() async {
    
    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Only fetch profile if the user is authenticated
    if (authProvider.isAuthenticated) {
      try {
        await userProfileProvider.fetchUserProfile();
      } catch (e) {
        print('Error fetching user profile: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // If the user is not authenticated, stop loading
      setState(() {
        _isLoading = false;
      });
    }
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

              ],
            ),
          )
        ),
      );
    });
  }
}
