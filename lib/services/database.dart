import 'package:flash_chat/models/fridge.dart';
import 'package:flash_chat/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference fridgeCollection = FirebaseFirestore.instance.collection('smartFridge');
  
  Future<void> updateUserData({String name}) async {
    //fridgeCollection.doc(uid).collection('fridge').add({'name' : '','expiryDate' : DateTime.now(),});
    return await fridgeCollection.doc(uid).set({
      'name': name,
    },
    );
  }

  // brew list from snapshot
  List<Fridge> _fridgeListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      //print(doc.data);
      return Fridge(
        id : doc.id,
        name: doc.get('name') ?? '',
        expiryDate: doc.get('expiryDate')
      );
    }).toList();
  }

  // user data from snapshots
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
       name: snapshot.get('name'),
        strength: snapshot.get('strength'), 
        sugars: snapshot.get('sugars'),
    );
  }

  // get fridge stream
  Stream<List<Fridge>> get fridge {
    final CollectionReference fridge = fridgeCollection.doc(uid).collection('fridge');
    return fridge.snapshots()
      .map(_fridgeListFromSnapshot);
  }

  // get user doc stream
  Stream<UserData> get userData {
    return fridgeCollection.doc(uid).snapshots()
      .map(_userDataFromSnapshot);
  }

  //add to fridge
  Future<void> updatFridgeData({String name, DateTime expiryDate}) async {
    return await fridgeCollection.doc(uid).collection('fridge').add(
      {
        'name' : name ?? 'item',
        'expiryDate' : expiryDate != null ? expiryDate.toLocal() : DateTime.now().toLocal().add(const Duration(days:  3))
      });
  }


  //delete from fridge
  Future<void> deleteData({String id}) async {
   return await fridgeCollection.doc(uid).collection('fridge').doc(id).delete();
    // return await item.get().then((value) {
    //   for(var temp in value.docs){
    //     temp.reference.delete();
    //   }
    // });
  }

}