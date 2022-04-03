import 'package:camera/camera.dart';
import 'package:smart_fridge/models/fridge.dart';
import 'package:smart_fridge/models/user.dart';
import 'package:smart_fridge/screens/login_screen.dart';
import 'package:smart_fridge/screens/object_detection/live_camera.dart';
import 'package:smart_fridge/screens/update_page.dart';
import 'package:smart_fridge/services/auth.dart';
import 'package:smart_fridge/services/database.dart';
import 'package:smart_fridge/widgets/fridgeList.dart';
import 'package:flutter/material.dart';
import 'package:smart_fridge/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  static const id = "home_screen";
  final List<CameraDescription> cameras;
  HomeScreen({this.cameras});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final AuthService _auth = AuthService();
  MyUser currentUser;
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemDateController = TextEditingController();
  TextEditingController _numberController = TextEditingController();
  DateTime expiryDate;
  String itemName;
  List<Fridge> temp;  
  String phone;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.getCurrentUser();
    getData();
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
          //     child: Image.asset('assets/images/refrigerator.png',height: 40,)),
          // ),
          //leadingWidth: 50,
          title: Text('MY FRIDGE', style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.teal,
          elevation: 0.0,
          actions: <Widget>[
            IconButton(onPressed: (){
              Navigator.pushNamed(context, UpdateScreen.id);
            }, icon: Icon(Icons.person_outlined, color: Colors.black,),),
            TextButton(
              child: Text('logout', style: TextStyle(color: Colors.black),),
              onPressed: () async {
                _auth.signOut().then((value) {
                  Navigator.popAndPushNamed(context, LoginScreen.id);
                });
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
              image: AssetImage('assets/images/empty.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: FridgeList()
        ),
        //floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton:  Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "addItem",
                  backgroundColor: Colors.teal.shade800,
                  onPressed: ()async{
                    //itemName = null;
                    itemName = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LiveFeed(widget.cameras)));
                    if(itemName!=null){
                      DatabaseService(uid: currentUser.uid).updatFridgeData(name: itemName);
                    }
                  },
                  child: Icon(Icons.linked_camera_rounded)
              ),
              SizedBox(height: 5,),
              FloatingActionButton(
                heroTag: "liveFeed",
                  backgroundColor: Colors.teal.shade800,
                  onPressed: ()async{
                    //DatabaseService(uid: currentUser.uid).updatFridgeData(name: 'apple');
                    _itemDateController.clear();
                    _itemNameController.clear();
                      setState(() {
                        itemName = null;
                        expiryDate = null;
                      });
                    _displayTextInputDialog(context);
                  },
                  child: Icon(Icons.post_add),
              ),
          ],
        ),
      ),
    );
  }

  void clear(){
    _itemDateController.clear();
    _itemNameController.clear();
    setState(() {
      itemName = null;
      expiryDate = null;
    });
  }


  //Dialog box
  Future<void> _displayTextInputDialog(BuildContext context) async {
    //clear();
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
                      keyboardType: TextInputType.datetime,
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

  @override
  void dispose() {
    super.dispose();
  }

  void getData()async {
    temp = await DatabaseService(uid: _auth.getCurrentUser().uid).getData();
    if(temp.isNotEmpty){
      //print(temp.toString());
      dialog(context);
    }
  }

  void dialog(BuildContext context)async {
    
    var res = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                Text("Items Expiring Soon..."),
                Text('contact store and order now!', style: TextStyle(fontSize: 12),)
              ],
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: TextFormField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      onChanged: (value){
                        setState(() {
                          phone = value;
                        });
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Store Number',
                          prefixIcon: Icon(Icons.call)),
                      validator: (value) {
                        if(value.length<10 || value.length>10){
                          return "Enter valid phone number";
                        }else{
                          return null;
                        }
                      },
                    ),
                  ),
                  Expanded(child: _buildListView()),
                  ],
              ),
            ),
            actions: [
              TextButton(onPressed: (){Navigator.pop(context);}, child: Text('cancle')),
              IconButton(onPressed: (){
                Navigator.pop(context, "call");
              }, icon: Icon(Icons.phone, color:Colors.green)),
              IconButton(onPressed: (){
                Navigator.pop(context, "message");
              }, icon: Icon(Icons.message, color: Colors.blueAccent)),
            ],
          );
        });
    if (res == "call"){
      if(_numberController.text.length == 10){
        launch('tel://91${_numberController.text}');
      } 
    }else if(res == "message"){
      if(_numberController.text.length == 10){
        whatsapp();
      } 
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: temp.length,
      //separatorBuilder: (ctx, i) => Divider(height: 0),
      itemBuilder: (context, index) {
        final fridgeItem = temp[index];
        return ListTile(
            title: Text(
              fridgeItem.name,
              style: TextStyle(color: Colors.black),
            ),
            subtitle: Text('Expires on ${fridgeItem.expiryDate.toDate().day}/${fridgeItem.expiryDate.toDate().month}/${fridgeItem.expiryDate.toDate().year}'),
            
            );
      },
    );
  }

  void whatsapp() {
    String items ='''''';
    temp.forEach((element) {
      items = items + "${element.name}\n";
    });
    try {
      final url = "https://api.whatsapp.com/send?phone=91${_numberController.text}&text=" +
          "shopping list \n\n"+
              items+"\n\nPlease give me a call before you come to deliver.";
      final encodeURL = Uri.encodeFull(url);

      // print("final url to open:" + url);
      // print("final url to open: encode url " + encodeURL);
      launch(encodeURL);
    }catch(error){
      print("Launch Error:" + error.toString());
    }
  }
}



