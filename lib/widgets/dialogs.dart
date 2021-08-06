import 'package:flutter/material.dart';

Future<void> showMessageDialog({
  required BuildContext context,
  String? title,
  required String message,
  String? ok,
  bool? dismissible,
  Color? color,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: dismissible ?? true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: ((title != null)
            ? Text(title,
                style: TextStyle(color: color ?? Theme.of(context).buttonColor))
            : null),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                message,
                style: TextStyle(color: color ?? Theme.of(context).buttonColor),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: ((ok != null) ? Text(ok) : Text('OK')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> loadingDialog(BuildContext context) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      });
}

void showSnackBar(
    {required BuildContext context,
    required String message,
    IconData icon = Icons.error_outline_outlined,
    int seconds = 3}) {
  final snackBar = SnackBar(
    content: Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        // add your preferred text content here
        Expanded(
          child: Text(message),
        ),
      ],
    ),
    // the duration of your snack-bar
    duration: Duration(seconds: seconds),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
