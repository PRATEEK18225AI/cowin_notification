import 'dart:convert';
import 'package:cowin_vaccine_slot_notification/utilities/object_converter.dart';
import 'package:provider/provider.dart';
import 'package:cowin_vaccine_slot_notification/services/user_details.dart';
import 'package:cowin_vaccine_slot_notification/authenticate/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VaccinePincode {
  String totalDose1;
  String totalDose2;
  List locations;
  Map vaccineTypeCount;

  VaccinePincode(
      {required this.totalDose1,
      required this.totalDose2,
      required this.locations,
      required this.vaccineTypeCount});

  factory VaccinePincode.fromSession(sessions) {
    int d1 = 0;
    int d2 = 0;
    var tempCount = {};
    var typeCount = {};
    for (var location in sessions) {
      d1 += int.parse(location["available_capacity_dose1"].toString());
      d2 += int.parse(location["available_capacity_dose2"].toString());
      var vacName = (location["vaccine"] == "" || location["vaccine"] == null)
          ? ""
          : location["vaccine"].trim().toUpperCase();

      if (!tempCount.containsKey(vacName)) {
        tempCount[vacName] = {'dose1': 0, 'dose2': 0};
      }
      tempCount[vacName]['dose1'] +=
          int.parse(location["available_capacity_dose1"].toString());
      tempCount[vacName]['dose2'] +=
          int.parse(location["available_capacity_dose2"].toString());
    }
    for (var k in tempCount.keys) {
      typeCount[k] = {
        'dose1': tempCount[k]['dose1'].toString(),
        'dose2': tempCount[k]['dose2'].toString()
      };
    }
    print('${typeCount.toString()}');
    return VaccinePincode(
        totalDose1: d1.toString(),
        totalDose2: d2.toString(),
        locations: sessions,
        vaccineTypeCount: typeCount);
  }
  Map<String, dynamic> toJson() => {
        'total_dose_1': totalDose1,
        'total_dose_2': totalDose2,
        'sessions': locations,
        'vaccine_type_count': vaccineTypeCount
      };
}

// Given class stores pincode,url and date and fetch json response from the cowin server
class CowinUrlToJson {
  String pincode;
  String date;
  late String url;

  Future<Map<String, dynamic>> getDataFromUrl() async {
    var r = await http.get(Uri.parse(this.url));
    if (r.statusCode == 200) {
      // If the server did return a 200 OK response,then parse the JSON.
      return ObjectToContainer.toJson(json.decode(r.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return Future.error('Bad Response');
    }
  }

  CowinUrlToJson({required this.pincode, required this.date}) {
    url =
        'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?pincode=${pincode}&date=${date}';
  }
}

// Class for Vaccine Detail page, It return scaffold page
class SlotDetails extends StatefulWidget {
  final locations;
  final front;
  final back;
  final loc;
  final data;
  SlotDetails(
      {Key? key, this.locations, this.front, this.back, this.loc, this.data})
      : super(key: key);

  @override
  _SlotDetailsState createState() => _SlotDetailsState();
}

class _SlotDetailsState extends State<SlotDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              flex: 2,
              child: Center(
                  child: Text('Vaccine Details',
                      style: TextStyle(
                          color: Colors.white,
                          backgroundColor: Colors.green[600],
                          fontSize: 40)))),
          Expanded(
              flex: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 2,
                      child: widget.back
                          ? IconButton(
                              onPressed: () {
                                dayVaccineInfo(context, widget.locations,
                                    loc: (this.widget.loc - 1), replace: true);
                              },
                              icon: Icon(Icons.arrow_back_ios, size: 15))
                          : SizedBox()),
                  Expanded(
                    flex: 5,
                    child: Image.asset('images/syringe.png'),
                  ),
                  Expanded(
                      flex: 2,
                      child: widget.front
                          ? IconButton(
                              onPressed: () {
                                dayVaccineInfo(context, widget.locations,
                                    loc: (this.widget.loc + 1), replace: true);
                              },
                              icon: Icon(Icons.arrow_forward_ios, size: 15))
                          : SizedBox()),
                ],
              )),
          Expanded(
            flex: 12,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1),
                                color: Colors.red[400]),
                            child: Center(
                              child: Text("${widget.data['name']}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            ))),
                    Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text("Name",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16)),
                                  )),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text("${widget.data['vaccine']}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[500],
                                            fontSize: 17)),
                                  )),
                            ),
                          ],
                        )),
                    Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text("Doses",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16)),
                                  )),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                            "Dose 1: ${widget.data['available_capacity_dose1']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[500],
                                                fontSize: 17)),
                                        Text(
                                            "Dose 2: ${widget.data['available_capacity_dose2']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[500],
                                                fontSize: 17)),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        )),
                    Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text("Address",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16)),
                                  )),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text.rich(
                                        TextSpan(
                                            text: "${widget.data['address']}"),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[500],
                                            fontSize: 17)),
                                  )),
                            ),
                          ],
                        )),
                    Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text("State",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 15)),
                                  )),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text("${widget.data['state_name']}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[500],
                                            fontSize: 16)),
                                  )),
                            ),
                          ],
                        )),
                    Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text("Fee",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 15)),
                                  )),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text("${widget.data['fee']}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[500],
                                            fontSize: 16)),
                                  )),
                            ),
                          ],
                        )),
                    Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text("Minimum\n    Age",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16)),
                                  )),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text(
                                        "${widget.data['min_age_limit']}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[500],
                                            fontSize: 16)),
                                  )),
                            ),
                          ],
                        )),
                    Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Text("Timing",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 15)),
                                  )),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1)),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("From: ${widget.data['from']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[500],
                                                fontSize: 17)),
                                        Text("To: ${widget.data['to']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[500],
                                                fontSize: 17)),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

