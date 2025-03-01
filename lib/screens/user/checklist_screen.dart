import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/checklist.dart';
import 'package:attendance_tracker/providers/checklist_provider.dart';
import 'package:attendance_tracker/screens/user/checklist_redirect_screen.dart';
import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/firebase_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChecklistScreen extends StatefulWidget {
  final String userId;

  const ChecklistScreen({required this.userId, super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late final Checklist checklist;
  @override
  Widget build(BuildContext context) {
    EdgeInsets margin = EdgeInsets.symmetric(vertical: 5, horizontal: 30);
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      BackButton(),
                    ],
                  ),
                  // Logo Section
                  AppConstants.logo,
                  // Title
                  Text(
                    "برنامج المحاسبة الرمضاني",
                    style: AppConstants.titleTextStyle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  
                  FutureBuilder(
                    future: context.read<ChecklistProvider>().getTodaysChecklist(widget.userId),
                    builder: (context, AsyncSnapshot<Checklist> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      checklist = snapshot.data!;
                      checklist.items.sort((a, b) => a.index!.compareTo(b.index!),);
                      return Column(
                        children: [
                          Text("${DateFormatUtils.formatHijriDate(checklist.date)} | ${DateFormatUtils.formatDate(checklist.date)}"),
                          const SizedBox(height: 20),
                          // Checklist Items
                          ...checklist.items.map((item) {
                            if(item.isPermanent == false) {
                              if(!item.daysOfWeek!.contains(getDayOfWeekBasedOnPackage(DateTime.now().weekday))) {
                                return SizedBox.shrink();
                              }
                            }
                            if (item.itemType == ChecklistItemType.normal) {
                              return _buildChecklistItemNormal(item);
                            } else {
                              return _buildChecklistItemPrayer(item);
                            }
                          }),
                          // Submit Button
                          FirebaseActionButton(
                            onPressed: _submitChecklist, 
                            text: 'إرسال'
                          )
                          
                        ],
                      );
                    }, 
                  ),                
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildChecklistItemNormal(ChecklistItem item) {
    item.isChecked = item.isChecked ?? false;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setInnerState) {
        return ListTile(
          title: Text(item.displayName),
          trailing: Checkbox(
            value: item.isChecked,
            onChanged: (value) {
              setInnerState(() {
                item.isChecked = value!;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildChecklistItemPrayer(ChecklistItem item) {
    item.prayerDoneType = item.prayerDoneType ?? PrayerDoneType.missed;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setInnerState) {
          return ListTile(
            title: Text(item.displayName),
            trailing: DropdownButton<PrayerDoneType>(
              value: item.prayerDoneType,
              onChanged: (value) {
                  setInnerState(() {
                    item.prayerDoneType = value!;
                  });
              },
              items: PrayerDoneType.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(Dictionary.prayerDoneTypes[e.index]),
                      ))
                  .toList(),
            ),
          );
        },
      );
    
    
  }

  
  
  Future<void> _submitChecklist() async {
    try {
      await context.read<ChecklistProvider>().createOrUpdateChecklist(widget.userId, checklist).then((value) async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChecklistRedirectScreen()),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to submit checklist: $e'),
      ));
    }
  }
}
