import 'package:flutter/material.dart';

AlertDialog errMessage(BuildContext context, errCode) {
  int n = (errCode == 'register') ? 3 : 1;
  int c = 0;
  return AlertDialog(
    actions: [
      TextButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) {
              if (c == n) {
                return true;
              } else {
                c += 1;
                return false;
              }
            });
          },
          child: Text("ok")),
    ],
    title: Text(errCode == 'register'
        ? 'Given Account is already registered with the application. Please try to login with your credentials or sign up with a new account.'
        : 'Given Account is not registered with the application. Please try to sign up.'),
  );
}
