import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/attendace.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/providers/attendance_provider.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/utils/prayer_time.dart';
import 'package:attendance_tracker/widgets/buttons/firebase_action_button.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:attendance_tracker/widgets/textFields/form_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
              
              AttendanceDashboard(userId: profile.uid),

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
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isInGroup
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("ترتيبك:",
                        style: AppConstants.titleTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20,),
                      SizedBox(
                        height: 70,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(flex: 2, child: SizedBox()),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  FutureBuilder(
                                    future: fetchUserRank(profile.groupId, profile.uid),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError || snapshot.data == -1) {
                                        return Text(
                                          'لا يوجد',
                                          style: AppConstants.titleTextStyle,
                                          textAlign: TextAlign.center,
                                        );
                                      } else {
                                        return Text(
                                          '${snapshot.data}',
                                          style: AppConstants.titleTextStyle,
                                          textAlign: TextAlign.center,
                                        );
                                      }
                                    },
                                  ),
                        
                                  Text("في مجموعتك")
                                ],
                              ),
                              Expanded(flex: 1, child: SizedBox()),
                              VerticalDivider(
                                color: Colors.grey, // Customize the color
                                thickness: 2,       // Adjust the thickness
                              ),
                              Expanded(flex: 1, child: SizedBox()),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  FutureBuilder(
                                    future: fetchUserRank('community', profile.uid),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError || snapshot.data == -1) {
                                        return Text(
                                          'لا يوجد',
                                          style: AppConstants.titleTextStyle,
                                          textAlign: TextAlign.center,
                                         );
                                      } else {
                                        return Text(
                                          '${snapshot.data}',
                                          style: AppConstants.titleTextStyle,
                                          textAlign: TextAlign.center,
                                        );
                                      }
                                    },
                                  ),
                                  Text("في دار الأرقم")
                                ],
                              ),
                              Expanded(flex: 2, child: SizedBox()),
                            ],
                          ),
                      ),
                    ],
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
                          SizedBox(
                            height: 10,
                          ),
                          EnglishNameTextField(controller, Dictionary.joinGroupInput),
                          SizedBox(
                            height: 10,
                          ),
                          FirebaseActionButton(
                              onPressed: () async {
                                // Validate the form
                                if (formKey.currentState!.validate()) {
                                  try {
                                    await provider.joinGroup(controller.text).then((_) {
                                      controller.clear();
                                    });
                                  } catch (e) {
                                    showSnackBar(context, '$e');
                                  }
                                } else {
                                  // The error state will be triggered by the validator returning an error message
                                }
                              },
                              text: Dictionary.joinGroup)
                        ],
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  // Function to fetch user's rank from Firestore
  Future<int> fetchUserRank(String groupId, String userId) async {
    try {
      final groupDoc = await FirebaseFirestore.instance.collection('leaderboards').doc(groupId).get();
      if (groupDoc.exists) {
        print("i'm here");
        final leaderboard = List<Map<String, dynamic>>.from(groupDoc.data()!['leaderboard']);

        int rank = 1;
        int previousScore = leaderboard[0]['totalScore'];
        for (int i = 0; i < leaderboard.length; i++) {
          print(leaderboard[i]['userId']);
          if (leaderboard[i]['userId'] == userId) {
            return rank;
          }
          if (leaderboard[i]['totalScore'] != previousScore) {
            rank = i + 1;
            previousScore = leaderboard[i]['totalScore'];
          }
        }
      }
      return -1; // User not found in the leaderboard
    } catch (e) {
      throw Exception('Failed to fetch user rank: $e');
    }
  }
}


class AttendanceDashboard extends StatefulWidget {
  final String userId;

  const AttendanceDashboard({
    required this.userId,
    super.key
    });

  @override
  State<AttendanceDashboard> createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otherMoqueController = TextEditingController();
  String? _selectedMosque;
  bool _showOtherMosque = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(builder:(context, value, child) {

      return Container(
        width: 400,
        padding: AppConstants.padding,
        margin: EdgeInsets.fromLTRB(30,5,30,40),
        decoration: AppConstants.boxDecoration,
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FutureBuilder<bool>(
                        future: AttendanceProvider().attendanceExists(widget.userId, DateTime.now()), 
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
                            final data = snapshot.data!;
                            if(data) {
                              return Text(Dictionary.attendanceRecordDuplicate);
                            }
                          }
                          return SizedBox.shrink();
                        }
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
          
                  Text(
                    Dictionary.attendanceTracker,
                    style: AppConstants.titleTextStyle,
                    textAlign: TextAlign.center,
                    ),
                  SizedBox(height: 20,),
                  _buildMosqueDropdown(),
                  SizedBox(height: 10,),
                  if(_showOtherMosque) NameTextField(_otherMoqueController, AppConstants.other),
                  SizedBox(height: 20,),

                  FirebaseActionButton(
                    onPressed: () async {

                      if (_formKey.currentState!.validate() && _selectedMosque != null) {
                        try{
                          DateTime date = DateTime.now();
                          String id = DateFormatUtils.formatDate(date);
                          String location = _selectedMosque!;
                          int score = Attendance.calculateScore(location);

                          final record = Attendance(attendanceId: id, userId: widget.userId, date: date, attendanceLocation: location, score: score);
                          
                          await AttendanceProvider().createOrUpdateAttendance(widget.userId, record)
                          .then((_) {
                            showSnackBar(context, Dictionary.attendanceRecordSuccess);
                            setState(() {});
                          });

                        }
                        catch (e) {
                          showSnackBar(context, '$e');
                        }
                      } else {
                        // The error state will be triggered by the validator returning an error message
                      }

                    }, 
                    text: Dictionary.createAttendanceRecord
                  )
                ],
              )
            ),

            FutureBuilder<bool>(
              future: PrayerTimesManager().isItFajrTime(), 
              builder: (context, snapshot) {
                
                if(snapshot.hasData) {
                  if(snapshot.data! == true) {
                    return SizedBox.shrink();
                  }
                }
                
                
                return Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(100), // Semi-transparent overlay
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(225, 225, 225, 1),
                        borderRadius: AppConstants.borderRadius
                      ),
                      child: Text(
                        Dictionary.attendanceRecordBlocked,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ],
        ),
      );

    });
  }

  Widget _buildMosqueDropdown() {

    Map<String,String> mosqueList = Attendance.mousqueList;
    return DropdownButtonFormField<String>(
      value: _selectedMosque,
      hint: Text('اختر المسجد', style: AppConstants.hintStyle,),
      items: mosqueList.keys
          .map((mosque) => DropdownMenuItem(value: mosque, child: Text(mosqueList[mosque]!)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedMosque = value;
          _showOtherMosque = value == AppConstants.other;
        });
      },
      decoration: InputDecoration(
        enabledBorder: AppConstants.defaultFieldBorder,
        focusedBorder: AppConstants.focusedFieldBorder,
        errorBorder: AppConstants.errorFieldBorder,
        focusedErrorBorder: AppConstants.focusedErrorFieldBorder,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      ),
      validator: (value) {
        if(value == null) {
          return Dictionary.emptyFieldErrorMessage;
        }
        return null;
      },
    );
  }
}
