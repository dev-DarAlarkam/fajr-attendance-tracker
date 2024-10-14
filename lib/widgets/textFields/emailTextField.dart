import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;

  const EmailTextField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: Dictionary.email,
        hintText: Dictionary.emailInput,
        hintStyle: AppConstants.hintStyle,
        enabledBorder: AppConstants.defaultFieldBorder,
        focusedBorder: AppConstants.focusedFieldBorder,
        errorBorder: AppConstants.errorFieldBorder,
        focusedErrorBorder: AppConstants.focusedErrorFieldBorder,
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return Dictionary.emptyFieldErrorMessage;
        }
        final emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
        if (!RegExp(emailPattern).hasMatch(value)) {
          return Dictionary.emailFormatErrorMessage;
        }
        return null;
      },
    );
  }
}

class EmailSignupTextField extends StatelessWidget {
  final TextEditingController controller;

  const EmailSignupTextField(
    this.controller, 
    {super.key}
    );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: Dictionary.email,
        hintStyle: AppConstants.hintStyle,
        enabledBorder: AppConstants.defaultFieldBorder,
        focusedBorder: AppConstants.focusedFieldBorder,
        errorBorder: AppConstants.errorFieldBorder,
        focusedErrorBorder: AppConstants.focusedErrorFieldBorder,
      ),

      validator: (value) {
        if (value == null || value.isEmpty) {
          return Dictionary.emptyFieldErrorMessage;
        }
        final emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
        if (!RegExp(emailPattern).hasMatch(value)) {
          return Dictionary.emailFormatErrorMessage;
        }
        return null;
      },
    );
  }
}

class EmailConfirmationTextField extends StatelessWidget {
  final TextEditingController confirmationEmail;
  final TextEditingController enteredEmail;

  const EmailConfirmationTextField(
    this.confirmationEmail,
    this.enteredEmail,
    {super.key}
    );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: TextFormField(
        controller: confirmationEmail,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: Dictionary.emailConfirmation,
          hintStyle: AppConstants.hintStyle,
          enabledBorder: AppConstants.defaultFieldBorder,
          focusedBorder: AppConstants.focusedFieldBorder,
          errorBorder: AppConstants.errorFieldBorder,
          focusedErrorBorder: AppConstants.focusedErrorFieldBorder,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return Dictionary.emptyFieldErrorMessage;
          }
          if (value != enteredEmail.text) {
            return Dictionary.emailConfirmationErrorMessage;
          }
          return null;
        },
      ),
    );
  }
}
