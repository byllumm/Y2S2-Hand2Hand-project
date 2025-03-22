import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

const supabaseUrl = 'https://fcmwinsdrdxzizfngqig.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZjbXdpbnNkcmR4eml6Zm5ncWlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI1NzYyMDcsImV4cCI6MjA1ODE1MjIwN30.1Zl6Zj-4VxMKi6SXOwR9CunaXMAhWMyZi-mMVn6rx7Y';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hand2Hand',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
