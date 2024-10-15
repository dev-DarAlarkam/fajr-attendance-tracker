import 'package:attendance_tracker/app_constants.dart';
import 'package:flutter/material.dart';

class TextNavButton extends StatelessWidget {
  final String text;
  final Widget nextScreen;

  const TextNavButton({
    required this.text,
    required this.nextScreen,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => nextScreen));
      } , 
      child: Text(
        text,
        style: AppConstants.textButtonStyle,
      )
    );
  }
}

class ElevatedNavButton extends StatelessWidget {
  final String text;
  final Widget nextScreen;

  const ElevatedNavButton({
    required this.text,
    required this.nextScreen,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => nextScreen));
      } ,          
      style: ElevatedButton.styleFrom(
        minimumSize: Size(400,50),
        backgroundColor:AppConstants.primaryColor,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child:Text(
        text, 
        style: TextStyle(fontSize: 18, color: AppConstants.backgroundPrimaryColor),
      )
    );
  }
}
