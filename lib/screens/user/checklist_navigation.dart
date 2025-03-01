import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/screens/user/checklist_screen.dart';
import 'package:attendance_tracker/services/prayer_times_services.dart';
import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/navigation_buttons.dart';
import 'package:flutter/material.dart';

class ChecklistNavigation extends StatelessWidget {

  final String userId;
  const ChecklistNavigation({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: AppConstants.padding,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
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
              ElevatedNavButton(text: "للمحاسبة اليومية", nextScreen: ChecklistScreen(userId: userId))
            ],
          ),

          FutureBuilder(future: PrayerTimesServices().checkIfIshaTime(), builder: _buildChecklistCover)
        ],
      ),
    );
  }

  Widget _buildChecklistCover(BuildContext context, AsyncSnapshot<bool> snapshot) {
    
    if (snapshot.hasError) {
      return Text(
        'لا يوجد',
        style: AppConstants.titleTextStyle,
        textAlign: TextAlign.center,
      );
    } else if(snapshot.hasData) {
      final bool isishaTime = snapshot.data!;

      return isishaTime 
        ? SizedBox.shrink()
        : Positioned.fill(
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
    } else {
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(100), // Semi-transparent overlay
          ),
          alignment: Alignment.center,
          child: CircularProgressIndicator()
        )
      );
    }
  }
}