import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/src/provider.dart';
import 'package:routemaster/routemaster.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/views/auth_page.dart';
import 'package:wecare/views/customers_page.dart';
import 'package:wecare/views/home_page.dart';
import 'package:wecare/views/term_page.dart';
import 'package:wecare/views/user_props_page.dart';
import 'package:wecare/widgets/loading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    '/term': (_) => MaterialPage<void>(
      child: TermPage(),
    ),
  });
}

class Launcher extends StatelessWidget {

  // load appuser from the local disk, if not found,
  // then check the server
  Future<AppUser?> loadUser(BuildContext context) async {
    FirebaseService firebase = context.read<FirebaseService>();
    if (firebase.auth.currentUser == null) {
      // delete the previous user if any
      AppUser.save(null);
      return null;
    } else {
      AppUser? user = await AppUser.load();
      if (user == null) {
        user = await firebase.getUser();
        if (user != null) {
          await AppUser.save(user);
        }
      }
      return user;
    }
  }

  @override
  Widget build(BuildContext context) {
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

          FirebaseService firebase = context.watch<FirebaseService>();

          if (firebase.auth.currentUser == null) {
            print('FutureBuilder: login route');
            appState.route = RoutemasterDelegate(routesBuilder: (context) {
              return _signOutRouteMap;
            });
          } else {
            print('FutureBuilder: app route');
            appState.route = RoutemasterDelegate(routesBuilder: (context) {
              return _signInRouteMap();
            });
          }

          return MaterialApp.router(
            title: 'CarePlanner',
            theme: ThemeData(
              primaryColor: Colors.teal[200],
            ),
            routeInformationParser: RoutemasterParser(),
            routerDelegate: appState.route!,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en', ''),
              const Locale('ja', ''),
            ],
          );
        });
  }
}
