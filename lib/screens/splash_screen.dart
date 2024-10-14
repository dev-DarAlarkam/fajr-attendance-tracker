import 'package:attendance_tracker/app_constants.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to changes in AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          print(authProvider.user.toString());
          print(authProvider.user!.email);
          // Navigate to the Home screen if the user is authenticated
          Future.microtask(() => Navigator.pushNamedAndRemoveUntil(context, '/user', (route)=>false));
        } else {
          // Navigate to the Login screen if the user is not authenticated
          Future.microtask(() => Navigator.pushNamedAndRemoveUntil(context, '/login', (route)=>false));
        }
        
        // Display a loading spinner while determining navigation
        return Scaffold(
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
                      AppConstants.appTitle,
                      style: AppConstants.titleTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            )
          ),
        );
      },
    );
  }
}