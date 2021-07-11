import 'package:flutter/material.dart';

Future<void> showMyDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('AlertDialog Title'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
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
