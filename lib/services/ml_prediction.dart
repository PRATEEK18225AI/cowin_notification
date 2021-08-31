import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cowin_vaccine_slot_notification/services/cowin_vaccine.dart';

class RandomForestRegressor {
  var lookup;
  var allPincodes;
  RandomForestRegressor({required this.lookup, required this.allPincodes});

  Future<List> getPredictions() async {
    DateTime today = DateTime.now();
    var url =
        'http://0e174408-7729-48da-bded-42d78768b672.southeastasia.azurecontainer.io/score';

    var lookupArr = [];
    var postals = [];
    for (var pin in allPincodes) {
      var v = lookup[pin];
      postals.add(pin);
      var pinArr = [];
      if (v != null) {
        for (int day = -2; day <= 2; day++) {
          var date = dateToString(
              today.add(Duration(days: day)).toString().split(" ")[0]);
          pinArr.add(v.containsKey(date) ? int.parse(v[date].toString()) : 0);
        }
      } else {
        for (int i = 0; i < 5; i++) {
          pinArr.add(0);
        }
      }
      lookupArr.add(pinArr);
    }
    var payload = json.encode({'data': lookupArr});
    var r = await http.post(Uri.parse(url), body: payload);
    if (r.statusCode == 200) {
      // If the server did return a 200 OK response,then parse the JSON.
      var jsonResponse = json.decode(json.decode(r.body));
      var preds = jsonResponse['rfr'];
      print(preds.toString());
      var pinDatePreds = {};
      var n = postals.length;
      var dates = [];
      for (int day = 3; day < 6; day++) {
        var date = dateToString(
            today.add(Duration(days: day)).toString().split(" ")[0]);
        dates.add(date);
      }
      for (int i = 0; i < n; i++) {
        var pin = postals[i];
        pinDatePreds[pin] = {};
        for (int day = 0; day < 3; day++) {
          var date = dates[day];
          pinDatePreds[pin][date] = preds[i][day].toString();
        }
      }
      return [pinDatePreds, dates];
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return Future.error('Model Error');
    }
  }

  factory RandomForestRegressor.fromLookup(lookup, allPincodes) {
    return RandomForestRegressor(lookup: lookup, allPincodes: allPincodes);
  }
}
