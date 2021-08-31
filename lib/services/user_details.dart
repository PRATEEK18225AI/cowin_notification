import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowin_vaccine_slot_notification/utilities/object_converter.dart';

class UserDetails {
  CollectionReference _users = FirebaseFirestore.instance.collection("Users");

  Stream<QuerySnapshot> get studentCollection => _users.snapshots();

  //check
  Future<bool> isNewUser(uid) async {
    var result = await _users.doc(uid).get();
    return result.exists == false;
  }

  //get
  Future<Map<String, dynamic>> getUserDataFromUid(String uid) async {
    var result = await _users.doc(uid).get();
    return ObjectToContainer.toJson(result.data());
  }

  //add
  Future<void> addUserDetails(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).set(data);
  }

  //update
  Future<void> updateUserDetails(uid, data) async {
    await _users.doc(uid).update(data);
  }

  Future<void> updateAlert(uid, alert) async {
    await _users.doc(uid).update({'alert': alert});
  }

  Future<void> updateUserCache(
      String uid, String pincode, Map<String, dynamic> dateToDetail) async {
    var dataRetrieved = await _users.doc(uid).get();
    var cache = dataRetrieved['cache'];
    cache[pincode] = dateToDetail;
    await _users.doc(uid).update({'cache': cache});
  }

  Future<void> updateLookup(uid, pincode, dateDoseCount) async {
    var dataRetrieved = await _users.doc(uid).get();
    var lookup = dataRetrieved['lookup'];
    lookup[pincode] = dateDoseCount;
    await _users.doc(uid).update({'lookup': lookup});
  }
}
