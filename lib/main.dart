import 'package:cowin_vaccine_slot_notification/authenticate/auth_service.dart';
import 'package:cowin_vaccine_slot_notification/services/background_task.dart';
import 'package:cowin_vaccine_slot_notification/services/location_manager.dart';
import 'package:cowin_vaccine_slot_notification/services/user_details.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cowin_vaccine_slot_notification/wrapper.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  // handling background tasks
  Workmanager().executeTask((task, data) async {
    await Firebase.initializeApp();

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

    var userData =
        await user.getUserDataFromUid(uid); // FireStore all latest data from DB

    // User logged in and background task begins
    print('Background execution in progress, uid:$uid, task: $task');

    var allPincodes = await getAllPincodes(uid);

    if (task == 'sendVaccineNotif') {
      await Future.delayed(Duration(seconds: 10));
    }

    // Different type of Background task
    switch (task) {

      /// Vaccine Details Update in DB
      case 'updateVaccineInfo':
        // Different type of Background task
        await updateUserDBCache(uid, allPincodes);
        await Future.delayed(Duration(seconds: 8));
        await updateDBLookup(uid, allPincodes);
        break;

      /// Notification Sender
      case 'sendVaccineNotif':
        if (userData['alert'] == 'false') {
          print('Alerts are turned off');
          return Future.value(true);
        }
        await sendBackgroundNotif(allPincodes, userData);
        break;
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode:
        false, // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
  Workmanager().registerPeriodicTask('1', 'updateVaccineInfo',
      frequency: Duration(minutes: 15));

  Workmanager().registerPeriodicTask(
    '2',
    'sendVaccineNotif',
    frequency: Duration(minutes: 15, seconds: 20),
    initialDelay: Duration(minutes: 2, seconds: 30),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Authenticate>(
            create: (context) => Authenticate(FirebaseAuth.instance)),
        Provider<UserDetails>(create: (context) => UserDetails()),
        StreamProvider(
            create: (context) => context.read<Authenticate>().authStateChanges,
            initialData: null),
        StreamProvider(
          create: (context) => context.read<UserDetails>().studentCollection,
          initialData: null,
        )
      ],
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
