import 'package:attendance_tracker/utils/dictionary.dart';
import 'package:flutter/material.dart';

class AppConstants {
  
  // Important strings
  static const String appTitle = Dictionary.title;

  static const String none = "none";
  static const String other = "other";
  static const String trueAsString = "true";
  static const String falseAsString = "false";

  ///--------------------------------------------------------------
  ///Logo:
  static const String logoPath = 'lib/assets/images/logo.png';
  static Image logo = Image.asset(
                    logoPath, // Adjust the logo path
                    width: 100,
                    height: 100,
                  );
              

  ///--------------------------------------------------------------
  ///Style Constants:
  
  //Colors
  static const Color primaryColor = Color(0xFF0F9447);
  static const Color secondaryColor = Color(0xFFF9BF18);
  static const Color backgroundPrimaryColor = Color.fromRGBO(241, 242, 246, 1);
  static const Color backgroundSecondaryColor = Colors.white; 
  static const Color shadowColor = Color.fromRGBO(0, 0, 0, 0.1);

  //Values
  static EdgeInsets padding = EdgeInsets.symmetric(vertical: 40, horizontal: 30);
  static EdgeInsets margin = EdgeInsets.symmetric(vertical: 40, horizontal: 30);
  static EdgeInsets containerMargain = EdgeInsets.symmetric(vertical: 10, horizontal: 30);
  static BorderRadius borderRadius = BorderRadius.circular(8);

  //TODO: add this style and others as a TextTheme
  //Text
  static TextStyle titleTextStyle = TextStyle(
                    fontSize: 26,
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  );

  //Box/Containers
  static BoxShadow boxShadow = BoxShadow(
                  color: shadowColor,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                );


  static BoxDecoration boxDecoration =  BoxDecoration(
              color: backgroundSecondaryColor,
              borderRadius: borderRadius,
              boxShadow: [boxShadow],
              border: Border(
                top: BorderSide(color: AppConstants.primaryColor, width: 6),
              ),
            );

  //Action Buttons
  static ButtonStyle actionButtonStyle = ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: borderRadius,
                    ),
                  );
  
  //Text Buttons
  static TextStyle textButtonStyle = TextStyle(
                fontSize: 16,
                color: AppConstants.primaryColor,
              );

  //Text Fields
  static TextStyle hintStyle = TextStyle(color: Colors.grey);
  static OutlineInputBorder defaultFieldBorder = OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(8.0), // Optional: add rounded corners
        );
  static OutlineInputBorder focusedFieldBorder = OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2.5),
          borderRadius: BorderRadius.circular(8.0),
        );
  static OutlineInputBorder errorFieldBorder = OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        );
  static OutlineInputBorder focusedErrorFieldBorder = OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2.5),
          borderRadius: BorderRadius.circular(8.0),
        );

}