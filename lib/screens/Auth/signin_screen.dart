import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/screens/Auth/reset_password_screen.dart';
import 'package:attendance_tracker/screens/Auth/signup_screen.dart';
import 'package:attendance_tracker/utils/date_format_utils.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/navigation_buttons.dart';
import 'package:attendance_tracker/widgets/buttons/firebase_auth_button.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:attendance_tracker/widgets/textFields/emailTextField.dart';
import 'package:attendance_tracker/widgets/textFields/passwordTextField.dart';
import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  void _handleSignin(void _) {
    _emailController.clear();
    _passwordController.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormatUtils.formatHijriDate(DateTime.now()),
                        style: AppConstants.textButtonStyle,
                      ),
                    ],
                  ),
                  // Logo Section
                  AppConstants.logo,
                  // Title
                  Text(
                    AppConstants.appTitle,
                    style: AppConstants.titleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
      
                  // Google SignIn button
                  FirebaseAuthButton(
                    onPressed: () async {
                      try{
                        await AuthProvider().signInWithGoogle()
                        .then(_handleSignin);
                      }
                      catch (e){
                        showSnackBar(context, '$e');
                      }
                    },
                    text: Dictionary.googleSignIn,
                    imagePath: "lib/assets/images/google-logo-white.png",
                  ),

                  SizedBox(height: 20),
      
                  Divider(
                    color: Colors.grey, // Customize the color
                    thickness: 1,       // Adjust the thickness
                  ),
                  SizedBox(height: 20),
      
                  // Email Field
                  EmailTextField(controller: _emailController),
                  SizedBox(height: 20),
      
                  // Password Field
                  PasswordTextField(controller: _passwordController),
                  SizedBox(height: 20),

                  // Sign In Button
                  FirebaseAuthButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, sign in
                        try{
                          await AuthProvider().signInWithEmail(_emailController.text, _passwordController.text)
                          .then(_handleSignin);
                        }
                        catch (e){
                          showSnackBar(context, '$e');
                        }
                      } else {
                        // The error state will be triggered by the validator returning an error message
                      }
                    },
                    text: Dictionary.signIn
                  ),
                  SizedBox(height: 15),

                  // Navigate to resetting password
                  TextNavButton(text: Dictionary.forgetPassword, nextScreen: ResetPasswordScreen()),
                  SizedBox(height: 10,),
                  
                  // Navigating to signing up
                  TextNavButton(text: Dictionary.signUp, nextScreen: SignupScreen()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}