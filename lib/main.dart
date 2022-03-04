import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge/models/user.dart';
import 'package:smart_fridge/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:smart_fridge/screens/update_page.dart';
import 'package:smart_fridge/screens/welcome_screen.dart';
import 'package:smart_fridge/screens/login_screen.dart';
import 'package:smart_fridge/screens/registration_screen.dart';
import 'package:smart_fridge/services/auth.dart';

List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  runApp(SmartFridge());
}

class SmartFridge extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamProvider<MyUser>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Wrapper.id,
      routes: {
        Wrapper.id: (context) => Wrapper(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(cameras : cameras),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        UpdateScreen.id: (context) => UpdateScreen(),
      },
      //home: Wrapper(),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     // theme: ThemeData.dark().copyWith(
  //     //   textTheme: TextTheme(
  //     //     bodyText2: TextStyle(color: Colors.black54),
  //     //   ),
  //     // ),
  //     debugShowCheckedModeBanner: false,
  //     initialRoute: WelcomeScreen.id,
  //     routes: {
  //       WelcomeScreen.id: (context) => WelcomeScreen(),
  //       LoginScreen.id: (context) => LoginScreen(),
  //       HomeScreen.id: (context) => HomeScreen(cameras : cameras),
  //       RegistrationScreen.id: (context) => RegistrationScreen(),
  //       UpdateScreen.id: (context) => UpdateScreen(),
  //     },
  //   );
  // }
}

class Wrapper extends StatelessWidget {
  static const id = "wrapper";
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<MyUser>(context);
    
    // return either the Home or Authenticate widget
    if (user == null){
      return WelcomeScreen();
    } else {
      return HomeScreen(cameras : cameras);
    }
    
  }
}
