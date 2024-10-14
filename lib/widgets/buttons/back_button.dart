import 'package:attendance_tracker/app_constants.dart';
import 'package:flutter/material.dart';

class BackButton extends StatelessWidget {
  const BackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {Navigator.pop(context);}, 
      icon: Icon(Icons.arrow_back, color: AppConstants.primaryColor,),
      );
  }
}