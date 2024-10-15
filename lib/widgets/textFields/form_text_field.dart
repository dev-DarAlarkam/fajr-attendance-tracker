import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:flutter/material.dart';

class NameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double marginTop;

  const NameTextField(
    this.controller, 
    this.hint, 
    {this.marginTop = 0,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: marginTop),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.text,
        
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppConstants.hintStyle,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          enabledBorder: AppConstants.defaultFieldBorder,
          focusedBorder: AppConstants.focusedFieldBorder,
          errorBorder: AppConstants.errorFieldBorder,
          focusedErrorBorder: AppConstants.focusedErrorFieldBorder,
        ),


        validator: (value) {
          if (value == null || value.isEmpty) {
            return Dictionary.emptyFieldErrorMessage; 
          }
          final arabicPattern = r'^[\u0600-\u06FF\s]+$';
          if (!RegExp(arabicPattern).hasMatch(value)) {
            return Dictionary.nonArabicErrorMessage; 
          }
          return null; // Return null if the validation is successful
        },
      ),
    );
  }
}


class EnglishNameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double marginTop;

  const EnglishNameTextField(
    this.controller, 
    this.hint, 
    {this.marginTop = 0,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: marginTop),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.text,
        
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppConstants.hintStyle,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          enabledBorder: AppConstants.defaultFieldBorder,
          focusedBorder: AppConstants.focusedFieldBorder,
          errorBorder: AppConstants.errorFieldBorder,
          focusedErrorBorder: AppConstants.focusedErrorFieldBorder,
        ),


        validator: (value) {
          if (value == null || value.isEmpty) {
            return Dictionary.emptyFieldErrorMessage; 
          }
          return null; // Return null if the validation is successful
        },
      ),
    );
  }
}



