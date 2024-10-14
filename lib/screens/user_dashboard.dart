import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("you've signed in"),
            IconButton(onPressed: () async {
              await AuthProvider().signOut().then((onValue) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SplashScreen()));
              });
            }, icon: Icon(Icons.ac_unit_outlined))
            
          ],
        ),
      ),
    );
  }
}