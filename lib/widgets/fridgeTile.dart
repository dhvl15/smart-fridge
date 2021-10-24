import 'package:intl/intl.dart';
import 'package:smart_fridge/models/fridge.dart';
import 'package:smart_fridge/services/database.dart';
import 'package:flutter/material.dart';

class FridgeTile extends StatelessWidget {

  final Fridge fridgeItem;
  final uid;
  FridgeTile({ this.fridgeItem, this.uid});

  Widget checkDate(){
    // print(DateFormat('dd-MM-yyyy').format(fridgeItem.expiryDate.toDate()).compareTo(DateFormat('dd-MM-yyyy').format(DateTime.now())));
    if (DateFormat('dd-MM-yyyy').format(fridgeItem.expiryDate.toDate()).compareTo(DateFormat('dd-MM-yyyy').format(DateTime.now()))==0) {
      
      return Row(children: [
        Icon(Icons.error_outline_rounded, color: Colors.red, size: 15,),
        Text('Expires today',style: TextStyle(color: Colors.red)),
      ],);
    } else {
      return Text('Expires on ${fridgeItem.expiryDate.toDate().day}/${fridgeItem.expiryDate.toDate().month}/${fridgeItem.expiryDate.toDate().year}');
    }
  }
  

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
          subtitle: checkDate(),
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