import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/models/user_profile.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/firebase_action_button.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:attendance_tracker/widgets/textFields/form_text_field.dart';
import 'package:flutter/material.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _otherGradeController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGrade;
  bool _showOtherGrade = false;

  Future<void> createProfile() async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, sign the user up
      final userProfile = UserProfile(
        uid: AuthProvider().uid!, 
        firstName: _firstNameController.text, 
        fatherName: _fatherNameController.text, 
        lastName: _lastNameController.text, 
        grade: _selectedGrade! == AppConstants.other ? _otherGradeController.text : _selectedGrade!.toString(), 
        groupId: AppConstants.none, 
        rule: UserProfile.rules[0] //"user"
        );

      try{
        await UserProfileProvider(authProvider: AuthProvider()).saveUserProfile(userProfile);
        Navigator.pushNamedAndRemoveUntil(context, '/', (route)=>false);
      }
      catch (e) {
        showSnackBar(context, '$e');
      }
    } else {
      // The error state will be triggered by the validator returning an error message
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Logo Section
                  AppConstants.logo,
                  // Title
                  Text(
                    Dictionary.createProfile,
                    style: AppConstants.titleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  // Name Fields
                  NameTextField(_firstNameController, 'اسمك'),
                  NameTextField(_fatherNameController, 'اسم الأب', marginTop: 10,),
                  NameTextField(_lastNameController, 'العائلة', marginTop: 10,),
                  SizedBox(height: 20),
                  // Birthday picker
                  _buildBirthdayField(context),
                  SizedBox(height: 20),
                  // Grade Dropdown
                  _buildGradeDropdown(),
                  if (_showOtherGrade) NameTextField(_otherGradeController, 'آخر', marginTop: 5),
                  SizedBox(height: 20),
                  
                  FirebaseActionButton(
                    onPressed: createProfile, 
                    text: Dictionary.signUp
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdayField(BuildContext context) {
    return TextFormField(
      controller: _birthdayController,
      readOnly: true,
      onTap: () => _pickDate(context),
      decoration: InputDecoration(
        hintText: 'تاريخ الميلاد',
        hintStyle: AppConstants.hintStyle,
        enabledBorder: AppConstants.defaultFieldBorder,
        focusedBorder: AppConstants.focusedFieldBorder,
        errorBorder: AppConstants.errorFieldBorder,
        focusedErrorBorder: AppConstants.focusedErrorFieldBorder,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      validator: (value) {
        if(_selectedDate == null) {
          return Dictionary.emptyFieldErrorMessage;
        }
        return null;
      },
    );
  }

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      // initialDate: DateTime(2005), // Default date
      firstDate: DateTime(1970),   // Earliest date
      lastDate: DateTime.now(),    // Latest date
      locale: Locale('ar'),        // Arabic locale for RTL
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = DateFormatUtils.formatDate(_selectedDate!);
      });
    }
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
    _firstNameController.dispose();
    _fatherNameController.dispose();
    _lastNameController.dispose();
    _birthdayController.dispose();
    _otherGradeController.dispose();
    super.dispose();
  }
}