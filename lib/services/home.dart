import 'dart:async';
import 'package:cowin_vaccine_slot_notification/services/background_task.dart';
import 'package:cowin_vaccine_slot_notification/services/cowin_vaccine.dart';
import 'package:cowin_vaccine_slot_notification/services/ml_prediction.dart';
import 'package:cowin_vaccine_slot_notification/services/info_manager.dart';
import 'package:cowin_vaccine_slot_notification/services/vaccine_preds_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cowin_vaccine_slot_notification/services/location_manager.dart';
import 'package:cowin_vaccine_slot_notification/authenticate/auth_service.dart';
import 'package:cowin_vaccine_slot_notification/services/user_details.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _pincode = TextEditingController();

  bool loading = true;
  var userData;
  bool alert = true;
  String uid = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      uid = context.read<Authenticate>().getUid();
    });
    print('Home uid:$uid');
    UserDetails user = UserDetails();
    user.getUserDataFromUid(uid).then((value) {
      setState(() {
        userData = value;
        alert = userData['alert'] == 'true';
      });
    });
    Future.delayed(Duration(seconds: 4, milliseconds: 400), () {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: (userData != null)
          ? Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                            radius: 40,
                            child: ClipRRect(
                              child: Image.asset(userData['gender'] == 'Male'
                                  ? 'images/boy.png'
                                  : 'images/girl.png'),
                              borderRadius: BorderRadius.circular(50.0),
                            )),
                        SizedBox(height: 10),
                        Text("${userData['name']}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Update Details'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UpdateDetails(updateDrawer: (newData) {
                                    setState(() {
                                      userData = newData;
                                    });
                                  })));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Preferences'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UpdatePreferences(updateDrawer: (newData) {
                                    setState(() {
                                      userData = newData;
                                    });
                                  })));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('About'),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AboutPage()));
                    },
                  ),
                ],
              ),
            )
          : SizedBox(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  setState(() {
                                    alert = !alert;
                                  });
                                  await UserDetails()
                                      .updateAlert(uid, alert.toString());
                                  Navigator.of(context).pop();
                                },
                                child: Text("Yes")),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("No")),
                          ],
                          title: Text(alert
                              ? 'Do you want to turn off the notifications?'
                              : 'Do you want to turn on the notifications?'),
                        ));
              },
              icon: (alert)
                  ? Icon(Icons.notifications_on)
                  : Icon(Icons.notifications_off),
              color: Colors.black),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        actions: [
                          TextButton(
                              onPressed: () async {
                                await context.read<Authenticate>().signOut();
                                Navigator.of(context).pop();
                              },
                              child: Text("Yes")),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("No")),
                        ],
                        title: Text('Are you sure you want to logout?'),
                      ));
            },
            icon: Icon(Icons.person, color: Colors.black),
          )
        ],
        title: Text(
          "Cowin Slot Notification",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: (loading == true || userData == null)
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : Container(
              padding: EdgeInsets.fromLTRB(2, 5, 2, 10),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/wallpaper.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: (37 / 180) * MediaQuery.of(context).size.height,
                      ),
                      Container(
                        width: (3 / 5) * MediaQuery.of(context).size.width,
                        height: (1 / 12) * MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: MaterialButton(
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            try {
                              var postals = await getAllPincodes(uid);
                              print(postals);
                              if (postals.length > 0) {
                                await weekScheduleGenerator(context, postals,
                                    i: 0);
                              }
                            } catch (e) {
                              print(e.toString());
                              if (e.toString() == 'Pincode Not Set') {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("ok")),
                                          ],
                                          title: Text(
                                              'Please set your pincode to use this feature'),
                                        ));
                              }
                            }
                            setState(() {
                              loading = false;
                            });
                          },
                          child: Text('See Schedule',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18)),
                        ),
                      ),
                      SizedBox(
                        height: (1 / 20) * MediaQuery.of(context).size.height,
                      ),
                      Container(
                        width: (3 / 5) * MediaQuery.of(context).size.width,
                        height: (1 / 12) * MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: MaterialButton(
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            try {
                              // pincode: lacal var in function
                              // postal: property of address class and member of given class
                              var postals = await getAllPincodes(uid);
                              if (postals.length > 0) {
                                await updateDBLookup(uid, postals);
                                var newUser =
                                    await UserDetails().getUserDataFromUid(uid);
                                setState(() {
                                  userData = newUser;
                                });
                                var classifier =
                                    RandomForestRegressor.fromLookup(
                                        userData['lookup'], postals);
                                var predDate =
                                    await classifier.getPredictions();
                                var predictions = predDate[0];
                                var dates = predDate[1];
                                setState(() {
                                  loading = false;
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Analyzestats(
                                        predictions: predictions,
                                        allPincode: postals,
                                        dates: dates,
                                      ),
                                    ));
                              }
                            } catch (e) {
                              print(e.toString());
                              if (e.toString() == 'Pincode Not Set') {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("ok")),
                                          ],
                                          title: Text(
                                              'Please set your pincode to use this feature'),
                                        ));
                              }
                            }
                            setState(() {
                              loading = false;
                            });
                          },
                          child: Text('Predictions',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18)),
                        ),
                      ),
                      SizedBox(
                        height: (1 / 20) * MediaQuery.of(context).size.height,
                      ),
                    ],
                  ))),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.search,
          color: Colors.black,
          size: 18,
        ),
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Center(child: Text('Search via Pincode')),
              actions: [
                TextButton(
                  onPressed: () async {
                    await weekScheduleGenerator(context, [_pincode.text],
                        i: -1);
                  },
                  child: Text("search"),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("cancel")),
              ],
              content: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _pincode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Pincode",
                    labelStyle: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                    hintText: "110070",
                    hintStyle: TextStyle(
                        color: Colors.green[300],
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
