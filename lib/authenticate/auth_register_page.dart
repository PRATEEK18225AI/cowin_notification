import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowin_vaccine_slot_notification/authenticate/auth_service.dart';
import 'package:cowin_vaccine_slot_notification/authenticate/social_auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:cowin_vaccine_slot_notification/services/user_details.dart';

class PersonalInfo extends StatefulWidget {
  final uid;
  const PersonalInfo({Key? key, this.uid}) : super(key: key);

  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  TextEditingController _name = TextEditingController();
  TextEditingController _age = TextEditingController();
  TextEditingController _pin = TextEditingController();
  String _gender = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(2, 5, 2, 10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                      child: Center(
                          child: Text('Enter Your Details',
                              style: TextStyle(
                                  fontSize: 33,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo[500]))),
                    )),
                Expanded(
                  flex: 12,
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
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
                              isEmpty: _gender == '',
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _gender,
                                  isDense: true,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _gender = newValue;
                                        state.didChange(newValue);
                                      });
                                    }
                                  },
                                  items: <String>['', 'Male', 'Female']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
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
                            hintText: "Enter your Pincode",
                            hintStyle: TextStyle(
                                color: Colors.green[500],
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 1, child: Container()),
                Expanded(
                  flex: 2,
                  child: MaterialButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterAccount(
                                      name: _name.text,
                                      age: _age.text,
                                      gender: _gender,
                                      pincode: _pin.text,
                                    )));
                      },
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.indigo[500],
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      )),
                ),
                Expanded(flex: 2, child: Container()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterAccount extends StatefulWidget {
  final name;
  final age;
  final gender;
  final pincode;
  const RegisterAccount(
      {Key? key, this.name, this.age, this.gender, this.pincode})
      : super(key: key);

  @override
  _RegisterAccountState createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  Map<String, dynamic> data = {};
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      data = {
        'name': widget.name,
        'age': widget.age,
        'gender': widget.gender,
        'alert': 'true',
        'cache': {},
        'lookup': {},
        'pincode': widget.pincode,
        'preferences': []
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightBlue[50],
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(2, 5, 2, 10),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Expanded(
                      flex: 5,
                      child: Container(
                        child: Center(
                            child: Text('Choose Account',
                                style: TextStyle(
                                    fontSize: 30, color: Colors.indigo[500]))),
                      )),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _email,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Email",
                          labelStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                          hintText: "Enter a valid Email",
                          hintStyle: TextStyle(
                              color: Colors.green[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        obscureText: true,
                        controller: _password,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Password",
                          labelStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                          hintText:
                              "Enter password of length between 8 to 14 characters",
                          hintStyle: TextStyle(
                              color: Colors.green[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: (4 / 7) * MediaQuery.of(context).size.width,
                      height: (1 / 18) * MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10)),
                      child: MaterialButton(
                        onPressed: () async {
                          try {
                            var uid = await context
                                .read<Authenticate>()
                                .regWithEmail(_email.text, _password.text);

                            UserDetails user = UserDetails();
                            await user.addUserDetails(uid, data);
                            print("User $uid data: ${data.toString()}");
                            int c = 0;
                            Navigator.of(context).popUntil((route) {
                              if (c == 2) {
                                return true;
                              } else {
                                c += 1;
                                return false;
                              }
                            });
                          } catch (e) {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => WillPopScope(
                                    child: errMessage(context, 'register'),
                                    onWillPop: () => Future.value(false)));
                          }
                        },
                        child: Text('Register',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            'or',
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SignInButton(
                            Buttons.Google,
                            text: 'Sign Up with Google',
                            onPressed: () async {
                              // pop 2 routes
                              try {
                                String uid = await context
                                    .read<Authenticate>()
                                    .regWithGoogle();
                                UserDetails user = UserDetails();
                                await user.addUserDetails(uid, data);
                                print("User $uid data: ${data.toString()}");
                                int c = 0;
                                Navigator.of(context).popUntil((route) {
                                  if (c == 2) {
                                    return true;
                                  } else {
                                    c += 1;
                                    return false;
                                  }
                                });
                              } catch (e) {
                                if (e.toString() == 'User Already Exist') {
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) => WillPopScope(
                                          child:
                                              errMessage(context, 'register'),
                                          onWillPop: () =>
                                              Future.value(false)));
                                }
                              }

                              //success do nothing
                              // fail
                            },
                          )
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
