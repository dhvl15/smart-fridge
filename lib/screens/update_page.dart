import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_fridge/models/user.dart';
import 'package:flutter/material.dart';
import 'package:smart_fridge/services/database.dart';
import 'package:smart_fridge/widgets/roundedButton.dart';
import 'package:smart_fridge/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class UpdateScreen extends StatefulWidget {
  static const id = "update_screen";
  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String error = '';
  String email,password,name, imageUrl;
  bool showSpinner = false;
  UserData _userData;
  File imageFile;
  XFile pickedImage;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    MyUser user = Provider.of<MyUser>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar : AppBar(
        elevation: 0.0,
        title: Text('Profile Page'),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            _userData = snapshot.data;
            return ModalProgressHUD(
              inAsyncCall: showSpinner,
              child: SingleChildScrollView(
                child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: Stack(
                          children: [
                  //                       Container(
                  //                         decoration: BoxDecoration(
                  //                           borderRadius : BorderRadius.circular(100),
                  //                           image: DecorationImage(
                  //                             image : imageFile != null 
                  // ? FileImage(imageFile)
                  // : snapshot.data.imageUrl == null || snapshot.data.imageUrl == "" ? AssetImage('assets/images/refrigerator.png') : NetworkImage(snapshot.data.imageUrl)),
                  //                         ),
                  //                         height: 200.0,
                  //                         // child: snapshot.data.imageUrl == null || snapshot.data.imageUrl == ""
                  //                         //   ? imageFile == null 
                  //                         //     ? Image.asset('assets/images/refrigerator.png')
                  //                         //     : Image.file(imageFile)
                  //                         //   : Image.network(snapshot.data.imageUrl),
                  //                       ),
                            CircleAvatar(
                              radius: 100,
                              backgroundImage : imageFile != null 
                                ? FileImage(imageFile)
                                : snapshot.data.imageUrl == null || snapshot.data.imageUrl == "" ? AssetImage('assets/images/refrigerator.png') : NetworkImage(snapshot.data.imageUrl),
                            ),
                            Positioned(
                              top: 0,
                              right:0,
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
                      
                      TextFormField(
                        initialValue: _userData.name,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        decoration: kTextFieldDecoration.copyWith(
                            hintText: "Enter your name"),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      TextFormField(
                        enabled: false,
                        initialValue: _userData.email,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          //Do something with the user input.
                          email = value;
                        },
                        decoration:
                            kTextFieldDecoration.copyWith(hintText: "Enter your email"),
                        // validator: (value) {
                        //   if(!value.startsWith(RegExp(r'[A-Z][a-z]'))){
                        //     return 'enter valid email';
                        //   }else if (!value.contains('@')) {
                        //     return 'enter valid email';
                        //   } else if(!value.contains('.')){
                        //     return 'enter valid email';
                        //   }else{
                        //     return null;
                        //   }
                        // },
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      RoundedButton(
                        onPressed: () async {
                          if(_formKey.currentState.validate()){
                          await DatabaseService(uid: user.uid).updateUserData(
                              name : name ?? snapshot.data.name, 
                              email : snapshot.data.email, 
                              imageUrl : imageUrl ?? snapshot.data.imageUrl,
                            ).catchError((e){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(e.toString()),
                                behavior: SnackBarBehavior.fixed,
                                backgroundColor: Colors.red.shade600,
                              ));
                          });
                            Navigator.pop(context);
                        }
                        },
                        title: "Update",
                        colour: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
                        ),
              ),
            );
          }else{
            return ModalProgressHUD(inAsyncCall: true, child: Container());
          }
        }
      ),
    );
  }


  // Select and image from the gallery or take a picture with the camera
  // Then upload to Firebase Storage
  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    try {
      pickedImage = await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      final String fileName = path.basename(pickedImage.path);

      setState(() {
        imageFile = File(pickedImage.path);
        showSpinner = true;
      });

      try {
        // Uploading the selected image with some custom meta data
        TaskSnapshot snapshot = await storage.ref(fileName).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              'uploaded_by': 'A bad guy',
              'description': 'Some description...'
            }));

        if (snapshot.state == TaskState.success) {
          String url = await snapshot.ref.getDownloadURL();

          if(url!=null){
            // Refresh the UI
            setState(() {
              imageUrl = url;
              showSpinner=false;
            });
            print(imageUrl);
          }
            // final snackBar =
            //     SnackBar(content: Text('Yay! Success'));
            // ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            print(
                'Error from image repo ${snapshot.state.toString()}');
            throw ('This file is not an image');
          }
      } on FirebaseException catch (error) {
        print(error);
      }
    } catch (err) {
        print(err);
    }
  }
}
