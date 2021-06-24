import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final bool hasIndicator;
  Loading([this.hasIndicator = true]);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: hasIndicator ? Center(child: CircularProgressIndicator()) : null,
    );
  }
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
