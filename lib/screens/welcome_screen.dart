import 'package:smart_fridge/screens/login_screen.dart';
import 'package:smart_fridge/screens/registration_screen.dart';
import 'package:smart_fridge/widgets/roundedButton.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {
  static const id = "welcome_screen";
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();

    // Firebase.initializeApp().whenComplete(() {
    //   print("firebase initialized");
    //   setState(() {});
    // });

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    // for curved animation
    //animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);

    //for ColorTween
    animation = ColorTween(
      begin: Colors.blueGrey.shade500,
      end: Colors.white,
    ).animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: "logo",
                  child: Container(
                    child: Image.asset('assets/images/refrigerator.png'),
                    height: 60.0,
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText(
                      "SmartFridge",
                      textStyle: TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.w900,
                      ),
                      speed: Duration(milliseconds: 150),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              title: "Log In",
              onPressed: () {
                Navigator.of(context).pushNamed(LoginScreen.id);
              },
              colour: Colors.lightBlueAccent,
            ),
            RoundedButton(
              title: "Register",
              onPressed: () {
                Navigator.of(context).pushNamed(RegistrationScreen.id);
              },
              colour: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
