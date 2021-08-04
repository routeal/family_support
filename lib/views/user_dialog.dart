import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void userDialog(BuildContext context) {
  AppState appState = context.read<AppState>();

  Dialog _dialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 48.0,
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.appName,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 48.0,
                      width: 48.0,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
              ListTile(
                leading: appState.currentUser!.avatar,
                title: Text(appState.currentUser!.displayName ?? ''),
                subtitle: Text(appState.currentUser!.email!),
                onTap: () {
                  Navigator.of(context).pop();
                  appState.route!.push('/user');
                },
              ),
              Divider(
                  color: Colors.black87,
                  height: 10.0,
                  indent: 2.0, // Starting Space
                  endIndent: 2.0 // Ending Space
                  ),
              ListTile(
                  leading: Icon(Icons.people_outlined),
                  title: Text('Your Care Team'),
                  onTap: () {
                    Navigator.of(context).pop();
                    appState.route!.push('/supporters');
                  }),
              Divider(
                  color: Colors.black87,
                  height: 10.0,
                  indent: 2.0, // Starting Space
                  endIndent: 2.0 // Ending Space
                  ),
              ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Settings'),
                onTap: () => {},
              ),
              Divider(
                  color: Colors.black87,
                  height: 10.0,
                  indent: 2.0, // Starting Space
                  endIndent: 2.0 // Ending Space
                  ),
              ListTile(
                leading: Icon(Icons.logout_outlined),
                title: Text('Sign Out'),
                onTap: () {
                  FirebaseService firebase = context.read<FirebaseService>();
                  firebase.signOut();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    child: Text('Privacy Policy'),
                    onPressed: () {
                      AppState appState = context.read<AppState>();
                      appState.route!.push('/term');
                    },
                  ),
                  Text(
                    '•',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  TextButton(
                    child: Text('Term of Service'),
                    onPressed: () {
                      AppState appState = context.read<AppState>();
                      appState.route!.push('/term');
                    },
                  )
                ],
              )
            ],
          ))));

  showDialog(context: context, builder: (BuildContext context) => _dialog);
}
