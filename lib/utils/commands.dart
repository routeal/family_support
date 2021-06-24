import 'dart:io';

import 'package:flutter/services.dart';

Future<void> exitApp() async {
  if (Platform.isIOS) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      exit(0);
    });
  } else {
    Future.delayed(const Duration(milliseconds: 1000), () {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    });
  }
}