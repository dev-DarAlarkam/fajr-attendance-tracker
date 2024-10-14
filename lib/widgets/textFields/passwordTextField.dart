import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;


  const PasswordTextField({
    super.key,
    required this.controller,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: Dictionary.password,
        hintText: Dictionary.passwordInput,
        hintStyle: AppConstants.hintStyle,
        enabledBorder: AppConstants.defaultFieldBorder,
        focusedBorder: AppConstants.focusedFieldBorder,
        errorBorder: AppConstants.errorFieldBorder,
        focusedErrorBorder: AppConstants.focusedErrorFieldBorder,
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return Dictionary.emptyFieldErrorMessage;
        }
        return null;
      },
    );
  }
}

class PasswordSignupTextField extends StatelessWidget {
  
  final TextEditingController controller;
  
  const PasswordSignupTextField(
    this.controller,
    {super.key}
    );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: Dictionary.password,
        hintStyle: AppConstants.hintStyle,
        enabledBorder: AppConstants.defaultFieldBorder,
        focusedBorder: AppConstants.focusedFieldBorder,
        errorBorder: AppConstants.errorFieldBorder,
        focusedErrorBorder: AppConstants.focusedErrorFieldBorder,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return Dictionary.emptyFieldErrorMessage; // Password is required
        }
        if (value.length < 8) {
          return Dictionary.passwordLengthErrorMessage; // Password must be at least 8 characters
        }
        final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
        final hasNumber = RegExp(r'\d').hasMatch(value);
        if (!hasLetter || !hasNumber) {
          return Dictionary.passwordFormatErrorMessage; // Password must contain letters and numbers
        }
        return null; // Return null if the validation is successful
      }
    );
  }
}

class PasswordConfirmationTextField extends StatelessWidget {
  
  final TextEditingController confirmationPassword;
  final TextEditingController enteredPassword;


  const PasswordConfirmationTextField(
    this.confirmationPassword,
    this.enteredPassword,
    {super.key}
    );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: TextFormField(
        controller: confirmationPassword,
        obscureText: true,
        decoration: InputDecoration(
          hintText: Dictionary.passwordConfirmation,
          hintStyle: AppConstants.hintStyle,
          enabledBorder: AppConstants.defaultFieldBorder,
          focusedBorder: AppConstants.focusedFieldBorder,
          errorBorder: AppConstants.errorFieldBorder,
          focusedErrorBorder: AppConstants.focusedErrorFieldBorder,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return Dictionary.emptyFieldErrorMessage; // Password is required
          }
          if (value != enteredPassword.text){
            return Dictionary.passwordConfirmationErrorMessage;
          }
          return null; // Return null if the validation is successful
        }
      ),
    );
  }
}