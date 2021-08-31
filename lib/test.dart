import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowin_vaccine_slot_notification/authenticate/auth_service.dart';
import 'package:cowin_vaccine_slot_notification/services/background_task.dart';
import 'package:cowin_vaccine_slot_notification/services/location_manager.dart';
import 'package:cowin_vaccine_slot_notification/services/user_details.dart';
import 'package:cowin_vaccine_slot_notification/utilities/date_time_operations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geocode/geocode.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cowin_vaccine_slot_notification/wrapper.dart';
import 'package:workmanager/workmanager.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () async {
                // Auth
                Authenticate auth = Authenticate(FirebaseAuth.instance);
                UserDetails user = UserDetails();
                String uid = '';
                try {
                  uid = auth.getUid();
                } catch (e) {
                  print(e.toString());
                  return Future.error(e.toString());
                }

                var userData = await user.getUserDataFromUid(
                    uid); // FireStore all latest data from DB

                // User logged in and background task begins
                print(
                    'Background execution in progress, uid:$uid, task: Notification');

                var allPincodes = await getAllPincodes(
                    uid); // current pincode + preferences // current pincode + preferences

                if (userData['alert'] == 'false') {
                  print('Alerts are turned off');
                  return Future.value(true);
                }
                await sendBackgroundNotif(allPincodes, userData);
              },
              child: Text('Notification')),
          TextButton(
              onPressed: () async {
                Authenticate auth = Authenticate(FirebaseAuth.instance);
                String uid = '';
                try {
                  uid = auth.getUid();
                } catch (e) {
                  print(e.toString());
                  return Future.error(e.toString());
                }

                // User logged in and background task begins
                print(
                    'Background execution in progress, uid:$uid, task: update');

                // current pincode + preferences
                var allPincodes = await getAllPincodes(uid);

                // Different type of Background task
                await updateUserDBCache(uid, allPincodes);
                await Future.delayed(Duration(seconds: 8));
                await updateDBLookup(uid, allPincodes);
              },
              child: Text('Update Db')),
          TextButton(
              onPressed: () async {
                Authenticate auth = Authenticate(FirebaseAuth.instance);

                String? uid = auth.getUid();
                var postals = await getAllPincodes(uid);
                print(postals.toString());
              },
              child: Text('All Pincode')),
          TextButton(
              onPressed: () async {
                DateTime today = DateTime.now();
                var date = DateString.dateToString(today);
                print(date);
                print(DateString.dateChangeFormat(date));
                print(DateString.sortDateList([
                  DateString.dateToString(today.add(Duration(days: 2))),
                  date,
                  DateString.dateToString(today.add(Duration(days: -2)))
                ]));
              },
              child: Text('Date Format')),
          TextButton(
              onPressed: () async {
                Authenticate auth = Authenticate(FirebaseAuth.instance);
                await auth.signOut();
              },
              child: Text('Sign out'))
        ],
      ),
    );
  }
}
