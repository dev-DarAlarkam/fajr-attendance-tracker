import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SigninButton extends StatelessWidget {
  final GlobalKey<FormState> formKey; 
  final TextEditingController email; //TODO: check why a string doesn't work
  final TextEditingController password;
  
  const SigninButton(
    this.formKey,
    this.email,
    this.password,
    {super.key}
    );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
            onPressed: () async {
              // TODO: Implement the sign-in logic here
              if (formKey.currentState!.validate()) {
                // If the form is valid, sign in
                try{
                  await AuthProvider().signInWithEmail(email.text, password.text);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SplashScreen()));
                }
                catch (e){
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
                Dictionary.signIn,
                style: TextStyle(fontSize: 18, color: AppConstants.backgroundPrimaryColor),
              ),
            ),
          );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
            onPressed: () async {
              try{
                  await AuthProvider().signInWithGoogle();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SplashScreen()));
                }
                catch (e){
                  showSnackBar(context, '$e');
                }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'lib/assets/images/google-logo-white.png',
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 10,),
                Text(
                  Dictionary.googleSignIn,
                  style: TextStyle(fontSize: 18, color: AppConstants.backgroundPrimaryColor),
                ),

              ],
            )
          );
  }
}