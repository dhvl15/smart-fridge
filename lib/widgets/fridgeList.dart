import 'package:flash_chat/models/fridge.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flash_chat/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flash_chat/models/fridge.dart';
import 'package:flash_chat/widgets/fridgeTile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FridgeList extends StatefulWidget {
  @override
  _FridgeListState createState() => _FridgeListState();
}

class _FridgeListState extends State<FridgeList> {
  

  @override
  Widget build(BuildContext context) {

    final fridge = Provider.of<List<Fridge>>(context) ?? [];
    MyUser _user = AuthService().getCurrentUser();

    return ListView.builder(
      itemCount: fridge.length,
      itemBuilder: (context, index) {
        return FridgeTile(fridgeItem: fridge[index], uid: _user.uid,);
      },
    );
  }
}