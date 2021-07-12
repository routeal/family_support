import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';

void userDialog(BuildContext context) {
  AppState appState = context.read<AppState>();

  Dialog fancyDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(0.0),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            //width: 300.0,
            //height: 400.0,
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 48.0,
                        child: Center(
                          child: Text(
                            'CarePlanner',
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
                  title: Text(appState.currentUser!.display_name!),
                  subtitle: Text(appState.currentUser!.email!),
                ),
                Divider(
                    color: Colors.black87,
                    height: 10.0,
                    indent: 2.0, // Starting Space
                    endIndent: 2.0 // Ending Space
                    ),
                ListTile(
                    leading: Icon(Icons.person_outline_rounded),
                    title: Text('Your profile'),
                    onTap: () {
                      Navigator.of(context).pop();
                      appState.route!.push('/user');
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
                      onPressed: null,
                    ),
                    Text(
                      '•',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    TextButton(
                      child: Text('Privacy Policy'),
                      onPressed: null,
                    )
                  ],
                )
              ],
            )
/*
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 800,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Dialog Title!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Okay let's go!",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
          Align(
            // These values are based on trial & error method
            alignment: Alignment(1.05, -1.05),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
*/
            ),
      ));

  showDialog(context: context, builder: (BuildContext context) => fancyDialog);
}
