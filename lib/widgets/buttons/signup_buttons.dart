import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/screens/signup_screen.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';

class SignupTextButton extends StatelessWidget {
  const SignupTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
            },
            child: Text(
              Dictionary.signUp,
              style: AppConstants.textButtonStyle
            ),
          );
  }
}

class SignupActionButton extends StatelessWidget {

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  
  const SignupActionButton(
    this.formKey,
    this.email,
    this.password,
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
            onPressed: () async {
              // Validate the form
              if (formKey.currentState!.validate()) {
                // If the form is valid, sign the user up
                try{
                  await AuthProvider().signUpWithEmail(email.text, password.text);
                  final user = await AuthProvider().user;
                  print(user.toString());
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route)=>false);
                  showSnackBar(context, Dictionary.emailVerificationMessage);
                }
                catch (e) {
                  showSnackBar(context, '$e');
                  print("$e");
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
                Dictionary.signUp,
                style: TextStyle(fontSize: 18, color: AppConstants.backgroundPrimaryColor),
              ),
            ),
          );
  }
}