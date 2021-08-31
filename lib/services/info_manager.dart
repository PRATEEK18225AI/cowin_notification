import 'package:cowin_vaccine_slot_notification/authenticate/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cowin_vaccine_slot_notification/services/user_details.dart';
import 'package:provider/provider.dart';

TextStyle headingStyle() => TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );

class UpdateDetails extends StatefulWidget {
  final updateDrawer;
  const UpdateDetails({Key? key, this.updateDrawer}) : super(key: key);

  @override
  _UpdateDetailsState createState() => _UpdateDetailsState();
}

class _UpdateDetailsState extends State<UpdateDetails> {
  TextEditingController _name = TextEditingController();
  TextEditingController _age = TextEditingController();
  TextEditingController _pin = TextEditingController();
  String _gender = '';
  String uid = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      uid = context.read<Authenticate>().getUid();
    });
    context.read<UserDetails>().getUserDataFromUid(uid).then((value) {
      setState(() {
        _age.text = value['age'];
        _pin.text = value['pincode'];
        _gender = value['gender'];
        _name.text = value['name'];
      });
    });
    Future.delayed(Duration(seconds: 3, milliseconds: 50), () {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Update Details",
            style: headingStyle(),
          ),
        ),
        body: (loading == true)
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _name,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Name",
                          labelStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                          hintText: "Enter your name",
                          hintStyle: TextStyle(
                              color: Colors.green[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _age,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Age",
                          labelStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                          hintText: "Enter your age",
                          hintStyle: TextStyle(
                              color: Colors.green[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                                labelText: 'Gender',
                                labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                                errorStyle: TextStyle(
                                    color: Colors.redAccent, fontSize: 16.0),
                                hintText: 'Select your gender',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                            isEmpty: _gender == '',
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _gender,
                                isDense: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _gender = newValue!;
                                    state.didChange(newValue);
                                  });
                                },
                                items: <String>[
                                  '',
                                  'Male',
                                  'Female'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _pin,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Pincode",
                          labelStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                          hintText: "Enter your pincode",
                          hintStyle: TextStyle(
                              color: Colors.green[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: (3 / 5) * width,
                      height: (1 / 18) * height,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10)),
                      child: MaterialButton(
                        onPressed: () async {
                          Map<String, dynamic> data = {
                            'name': _name.text,
                            'age': _age.text,
                            'gender': _gender,
                            'pincode': _pin.text,
                          };
                          await context
                              .read<UserDetails>()
                              .updateUserDetails(uid, data);

                          var newData = await context
                              .read<UserDetails>()
                              .getUserDataFromUid(uid);

                          widget.updateDrawer(newData);
                          Navigator.of(context).pop();
                        },
                        child: Text('Submit',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ));
  }
}

class UpdatePreferences extends StatefulWidget {
  final updateDrawer;
  const UpdatePreferences({Key? key, this.updateDrawer}) : super(key: key);

  @override
  _UpdatePreferencesState createState() => _UpdatePreferencesState();
}

class _UpdatePreferencesState extends State<UpdatePreferences> {
  List<TextEditingController> _preferences = [];
  String uid = '';
  bool loading = true;
  var pincodes = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      uid = context.read<Authenticate>().getUid();
      for (int i = 0; i < 5; i++) {
        _preferences.add(TextEditingController());
      }
    });
    context.read<UserDetails>().getUserDataFromUid(uid).then((value) {
      setState(() {
        this.pincodes = value['preferences'];
        int i = 0;
        for (var pincode in pincodes) {
          this._preferences[i].text = pincode.toString();
          i++;
        }
      });
    });

    Future.delayed(Duration(seconds: 2, milliseconds: 200), () {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pincode Preferences",
          style: headingStyle(),
        ),
      ),
      body: (loading == true)
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                  children: <Widget>[
                        for (int index = 0; index < 5; index++)
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: TextFormField(
                                  controller: this._preferences[index],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Pincode ${index + 1}",
                                    labelStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                    hintText: "Enter your Pincode  $index",
                                    hintStyle: TextStyle(
                                        color: Colors.green[500],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          )
                      ] +
                      [
                        Container(
                          width: (3 / 5) * width,
                          height: (1 / 18) * height,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          child: MaterialButton(
                            onPressed: () async {
                              Map<String, dynamic> data = {
                                'preferences': _preferences
                                    .map((value) => value.text.toString())
                                    .toList()
                              };
                              await context
                                  .read<UserDetails>()
                                  .updateUserDetails(uid, data);
                              var newData = await context
                                  .read<UserDetails>()
                                  .getUserDataFromUid(uid);

                              widget.updateDrawer(newData);
                              Navigator.of(context).pop();
                            },
                            child: Text('Submit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                        )
                      ])),
    );
  }
}

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  TextStyle aboutHeader() => TextStyle(
      color: Colors.green[600],
      fontWeight: FontWeight.w600,
      fontSize: 24,
      decoration: TextDecoration.underline);
  TextStyle aboutDesc() => TextStyle(
        color: Colors.grey[450],
        fontWeight: FontWeight.w600,
        fontSize: 19,
      );
  TextStyle aboutName() => TextStyle(
        color: Colors.blue[600],
        fontWeight: FontWeight.bold,
        fontSize: 22,
      );
  TextStyle aboutContrib() => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
      );
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "About",
            style: headingStyle(),
          ),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
          width: width,
          height: height,
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project Description', style: aboutHeader()),
              SizedBox(height: 5),
              Text(
                  'This Project has been done as a part of 6th semester internship under guidance of "Dr. Garima Chhikara" maam. The Purpose of the given application is to provide its users the details about availability of Covid-19 vaccine in their region. ',
                  style: aboutDesc()),
              SizedBox(height: 20),
              Text('Developers', style: aboutHeader()),
              SizedBox(height: 15),
              Text('1. Prateek kumar (2K18/CO/255)', style: aboutName()),
              SizedBox(height: 5),
              Text(
                  'Contribution:User Interface Design, User Authentication, FireStore Database management, Cowin API request handling, Vaccine Notifications handling, ML model Training and Deployment on Azure Web Services',
                  style: aboutContrib()),
              SizedBox(height: 10),
              Text('1. Rahul kumar (2K18/CO/272)', style: aboutName()),
              SizedBox(height: 5),
              Text(
                  'Contribution: Data Collection and Preprocessing, App Permissons Management',
                  style: aboutContrib()),
            ],
          ),
        ));
  }
}
