import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/providers/group_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/firebase_action_button.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:attendance_tracker/widgets/textFields/form_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupDashboard extends StatelessWidget {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  GroupDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, child) {
        UserProfile profile = provider.userProfile!;
        bool isInGroup = profile.groupId != AppConstants.none;

        return Container(
          width: 400,
          padding: AppConstants.padding,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
          decoration: AppConstants.boxDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if(isInGroup)
                FutureBuilder(
                  future: context.read<GroupProvider>().fetchGroupName(profile.groupId), 
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("...");
                    } else if (snapshot.hasError) {
                      return Text(
                        'لا يوجد',
                        style: AppConstants.titleTextStyle,
                        textAlign: TextAlign.center,
                      );
                    } else {
                      return _welcomeMessage(snapshot.data as String);
                    }
                  },
                )
              else
                _buildJoinGroupForm(context, provider) 
            ],
          ),
        );
      },
    );
  }


  Widget _welcomeMessage(String groupName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'مجموعتك هي \n $groupName',
          style: AppConstants.titleTextStyle,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20,),
      ],
    );
  }

  //TODO: make a provider to handle this function or add it to an existing one
  // Function to fetch user's rank from Firestore
  Future<int> fetchUserRank(String groupId, String userId) async {
    try {
      final groupDoc = await FirebaseFirestore.instance.collection('leaderboards').doc(groupId).get();
      if (groupDoc.exists) {
        final leaderboard = List<Map<String, dynamic>>.from(groupDoc.data()!['leaderboard']);

        int rank = 1;
        int previousScore = leaderboard[0]['totalScore'];
        for (int i = 0; i < leaderboard.length; i++) {
          if (leaderboard[i]['userId'] == userId) {
            return rank;
          }
          if (leaderboard[i]['totalScore'] != "N/A" && leaderboard[i]['totalScore'] != previousScore) {
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

  Widget _leaderboardBuilder(BuildContext context, AsyncSnapshot<int> snapshot) {
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
  }

  //TODO: add all the required text to the dictionary
  Widget _buildLeaderboard(UserProfile profile) {
    return Column(
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
                    FutureBuilder<int>(
                      future: fetchUserRank(profile.groupId, profile.uid),
                      builder: _leaderboardBuilder
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
                    FutureBuilder<int>(
                      future: fetchUserRank('community', profile.uid),
                      builder: _leaderboardBuilder,
                    ),
                    Text("في دار الأرقم")
                  ],
                ),
                Expanded(flex: 2, child: SizedBox()),
              ],
            ),
        ),
      ],
    );              
  }

  //TODO: add all the required text to the dictionary
  Widget _buildJoinGroupForm (BuildContext context, UserProfileProvider provider) {
    return Form(
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
    );
  }
}
