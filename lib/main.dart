import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:san_group/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? name, email, emp_id, image, password, post, brunch, user_is_verifyed;
String approver_id = 'Loading...', approver_mobile = 'Loading...';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  password = prefs.getString('password');
  emp_id = prefs.getString('emp_id');

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // var mail = prefs.getString('email');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define your theme properties here
        primaryColor: Colors.blueGrey,

        // Add more theme properties as needed
      ),
      home: AnimatedSplashScreen(
          animationDuration: Duration(milliseconds: 500),
          duration: 500,
          splash: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Image.asset(
                "images/san_group.jpg",
                height: 250,
                width: 250,
              ),
            ),
          ),
          nextScreen:login(),
          splashIconSize: 450,
          splashTransition: SplashTransition.scaleTransition,
          // pageTransitionType:  Animation(),
          backgroundColor: Colors.white),
    );
  }
}
