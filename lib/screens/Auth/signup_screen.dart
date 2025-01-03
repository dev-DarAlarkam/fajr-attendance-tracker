import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:attendance_tracker/widgets/buttons/firebase_auth_button.dart';
import 'package:attendance_tracker/widgets/show_snack_bar.dart';
import 'package:attendance_tracker/widgets/textFields/emailTextField.dart';
import 'package:attendance_tracker/widgets/textFields/passwordTextField.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
                    Dictionary.signUp,
                    style: AppConstants.titleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Email Fields
                  EmailSignupTextField(_emailController),
                  EmailConfirmationTextField(_confirmEmailController, _emailController),
                  SizedBox(height: 20),
                  // Password Fields
                  PasswordSignupTextField(_passwordController),
                  PasswordConfirmationTextField(_confirmPasswordController, _passwordController),
                  SizedBox(height: 20),
                  // Sign-Up Button
                  FirebaseAuthButton(
                    onPressed: () async {
                      // Validate the form
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, sign the user up
                        try{
                          await AuthProvider().signUpWithEmail(_emailController.text, _passwordController.text);
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route)=>false);
                          showSnackBar(context, Dictionary.emailVerificationMessage);
                        }
                        catch (e) {
                          showSnackBar(context, '$e');
                        }
                      } else {
                        // The error state will be triggered by the validator returning an error message
                      }
                    }, 
                    text: Dictionary.signUp
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signup() async {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      // If the form is valid, sign the user up
      try{
        await AuthProvider().signUpWithEmail(_emailController.text, _passwordController.text);
        Navigator.pushNamedAndRemoveUntil(context, '/', (route)=>false);
        showSnackBar(context, Dictionary.emailVerificationMessage);
      }
      catch (e) {
        showSnackBar(context, '$e');
      }
    } else {
      // The error state will be triggered by the validator returning an error message
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _confirmEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}