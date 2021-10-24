import 'package:flash_chat/models/fridge.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/services/auth.dart';
import 'package:flash_chat/services/database.dart';
import 'package:flash_chat/widgets/fridgeList.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const id = "home_screen";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final AuthService _auth = AuthService();
  MyUser currentUser;
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemDateController = TextEditingController();
  DateTime expiryDate;
  String itemName;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Fridge>>.value(
      initialData:[],
      value: DatabaseService(uid: currentUser.uid).fridge,
      child: Scaffold(
        backgroundColor: Colors.teal.shade100,
        appBar: AppBar(
          // leading: Padding(
          //   padding: const EdgeInsets.only(left : 10.0),
          //   child: Hero(
          //      tag: "logo",
          //     child: Image.asset('images/refrigerator.png',height: 40,)),
          // ),
          //leadingWidth: 50,
          title: Text('MY FRIDGE', style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.teal,
          elevation: 0.0,
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.person_outlined, color: Colors.black,),
              label: Text('logout', style: TextStyle(color: Colors.black),),
              onPressed: () async {
                _auth.signOut().then((value) {
                  Navigator.popAndPushNamed(context, LoginScreen.id);
                });
              },
            ),
            // FlatButton.icon(
            //   icon: Icon(Icons.settings),
            //   label: Text('settings'),
            //   onPressed: () => _showSettingsPanel(),
            // )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
              image: AssetImage('images/empty.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: FridgeList()
        ),
        //floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton:  FloatingActionButton(
              backgroundColor: Colors.teal.shade800,
              onPressed: ()async{
                //DatabaseService(uid: currentUser.uid).updatFridgeData(name: 'apple');
                _displayTextInputDialog(context);
              },
              child: Icon(Icons.post_add),
          ),
      ),
    );
  }


  //Dialog box
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add new item'),
          content: Container(
            height: 120,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceA,
              children: [
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.datetime,
                    controller: _itemNameController,
                    decoration: kTextFieldDecoration.copyWith(hintText: 'Enter item name',),
                    onChanged: (value){
                      itemName= value;
                    },
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: expiryDate != null,
                  child: Expanded(
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      controller: _itemDateController,
                      decoration: kTextFieldDecoration.copyWith(hintText: 'Enter item date'),
                      // onChanged: (value){
                      //   setState(() {
                      //     expiryDate = value.;
                      //   });
                      // },
                    ),
                  ),
                ),
                SizedBox(height: 10),
               Expanded(
                 child: TextButton.icon(
                   onPressed: ()async{
                      //DatePickerDialog(initialDate: DateTime.now(),firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 7)));
                      expiryDate = await showDatePicker(context: context, initialDate: DateTime.now(),firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 7)));
                      setState(() {
                        
                        
                        if (expiryDate!=null) {
                          _itemDateController.text = DateFormat('dd-MM-yyyy').format(expiryDate);
}
                      });
                      
                    }, 
                    icon: Icon(Icons.date_range_outlined), 
                    label: Text("Pick expiry date"),
                 ),
               )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                //print(_textFieldController.text);
                DatabaseService(uid: currentUser.uid).updatFridgeData(name: itemName,expiryDate: expiryDate);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}



