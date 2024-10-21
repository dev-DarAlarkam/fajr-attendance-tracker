import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/attendace.dart';
import 'package:attendance_tracker/providers/attendance_provider.dart';
import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/utils/prayer_time.dart';
import 'package:attendance_tracker/widgets/buttons/firebase_action_button.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:attendance_tracker/widgets/textFields/form_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                  if(_showOtherMosque) NameTextField(_otherMoqueController, "آخر"),
                  SizedBox(height: 20,),

                  FirebaseActionButton(
                    onPressed: _signAttendance, 
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

  Future<void> _signAttendance() async {
    if (_formKey.currentState!.validate() && _selectedMosque != null) {
      try{
        DateTime date = DateTime.now();
        String id = DateFormatUtils.formatDate(date);
        String location = _selectedMosque!;
        String otherLocation = _otherMoqueController.text;
        int score = Attendance.calculateScore(location);

        final record = Attendance(
          attendanceId: id, 
          userId: widget.userId, 
          date: date, 
          attendanceLocation: location, 
          otherLocation: location == "other" ? otherLocation : "none",
          score: score
        );
        
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
