import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final bool hasIndicator;
  LoadingWidget([this.hasIndicator = true]);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: hasIndicator ? Center(child: CircularProgressIndicator()) : null,
    );
  }
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeCare',
      theme: ThemeData(
        primaryColor: Colors.teal[200],
      ),
      home: LoadingWidget(),
    );
  }
}
