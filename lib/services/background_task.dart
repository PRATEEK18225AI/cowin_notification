// update vaccine iinfo in database
import 'package:cowin_vaccine_slot_notification/services/cowin_vaccine.dart';
import 'package:cowin_vaccine_slot_notification/services/user_details.dart';
import 'package:cowin_vaccine_slot_notification/utilities/date_time_operations.dart';
import 'package:cowin_vaccine_slot_notification/utilities/object_converter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> updateUserDBCache(String uid, List<String> allPincodes) async {
  if (allPincodes.length <= 0) {
    return Future.error('Nothing to Update');
  }

  DateTime today = DateTime.now(); //current date
  List<String> dateList = [];

  for (int day = 0; day < 3; day++) {
    var date = DateString.dateToString(today.add(Duration(days: day)));
    dateList.add(date);
  }

  Map<String, dynamic> dateToDetail = {}; // Pincode:Date
  for (var pin in allPincodes) {
    for (var date in dateList) {
      try {
        var data =
            await CowinUrlToJson(pincode: pin, date: date).getDataFromUrl();
        dateToDetail[date] = (data['sessions'].length > 0)
            ? VaccinePincode.fromSession(data['sessions']).toJson()
            : null;
        UserDetails().updateUserCache(uid, pin, dateToDetail);
      } catch (e) {
        print('$pin $date Error: ${e.toString()}');
      }
    }
  }
}

Future<void> updateDBLookup(String uid, List<String> allPincodes) async {
  if (allPincodes.length <= 0) {
    return Future.error('Nothing to Update');
  }

  // to update db if necessary
  UserDetails user = UserDetails();

  var userData = await UserDetails().getUserDataFromUid(uid);

  var lookup = ObjectToContainer.toJson(userData['lookup']);
  var userCache = ObjectToContainer.toJson(userData['cache']);

  DateTime today = DateTime.now(); //current date

  // 5 days => 2 prev + 3 curr, predict: 6,7,8
  List<String> currRange = [];
  for (int day = -2; day <= 2; day++) {
    var date = DateString.dateToString(today.add(Duration(days: day)));
    currRange.add(date);
  }
  // sorting according to date
  currRange.sort((a, b) => compareDate(a, b));
  print('curr range: ${currRange.toString()}');

  // updating pincode of today, tommor and after
  for (var pin in allPincodes) {
    Map<String, int> pinCache = {};

    if (!userCache.containsKey(pin)) {
      // pincode is not present in DB
      Map<String, dynamic> dateToDetail = {};
      for (int idx = 2; idx < 5; idx++) {
        var date = currRange[idx];
        try {
          var data =
              await CowinUrlToJson(pincode: pin, date: date).getDataFromUrl();
          dateToDetail[date] = (data['sessions'].length > 0)
              ? VaccinePincode.fromSession(data['sessions']).toJson()
              : null;
        } catch (e) {
          print('$pin $date Error: ${e.toString()}');
        }
      }
      // it will update cache
      await user.updateUserCache(uid, pin, dateToDetail);
      dateToDetail.forEach((d, val) {
        if (val != null) {
          pinCache[d] = (int.parse(val["total_dose_1"].toString()) +
              int.parse(val["total_dose_2"].toString()));
        } else {
          pinCache[d] = 0;
        }
      });
    } else {
      // pincode is present
      for (int idx = 2; idx < 5; idx++) {
        // iterating over dates
        var date = currRange[idx];
        var datecache = ObjectToContainer.toJson(userCache[pin]);
        if (datecache.containsKey(date) && datecache[date] != null) {
          pinCache[date] =
              (int.parse(datecache[date]["total_dose_1"].toString()) +
                  int.parse(datecache[date]["total_dose_2"].toString()));
        } else {
          pinCache[date] = 0;
        }
      }
    }
    print('$pin , ${pinCache.toString()}');
    // old lookup data from db
    var preData =
        lookup.containsKey(pin) ? ObjectToContainer.toJson(lookup[pin]) : {};

    // based on cache and direct response from cowin
    Map<String, int> newData = {};

    // feeling with latest data
    for (var date in currRange) {
      newData[date] = 0;
      if (preData.containsKey(date)) {
        int preval = int.parse(preData[date].toString());
        newData[date] = (preval > newData[date]!) ? preval : newData[date]!;
      }
      if (pinCache.containsKey(date)) {
        newData[date] = (pinCache[date]! > newData[date]!)
            ? pinCache[date]!
            : newData[date]!;
      }
    }
    // converting to string
    Map<String, dynamic> newStringData = {};
    newData.forEach((key, value) {
      newStringData[key] = value.toString();
    });
    await user.updateLookup(uid, pin, newStringData);
  }
}

String? createVaccineNotif(pin, data) {
  String message = '''''';
  bool isMessage = false;
  var dates = [];
  data.forEach((date, _) {
    dates.add(date.toString());
  });
  dates.sort((a, b) => compareDate(a, b));
  for (var date in dates) {
    var value = data[date];
    if (value != null) {
      message += '''Date: $date (''';
      isMessage = true;
      value['vaccine_type_count'].forEach((vac, _) {
        message += ''' $vac,''';
      });
      message +=
          ''')\nTotal: Dose 1(${value["total_dose_1"]}) Dose 2(${value["total_dose_2"]})\n----------------------------\n''';
    }
  }
  return isMessage ? message : null;
}

Future<void> displayNotification(FlutterLocalNotificationsPlugin notifPlugin,
    int id, String? title, String? body,
    {String? payload}) async {
  NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
        'main_channel', 'Main Channel', 'Main Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation('$body')),
  );
  print('Sending Notification with id:$id, title:$title, payload:$payload');
  await notifPlugin.show(id, title, body, notificationDetails,
      payload: payload);
}

Future<void> sendBackgroundNotif(allPincodes, userData) async {
  FlutterLocalNotificationsPlugin notifPlugin =
      FlutterLocalNotificationsPlugin();

  await notifPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  print('Notification Plugin Succesfully Initialized');

  if (userData['cache'] != null) {
    allPincodes.asMap().forEach((idx, pin) async {
      if (pin != null && userData['cache'].containsKey(pin)) {
        print(pin);
        String? notif = createVaccineNotif(pin, userData['cache'][pin]);
        if (notif != null) {
          print(notif);
          await displayNotification(
              notifPlugin, idx, "Cowin Slot Alert: $pin", notif,
              payload: 'Vaccine $pin');
        } else {
          print('Every date has null value for pin $pin');
        }
      } else {
        print('pincoe $pin is absent in cache');
      }
    });
  } else {
    print('NuLL cache');
  }
}
