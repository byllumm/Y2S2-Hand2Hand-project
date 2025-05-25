import 'package:flutter/material.dart';
import 'screens/my_items_screen.dart';
import 'sign_up_screen.dart';
import 'sign_in_screen.dart';
import '../supabase_service.dart';

final service = SupabaseService();

void navigateToBrowseItemsScreen(BuildContext context, SupabaseService service) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MyItemsScreen(service: service)),
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


void navigateWithTransition(BuildContext context, Widget page) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        var scaleTween = Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.easeOut));
        var scaleAnimation = animation.drive(scaleTween);

        var opacityTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut));
        var opacityAnimation = animation.drive(opacityTween);

        return SlideTransition(position: offsetAnimation, child:ScaleTransition(scale: scaleAnimation, child: FadeTransition(opacity: opacityAnimation, child: child,),),);
      },
    ),
  );
}
