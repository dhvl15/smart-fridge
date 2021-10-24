import 'package:flash_chat/models/fridge.dart';
import 'package:flash_chat/services/database.dart';
import 'package:flutter/material.dart';

class FridgeTile extends StatelessWidget {

  final Fridge fridgeItem;
  final uid;
  FridgeTile({ this.fridgeItem, this.uid});
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.teal.shade600,
            backgroundImage: AssetImage('images/logo2.png'),
          ),
          title: Text(fridgeItem.name),
          subtitle: Text('Expires on ${fridgeItem.expiryDate.toDate().day}/${fridgeItem.expiryDate.toDate().month}/${fridgeItem.expiryDate.toDate().year}'),
          trailing: IconButton(
            onPressed: (){
              DatabaseService(uid:uid).deleteData(id: fridgeItem.id);
            }, 
            icon: Icon(Icons.delete_outline_rounded),color: Colors.red,)
        ),
      ),
    );
  }
}