import 'package:attendance_tracker/app_constants.dart';
import 'package:flutter/material.dart';

class FirebaseAuthButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String text;
  final String? imagePath;


  const FirebaseAuthButton({
    required this.onPressed,
    required this.text,
    this.imagePath,
    super.key
    });

  @override
  State<FirebaseAuthButton> createState() => _FirebaseAuthButtonState();
}

class _FirebaseAuthButtonState extends State<FirebaseAuthButton> {
  bool _isLoading = false;

  
  void _handlePress() async {
    
    setState(() {
      _isLoading = true;
    });

    // Call the parent onPressed method
    await widget.onPressed();

    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
   
    return Stack(
      alignment: Alignment.center,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _handlePress,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(400,50),
            backgroundColor: _isLoading ? Colors.grey : AppConstants.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: 
          widget.imagePath == null 
          ? Text(
                _isLoading ? '' : widget.text, 
                style: TextStyle(fontSize: 18, color: AppConstants.backgroundPrimaryColor),
                )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  widget.imagePath!,
                  height: 24, // Adjust size as needed
                  width: 24,
                ),
                SizedBox(width: 10),

                Text(
                  _isLoading ? '' : widget.text, 
                  style: TextStyle(fontSize: 18, color: AppConstants.backgroundPrimaryColor),
                  ),
              ],
            ),
        ),
        if (_isLoading)
          Positioned(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }
}
