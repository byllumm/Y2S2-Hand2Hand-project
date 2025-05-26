import 'package:flutter/material.dart';
import 'navigation_helper.dart';

class Controller extends StatelessWidget {
  const Controller({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Text(
            'Welcome to Hand2Hand',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(223, 255, 213, 63),
              letterSpacing: 1.2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Image.asset('assets/logo.png', height: 250),
          ),
          SizedBox(height: 50),
          Center(
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  navigateToSignInScreen(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(223, 255, 213, 63),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Log In'),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  navigateToSignUpScreen(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Color.fromARGB(223, 255, 213, 63),
                      width: 2,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Sign Up'),
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
