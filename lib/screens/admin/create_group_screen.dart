import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/group.dart';
import 'package:attendance_tracker/providers/group_provider.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/firebase_action_button.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:attendance_tracker/widgets/textFields/form_text_field.dart';
import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _otherGradeController = TextEditingController();
  String? _selectedGrade;
  bool _showOtherGrade = false;

  @override
  Widget build(BuildContext context) {
    Group group;

    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: AppConstants.backgroundPrimaryColor,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              padding: AppConstants.padding,
              margin: AppConstants.margin,
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
                    Dictionary.createGroup,
                    style: AppConstants.titleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  // Name Fields
                  NameTextField(_groupNameController, 'اسم المجموعة'),
                  SizedBox(height: 20),
                  // Grade Dropdown
                  _buildGradeDropdown(),
                  if (_showOtherGrade) NameTextField(_otherGradeController, 'آخر', marginTop: 5),
                  SizedBox(height: 20),
                  
                  FirebaseActionButton(
                    onPressed: () async {
                      // Validate the form
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, sign the user up
                        group = Group(
                          groupId: Group.generateGroupId(), 
                          groupName: _groupNameController.text, 
                          gradeLevel: _selectedGrade! == AppConstants.other ? _otherGradeController.text : _selectedGrade!.toString(), 
                          members: []
                          );

                        try{
                          await GroupProvider().createGroup(group).then((_) {
                            _groupNameController.clear();
                            _otherGradeController.clear();
                            showSnackBar(context, Dictionary.createGroupSuccess);
                          });
                        }
                        catch (e) {
                          showSnackBar(context, '$e');
                        }
                      } else {
                        // The error state will be triggered by the validator returning an error message
                      }
                    }, 
                    text: Dictionary.createGroup
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  // Dropdown for Grade Selection
  Widget _buildGradeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGrade,
      hint: Text('اختر الصف', style: AppConstants.hintStyle,),
      items: List.generate(12, (index) => (index + 1).toString())
          .map((grade) => DropdownMenuItem(value: grade, child: Text(grade)))
          .toList()
        ..add(DropdownMenuItem(value: AppConstants.other, child: Text('آخر'))),
      onChanged: (value) {
        setState(() {
          _selectedGrade = value;
          _showOtherGrade = value == AppConstants.other;
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


  @override
  void dispose() {
    _groupNameController.dispose();
    _otherGradeController.dispose();
    super.dispose();
  }
}