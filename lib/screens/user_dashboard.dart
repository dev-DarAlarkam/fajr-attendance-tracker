import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/group_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/screens/admin/create_group_screen.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/firebase_action_button.dart';
import 'package:attendance_tracker/widgets/buttons/navigation_buttons.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:attendance_tracker/widgets/textFields/form_text_field.dart';
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
    final userProfileProvider = context.read<UserProfileProvider>(); // Non-listening access

    try {
      await userProfileProvider.fetchUserProfile();
    } catch (e) {
      print('Error fetching user profile: $e');
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

              GroupDashboard(),

              // Tracker form
              Container(
                width: 400,
                padding: AppConstants.padding,
                margin: margin,
                decoration: AppConstants.boxDecoration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedNavButton(text: "Create group", nextScreen: CreateGroupScreen()),
                    FirebaseActionButton(
                      onPressed: () async {
                        try {
                          await GroupProvider().removeUserFromGroup(profile.uid, profile.groupId);
                        } catch (e) {
                          showSnackBar(context, '$e');
                        }
                      }, 
                      text: "exit group"
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}

class GroupDashboard extends StatelessWidget {

  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  GroupDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, child) {
        
        UserProfile profile = provider.userProfile!;
        bool isInGroup = profile.groupId != 'None';
        
        return Container(
          width: 400,
          padding: AppConstants.padding,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
          decoration: AppConstants.boxDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                isInGroup 
                ? Text(
                    profile.groupId,
                    style: AppConstants.titleTextStyle,
                    textAlign: TextAlign.center,
                  )
                : Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Text(
                          Dictionary.joinGroup,
                          style: AppConstants.titleTextStyle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10,),
                        EnglishNameTextField(controller, Dictionary.joinGroupInput),
                        SizedBox(height: 10,),
                        FirebaseActionButton(
                          onPressed: () async {
                            // Validate the form
                            if (formKey.currentState!.validate()) {
                              try{
                                await provider.joinGroup(controller.text)
                                .then((_) {
                                  controller.clear();
                                });
                              }
                              catch (e) {
                                showSnackBar(context, '$e');
                              }
                            } else {
                              // The error state will be triggered by the validator returning an error message
                            }
                          }, 
                          text: Dictionary.joinGroup
                        )
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
