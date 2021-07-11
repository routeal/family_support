import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:routemaster/routemaster.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/ui/app_state.dart';
import 'package:wecare/ui/customers_page.dart';
import 'package:wecare/ui/home_page.dart';
import 'package:wecare/ui/user_props_page.dart';
import 'package:wecare/widgets/loading.dart';

import './ui/auth_page.dart';

final _signOutRouteMap = RouteMap(routes: {
  '/': (routeInfo) {
    return MaterialPage<void>(
      child: AuthPage(),
    );
  }
});

RouteMap _signInRouteMap() {
  return RouteMap(routes: {
    '/': (_) {
      return Guard(
        canNavigate: (routeInfo, context) {
          FirebaseService firebase = context.read<FirebaseService>();
          if (!firebase.auth.currentUser!.emailVerified) return false;
          AppState appState = context.read<AppState>();
          if (appState.currentUser == null) return false;
          return true;
        },
        onNavigationFailed: (routeInfo, context) {
          FirebaseService firebase = context.read<FirebaseService>();
          if (!firebase.auth.currentUser!.emailVerified)
            return Redirect('/verify');
          AppState appState = context.read<AppState>();
          if (appState.currentUser == null) {
            return Redirect('/user');
          }
          return Redirect('/');
        },
        builder: () => TabPage(
          child: HomePage(),
          paths: ['customers', 'settings', 'search'],
        ),
      );
    },
    '/customers': (_) => MaterialPage<void>(
          child: CustomersPage(),
        ),
    '/settings': (_) => MaterialPage<void>(
          child: SettingsPage(),
        ),
    '/search': (_) => MaterialPage<void>(
          child: ProfilePage(),
        ),
    '/user': (_) => MaterialPage<void>(
          child: UserPropsPage(),
        ),
    '/verify': (_) => MaterialPage<void>(
          child: SendEmailVerificationPage(),
        ),
  });
}

class Launcher extends StatelessWidget {
  // load appuser from the local disk, if not found,
  // then check the server
  Future<AppUser?> loadUser(BuildContext context) async {
    AppUser? user = await AppUser.load();
    if (user == null) {
      FirebaseService firebase = context.read<FirebaseService>();
      user = await firebase.getUser();
      if (user != null) {
        await AppUser.save(user);
      }
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    FirebaseService firebase = context.watch<FirebaseService>();
    firebase.userId = firebase.auth.currentUser?.uid;

    // SignIn Page
    if (firebase.userId == null) {
      // remove the appuser first
      return FutureBuilder(
          future: AppUser.save(null),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return LoadingPage();
            }
            return MaterialApp.router(
              title: 'CarePlanner',
              theme: ThemeData(
                primaryColor: Colors.teal[200],
              ),
              routeInformationParser: RoutemasterParser(),
              routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
                return _signOutRouteMap;
              }),
            );
          });
    }

    // Home Page
    return FutureBuilder(
        future: loadUser(context),
        builder: (BuildContext context, AsyncSnapshot<AppUser?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return LoadingPage();
          }

          if (snapshot.hasData) {
            print('FutureBuilder: ' + snapshot.data!.toJson().toString());
          } else {
            print('FutureBuilder: no data');
          }

          AppState appState = context.read<AppState>();
          appState.currentUser = snapshot.data;

          appState.route = RoutemasterDelegate(routesBuilder: (context) {
            return _signInRouteMap();
          });

          return MaterialApp.router(
            title: 'CarePlanner',
            theme: ThemeData(
              primaryColor: Colors.teal[200],
            ),
            routeInformationParser: RoutemasterParser(),
            routerDelegate: appState.route!,
          );
        });
  }
}
