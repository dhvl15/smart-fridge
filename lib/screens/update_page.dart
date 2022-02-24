import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_fridge/screens/home_screen.dart';
import 'package:smart_fridge/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_fridge/widgets/roundedButton.dart';
import 'package:smart_fridge/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const id = "registration_screen";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String error = '';
  String email;
  String password;
  String name;
  bool showSpinner = false;
  //final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar : AppBar(
        //backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('SmartFridge Signup'),
        // actions: <Widget>[
        //   TextButton.icon(
        //     icon: Icon(Icons.person),
        //     label: Text('Sign In',style: TextStyle(color: Colors.blueAccent),),
        //     onPressed: () => Navigator.popAndPushNamed(context, ChatScreen.id),
        //   ),
        // ],
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        //progressIndicator: LinearProgressIndicator(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Stack(
                    children: [
                      Hero(
                        tag: "logo",
                        child: Container(
                          height: 200.0,
                          child: Image.asset('assets/images/refrigerator.png'),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: IconButton(
                            color: Colors.white,
                            iconSize: 30,
                            onPressed: (){
                              _upload('camera');
                            }, 
                            icon: Icon(Icons.add_a_photo_rounded)),
                        ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                
                TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    //Do something with the user input.
                    name = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: "Enter your name"),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    //Do something with the user input.
                    email = value;
                  },
                  decoration:
                      kTextFieldDecoration.copyWith(hintText: "Enter your email"),
                  validator: (value) {
                    if(!value.startsWith(RegExp(r'[A-Z][a-z]'))){
                      return 'enter valid email';
                    }else if (!value.contains('@')) {
                      return 'enter valid email';
                    } else if(!value.contains('.')){
                      return 'enter valid email';
                    }else{
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (value) {
                    //Do something with the user input.
                    password = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: "Enter your password"),
                  validator: (value){
                    if(value.length < 6){
                      return 'minimum 6 characters required';
                    }else{
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  onPressed: () async {
                    if(_formKey.currentState.validate()){
                    setState(() => showSpinner = true);
                    //dynamic result = await 
                    _auth.register(email:email, password:password,name:name).then((result) {
                      if (result != null) {
                        Navigator.pushNamedAndRemoveUntil(context, HomeScreen.id, (route) => false);
                      }
                      setState(() {
                        showSpinner = false;
                      });
                    }).catchError((e){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.toString()),
                          behavior: SnackBarBehavior.fixed,
                          backgroundColor: Colors.red.shade600,
                        ));
                    });
                  }
                  },
                  title: "Register",
                  colour: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Select and image from the gallery or take a picture with the camera
  // Then upload to Firebase Storage
  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      final String fileName = path.basename(pickedImage.path);
      File imageFile = File(pickedImage.path);

      try {
        // Uploading the selected image with some custom meta data
        TaskSnapshot snapshot = await storage.ref(fileName).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              'uploaded_by': 'A bad guy',
              'description': 'Some description...'
            }));

        if (snapshot.state == TaskState.success) {
            final String downloadUrl =
                await snapshot.ref.getDownloadURL();
            final snackBar =
                SnackBar(content: Text('Yay! Success'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            print(
                'Error from image repo ${snapshot.state.toString()}');
            throw ('This file is not an image');
          }

        // Refresh the UI
        setState(() {});
      } on FirebaseException catch (error) {
        print(error);
      }
    } catch (err) {
        print(err);
    }
  }
}







  