import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/widgets/buttons/reset_password_buttons.dart';
import 'package:attendance_tracker/widgets/buttons/signin_button.dart';
import 'package:attendance_tracker/widgets/buttons/signup_buttons.dart';
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await AuthProvider().signOut();
                          print("signed out from mainscreen");
                        }, 
                        icon: Icon(Icons.ac_unit_outlined)
                      )
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
                  GoogleSignInButton(),
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
                  SigninButton(
                    _formKey,
                    _emailController,
                    _passwordController
                    ),
                  SizedBox(height: 15),
      
                  // Forgot Password Link
                  ResetPasswordTextButton(),
                  // Create New Account Link
                  SignupTextButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
