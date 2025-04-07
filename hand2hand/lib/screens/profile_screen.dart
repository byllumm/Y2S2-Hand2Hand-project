import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/screens/my_items_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const ProfileScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "MY PROFILE",
              style: GoogleFonts.redHatDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 66, 66, 66),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyItemsScreen()),
                );
              },
              child: Text("My Items"),
            ),
          ],
        ),
      ),
    );
  }
}
