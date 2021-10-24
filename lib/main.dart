import 'package:firebase_core/firebase_core.dart';
import 'package:smart_fridge/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:smart_fridge/screens/welcome_screen.dart';
import 'package:smart_fridge/screens/login_screen.dart';
import 'package:smart_fridge/screens/registration_screen.dart';
//import 'dart:html';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData.dark().copyWith(
      //   textTheme: TextTheme(
      //     bodyText2: TextStyle(color: Colors.black54),
      //   ),
      // ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
      },
    );
  }
}
