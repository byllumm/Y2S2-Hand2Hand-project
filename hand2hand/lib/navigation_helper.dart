import 'package:flutter/material.dart';
import 'screens/my_items_screen.dart';
import 'sign_up_screen.dart';
import 'sign_in_screen.dart'; // Import the SignInScreen

void navigateToBrowseItemsScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MyItemsScreen()),
  );
}

void navigateToSignUpScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SignUpScreen()),
  );
}

void navigateToSignInScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SignInScreen()),
  );
}
