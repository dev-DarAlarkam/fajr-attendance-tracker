import 'package:flutter/material.dart';

//TODO: translate the important errors to arabic
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message))
  );
}