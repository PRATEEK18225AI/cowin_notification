import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowin_vaccine_slot_notification/services/user_details.dart';
import 'package:cowin_vaccine_slot_notification/utilities/object_converter.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

Future<Address?> determinePincode() async {
  // Test if location services are enabled.
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  Position position = await Geolocator.getCurrentPosition();
  print('${position.latitude}, ${position.longitude}');
  try {
    GeoCode geoCode = GeoCode();

    Address? address = await geoCode.reverseGeocoding(
        latitude: position.latitude, longitude: position.longitude);

    if (address.countryName != 'India') {
      print(address.countryName);
      throw Exception('Country not India !!');
    }
    return address;
  } catch (e) {
    print(e.toString());
    return Future.error('${e.toString()}');
  }
}

Future<String> getLatestPincode() async {
  try {
    var address = await determinePincode();
    String pincode = '';
    if (address != null) {
      pincode = address.postal!;
    }
    return pincode;
  } catch (e) {
    print(e.toString());
  }
  return '';
}

Future<List<String>> getAllPincodes(String uid) async {
  // FireStore data load
  UserDetails user = UserDetails();
  var userData = await user.getUserDataFromUid(uid);
  String pincode = userData['pincode'].toString();
  // String postal = await getLatestPincode();

  // if (postal != '' && postal != pincode) {
  //   await user.updateUserDetails(uid, {'pincode': postal});
  //   pincode = postal;
  // }
  List<String> postals = [];
  // user has enabled background services
  if (pincode != '') {
    // current pincode
    postals.add(pincode);
  } else {
    return Future.error('Pincode Not Set');
  }
  var allPincodes = ObjectToContainer.toList(userData['preferences']);

  for (var pin in allPincodes) {
    // rest of pincodes
    if (pin != '') {
      postals.add(pin);
    }
  }
  return postals;
}
