import 'package:cloud_firestore/cloud_firestore.dart';

class Fridge{

  final String name;
  final Timestamp expiryDate;
  String id;

  Fridge({ this.name, this.expiryDate, this.id});

}