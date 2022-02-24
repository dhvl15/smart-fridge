import 'package:cloud_firestore/cloud_firestore.dart';

class Fridge{

  final String name;
  final Timestamp expiryDate;
  String id;

  Fridge({ this.name, this.expiryDate, this.id});

  Fridge.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        expiryDate = Timestamp.fromDate(DateTime.tryParse(json['expiryDate']));

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'expiryDate': expiryDate.toDate().toString(),
    };
  }
}