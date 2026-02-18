import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/screens/user/checklist_screen.dart';
import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:attendance_tracker/widgets/buttons/navigation_buttons.dart';
import 'package:flutter/material.dart';

class ChecklistNavigation extends StatelessWidget {

  final UserProfile userProfile;
  const ChecklistNavigation({required this.userProfile, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: AppConstants.padding,
      margin: EdgeInsets.fromLTRB(30,5,30,15),
      decoration: AppConstants.boxDecoration,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "برنامج المحاسبة الرمضاني",
                style: AppConstants.titleTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "الخاص بيوم: ${DateFormatUtils.formatHijriDate(DateTime.now())}",
                style: AppConstants.textButtonStyle,
              ),
              const SizedBox(height: 20),
              ElevatedNavButton(text: "للمحاسبة اليومية", nextScreen: ChecklistScreen(userProfile: userProfile))
            ],
          ),

        ],
      ),
    );
  }
}