dayVaccineInfo(BuildContext context, List locations,
    {int loc: 0, replace: false}) {
  bool front = true;
  bool back = true;
  int l = locations.length;
  if (l == 1) {
    front = back = false;
  } else {
    if (loc == 0) {
      back = false;
    }
    if (loc == l - 1) {
      front = false;
    }
  }
  replace
      ? Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SlotDetails(
                locations: locations,
                front: front,
                back: back,
                loc: loc,
                data: locations[loc]),
          ),
        )
      : Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SlotDetails(
                locations: locations,
                front: front,
                back: back,
                loc: loc,
                data: locations[loc]),
          ),
        );
}

class VaccineSchedule extends StatefulWidget {
  final today;
  final pincode;
  final vaccineDetails;
  final header;
  final postals;
  final front;
  final back;
  final i;

  VaccineSchedule(
      {Key? key,
      this.today,
      this.pincode,
      this.vaccineDetails,
      this.header,
      this.i,
      this.postals,
      this.front,
      this.back})
      : super(key: key);

  @override
  _VaccineScheduleState createState() => _VaccineScheduleState();
}

class _VaccineScheduleState extends State<VaccineSchedule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        title: Text('Schedule'),
        centerTitle: true,
      ),
      body: Container(
          child: Column(
        children: [
          Expanded(
              flex: 1,
              child: Center(
                child: Text('${widget.header}',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    )),
              )),
          Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: widget.back
                          ? IconButton(
                              onPressed: () async {
                                await weekScheduleGenerator(
                                    context, widget.postals,
                                    i: (widget.i! - 1), replace: true);
                              },
                              icon: Icon(Icons.arrow_back_ios, size: 15))
                          : SizedBox()),
                  Expanded(
                      flex: 3,
                      child: Center(
                          child: Text('${widget.pincode}',
                              style: TextStyle(
                                color: Colors.cyan[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              )))),
                  Expanded(
                      flex: 2,
                      child: widget.front
                          ? IconButton(
                              onPressed: () async {
                                await weekScheduleGenerator(
                                    context, widget.postals,
                                    i: (widget.i! + 1), replace: true);
                              },
                              icon: Icon(Icons.arrow_forward_ios, size: 15))
                          : SizedBox()),
                ],
              )),
          Expanded(
              flex: 4,
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                      children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration:
                                    BoxDecoration(color: Colors.brown[500]),
                                child: Row(children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 2)),
                                      child: Center(
                                        child: Text('Date',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 15)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 2)),
                                      child: Center(
                                        child: Text('Details',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 15)),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                            )
                          ] +
                          widget.vaccineDetails
                              .map<Expanded>((vaccine) => Expanded(
                                    flex: 5,
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: Colors.white),
                                      child: Row(children: [
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 2)),
                                            child: Center(
                                              child: Text('${vaccine[0]}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.black,
                                                      fontSize: 15)),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 2)),
                                            child: Center(
                                                child: (vaccine[1] != null)
                                                    ? Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                dayVaccineInfo(
                                                                    context,
                                                                    vaccine[1]
                                                                        .locations,
                                                                    loc: 0);
                                                              },
                                                              child: Text(
                                                                  'Total: Dose 1(${vaccine[1].totalDose1}), Dose 2(${vaccine[1].totalDose2})',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15)),
                                                            ),
                                                            Text(
                                                              vaccine[1]
                                                                  .vaccineTypeCount
                                                                  .entries
                                                                  .map((item) =>
                                                                      '${item.key}')
                                                                  .toList()
                                                                  .join(','),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 14),
                                                            ),
                                                          ])
                                                    : Text('-',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15))),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ))
                              .toList()))),
          Expanded(flex: 1, child: SizedBox()),
        ],
      )),
    );
  }
}

