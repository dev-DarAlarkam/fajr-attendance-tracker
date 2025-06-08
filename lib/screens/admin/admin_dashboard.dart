import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/screens/admin/checklist/checklist_item_manager_screen.dart';
import 'package:attendance_tracker/screens/admin/group/create_group_screen.dart';
import 'package:attendance_tracker/screens/admin/attendance/leaderboard_screen.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/firebase_action_button.dart';
import 'package:attendance_tracker/widgets/buttons/navigation_buttons.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  
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
    EdgeInsets margin = EdgeInsets.symmetric(vertical: 5, horizontal: 30);

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
              NavigatorDashboard(),
            ],
          ),
        )
      ),
    );
  }
}

class NavigatorDashboard extends StatelessWidget {
  const NavigatorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: AppConstants.padding,
      margin: EdgeInsets.fromLTRB(30,5,30,40),
      decoration: AppConstants.boxDecoration,
      child: Column(
        children: [
          FirebaseActionButton(
            onPressed: () async {
              try {
                HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('calculateLeaderboardNow');

                await callable.call().then((_) {
                  showSnackBar(context, 'تمت عملية إعادة ضبط المراتب بنجاح');
                }); 
              } catch (e) {
                showSnackBar(context, '$e');
              }
            },
            text: "أعد ضبط المراتب"
          ),
          SizedBox(height: 10,),
          ElevatedNavButton(text: "انشئ مجموعة", nextScreen: CreateGroupScreen()),
          SizedBox(height: 10,),
          ElevatedNavButton(text: "لائحة البيانات", nextScreen: LeaderboardDashboardScreen()),
          SizedBox(height: 10,),
          ElevatedNavButton(text: "ادارة برنامج المحاسبة", nextScreen: ChecklistItemManagerScreen(),)
        ],
      )
    );
  }
}

