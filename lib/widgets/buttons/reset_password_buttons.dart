import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/screens/reset_password_screen.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';

class ResetPasswordTextButton extends StatelessWidget {
  const ResetPasswordTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
            onPressed: () {
              // TODO: Navigate to Forgot Password
              Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordScreen()));
            },
            child: Text(
              Dictionary.forgetPassword,
              style: AppConstants.textButtonStyle
            ),
          );
  }
}

class ResetPasswordActionButton extends StatelessWidget {

  final GlobalKey<FormState> formKey;
  final String email;

  const ResetPasswordActionButton(
    this.formKey,
    this.email,
    {super.key}
    );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
            onPressed: () async {

              // TODO: Implement the reset-password logic here
              if (formKey.currentState!.validate()) {
                // If the form is valid, reset password
                try{
                  await AuthProvider().resetPassword(email);
                  showSnackBar(context, ""); //TODO: add a mesage for success
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SplashScreen()));
                }
                catch (e) {
                  showSnackBar(context, '$e');
                }
              } else {
                // The error state will be triggered by the validator returning an error message
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Center(
              child: Text(
                Dictionary.resetPassword,
                style: TextStyle(fontSize: 18, color: AppConstants.backgroundPrimaryColor),
              ),
            ),
          );
  }
}