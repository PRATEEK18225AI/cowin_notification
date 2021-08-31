import 'package:cowin_vaccine_slot_notification/authenticate/auth_service.dart';
import 'package:cowin_vaccine_slot_notification/authenticate/social_auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:cowin_vaccine_slot_notification/services/user_details.dart';
import 'package:cowin_vaccine_slot_notification/authenticate/auth_register_page.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var width;
  var height;
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Cowin Slot",
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Notification",
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                            flex: 12, child: Image.asset('images/cowin.png')),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(children: [
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
                        child: Container(
                          width: (3 / 5) * MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          child: MaterialButton(
                            onPressed: () async {
                              String uid = await context
                                  .read<Authenticate>()
                                  .signInWithEmail(_email.text, _password.text);
                              if (uid == 'NULL' || uid == 'ERROR') {
                                print(uid);
                              } else {
                                print("User $uid logged in!!");
                              }
                            },
                            child: Center(
                              child: Text('Login',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('or',
                                style: TextStyle(color: Colors.grey[600])),
                            SignInButton(
                              Buttons.Google,
                              text: 'Sign in with Google',
                              onPressed: () async {
                                try {
                                  await context
                                      .read<Authenticate>()
                                      .signWithGoogle();
                                } catch (e) {
                                  if (e.toString() == 'User Not Registered') {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) => WillPopScope(
                                            child: errMessage(context, 'login'),
                                            onWillPop: () =>
                                                Future.value(false)));
                                  }
                                }
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PersonalInfo()));
                              },
                              child: Text(
                                "Create New Account",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