String dateToString(String date) {
  var dateNew = date.split('-');
  return '${dateNew[2]}-${dateNew[1]}-${dateNew[0]}';
}

int compareDate(a, b) {
  return dateToString(a.toString()).compareTo(dateToString(b.toString()));
}

weekScheduleGenerator(BuildContext context, List<String> postals,
    {int i: 0, replace: false}) async {
  bool front = true;
  bool back = true;
  String header = '';

  var uid = context.read<Authenticate>().getUid();
  var userData = await UserDetails().getUserDataFromUid(uid);
  var cache = userData['cache'];

  if (postals.length == 1) {
    front = back = false;
  } else {
    if (i == 0) {
      back = false;
    }
    if (i == postals.length - 1) {
      front = false;
    }
  }

  if (i == -1) {
    header = 'Given Pincode';
  } else if (i == 0) {
    header = 'Current Location';
  } else {
    header = 'Pincode $i';
  }

  DateTime today = DateTime.now();
  String pincode = (i == -1) ? postals[0] : postals[i];

  List<List<dynamic>> vaccineDetails = [];
  Map dateToDetail = {};
  if (cache != null && cache.containsKey(pincode)) {
    dateToDetail = cache[pincode];
    dateToDetail.forEach((k, v) {
      vaccineDetails.add(
          [k, (v == null) ? null : VaccinePincode.fromSession(v['sessions'])]);
    });
  } else {
    for (int day = 0; day < 3; day++) {
      var date =
          dateToString(today.add(Duration(days: day)).toString().split(" ")[0]);
      try {
        var data =
            await CowinUrlToJson(pincode: pincode, date: date).getDataFromUrl();
        var info;
        var currJsonResponse;
        if (data['sessions'].length > 0) {
          info = VaccinePincode.fromSession(data['sessions']);
          currJsonResponse = info.toJson();
        }
        vaccineDetails.add([date, info]);
        dateToDetail[date] = currJsonResponse;
      } catch (e) {}
    }
    if (cache != null && i != -1) {
      cache[pincode] = dateToDetail;
      UserDetails().updateUserCache(
          uid, pincode, ObjectToContainer.toJson(dateToDetail));
    }
  }
  vaccineDetails.sort((a, b) => compareDate(a[0], b[0]));
  replace
      ? Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VaccineSchedule(
                today: today,
                pincode: i == -1 ? postals[0] : postals[i],
                vaccineDetails: vaccineDetails,
                postals: postals,
                front: front,
                header: header,
                back: back,
                i: i),
          ),
        )
      : Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VaccineSchedule(
                today: today,
                pincode: i == -1 ? postals[0] : postals[i],
                vaccineDetails: vaccineDetails,
                postals: postals,
                front: front,
                header: header,
                back: back,
                i: i),
          ),
        );
}
