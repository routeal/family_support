import 'package:flutter/material.dart';
import 'package:wecare/globals.dart' as globals;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      theme: ThemeData(
        primaryColor: globals.defaultThemeColor,
      ),
      home: LoadingWidget(),
    );
  }
}
