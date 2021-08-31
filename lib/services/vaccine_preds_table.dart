import 'package:cowin_vaccine_slot_notification/services/cowin_vaccine.dart';
import 'package:flutter/material.dart';

class Analyzestats extends StatefulWidget {
  final allPincode;
  final dates;
  final predictions;
  const Analyzestats({Key? key, this.predictions, this.allPincode, this.dates})
      : super(key: key);

  @override
  _AnalyzestatsState createState() => _AnalyzestatsState();
}

class _AnalyzestatsState extends State<Analyzestats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Predictions'),
      ),
      body: Container(
          child: Column(
        children: [
          Expanded(
              flex: 1,
              child: Center(
                child: Text('Total Expected Units',
                    style: TextStyle(
                      color: Colors.pink[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    )),
              )),
          Expanded(
              flex: 6,
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 3,
                    ),
                    //borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                      children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration:
                                    BoxDecoration(color: Colors.indigo[600]),
                                child: Row(children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 2)),
                                      child: Center(
                                        child: Text('Pincode',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 2)),
                                      child: Center(
                                        child: Text('${widget.dates[0]}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 14)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 2)),
                                      child: Center(
                                        child: Text('${widget.dates[1]}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 14)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 2)),
                                      child: Center(
                                        child: Text('${widget.dates[2]}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 14)),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                            )
                          ] +
                          widget.allPincode
                              .map<Expanded>((pin) => Expanded(
                                    flex: 1,
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
                                              child: Text('$pin',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.black,
                                                      fontSize: 16)),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 2)),
                                            child: Center(
                                              child: Text(
                                                  '${widget.predictions[pin][widget.dates[0]]}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.black,
                                                      fontSize: 17)),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 2)),
                                            child: Center(
                                              child: Text(
                                                  '${widget.predictions[pin][widget.dates[1]]}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.black,
                                                      fontSize: 17)),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 2)),
                                            child: Center(
                                              child: Text(
                                                  '${widget.predictions[pin][widget.dates[2]]}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.black,
                                                      fontSize: 17)),
                                            ),
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
