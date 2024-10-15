import 'package:attendance_tracker/app_constants.dart';
import 'package:flutter/material.dart';

class FirebaseActionButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String text;


  const FirebaseActionButton({
    required this.onPressed,
    required this.text,
    super.key
    });

  @override
  State<FirebaseActionButton> createState() => _FirebaseActionButtonState();
}

class _FirebaseActionButtonState extends State<FirebaseActionButton> {
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
          child:Text(
                _isLoading ? '' : widget.text, 
                style: TextStyle(fontSize: 18, color: AppConstants.backgroundPrimaryColor),
          )
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
