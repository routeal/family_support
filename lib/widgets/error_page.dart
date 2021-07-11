import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lottie/lottie.dart';

class ErrorPage extends StatelessWidget {
  String? error;

  ErrorPage({this.error}) {
    error ??= 'Oops, something went wrong.';
  }

  void tryLater() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      // TODO: don't know how to build for both platforms
      //exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: FIXME: need to be fixed!!!
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                child: Lottie.asset('assets/images/9195-error.json'),
              ),
            ),
            Expanded(
              child: Text(error!,
                  style: Theme.of(context).primaryTextTheme.headline5),
            ),
            Flexible(
              child: ElevatedButton(
                onPressed: tryLater,
                child: const Text('TRY LATER'),
              ),
            )
          ],
        ));
  }
}
