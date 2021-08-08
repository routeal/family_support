import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';
import 'package:wecare/constants.dart' as Constants;
import 'package:wecare/models/team.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/views/auth_page.dart';
import 'package:wecare/views/home_page.dart';
import 'package:wecare/views/new_team.dart';
import 'package:wecare/views/team_page.dart';
import 'package:wecare/views/term_page.dart';
import 'package:wecare/views/timeline_page.dart';
import 'package:wecare/views/user_page.dart';
import 'package:wecare/widgets/loading.dart';

RouteMap _signOutRouteMap() {
  return RouteMap(routes: {
    '/': (_) => MaterialPage<void>(
          child: AuthPage(),
        ),
  });
}

RouteMap _signInRouteMap() {
  return RouteMap(routes: {
    '/': (_) {
      return Guard(
        canNavigate: (routeInfo, context) {
          FirebaseService firebase = context.read<FirebaseService>();
          if (!firebase.auth.currentUser!.emailVerified) return false;
          AppState appState = context.read<AppState>();
          if (appState.currentUser == null && appState.currentTeam == null) {
            print("no currentuser no currentteam");
            return false;
          }
          if (appState.currentUser == null ||
              appState.currentUser!.displayName == null) {
            print("no currentuser or displayName");
            return false;
          }
          return true;
        },
        onNavigationFailed: (routeInfo, context) {
          FirebaseService firebase = context.read<FirebaseService>();
          if (!firebase.auth.currentUser!.emailVerified)
            return Redirect('/verify');
          AppState appState = context.read<AppState>();
          if (appState.currentUser == null && appState.currentTeam == null) {
            return Redirect('/team');
          }
          if (appState.currentUser == null ||
              appState.currentUser!.displayName == null) {
            print('user redirect');
            return Redirect('/user');
          }
          return Redirect('/');
        },
        builder: () => TabPage(
          child: HomePage(),
          paths: ['timeline', 'event', 'shift', 'chat', 'album'],
        ),
      );
    },
    '/timeline': (_) => MaterialPage<void>(
          child: TimelinePage(),
        ),
    '/event': (_) => MaterialPage<void>(
          child: EventPage(),
        ),
    '/shift': (_) => MaterialPage<void>(
          child: ShiftPage(),
        ),
    '/chat': (_) => MaterialPage<void>(
          child: ChatPage(),
        ),
    '/album': (_) => MaterialPage<void>(
          child: AlbumPage(),
        ),
    '/user': (route) => MaterialPage<void>(
          child: UserPropsPage(),
        ),
    '/verify': (_) => MaterialPage<void>(
          child: SendEmailVerificationPage(),
        ),
    '/term': (_) => MaterialPage<void>(
          child: TermPage(),
        ),
    '/supporters': (_) => MaterialPage<void>(
          child: TeamMembers(),
        ),
    '/team': (_) => MaterialPage<void>(
          child: JoinTeamPage(),
        ),
  });
}

class Launcher extends StatelessWidget {
  // load appuser from the local disk, if not found,
  // then check the server
  Future<AppUser?> loadUser(BuildContext context) async {
    try {
      FirebaseService firebase = context.read<FirebaseService>();
      if (firebase.auth.currentUser == null) {
        // delete the previous user if any
        await AppUser.save(null);
        return null;
      } else {
        AppUser? user = await AppUser.load();
        if (user == null) {
          user = await firebase.getUser(firebase.auth.currentUser!.uid);
          if (user != null) {
            print("init user from net: " + user.toJson().toString());
            await AppUser.save(user);
          }
        } else {
          print("init user from local: " + user.toJson().toString());
        }
        return user;
      }
    } catch (e) {
      print("Error loadUser:" + e.toString());
    }
    return null;
  }

  Future<Team?> loadTeam(BuildContext context, AppUser? user) async {
    try {
      if (user == null || user.teamId == null) {
        await Team.save(null);
        return null;
      }
      Team? team = await Team.load();
      if (team == null) {
        FirebaseService firebase = context.read<FirebaseService>();
        team = await firebase.getTeam(user.teamId!);
        if (team != null) {
          print("init team from net: " + team.toJson().toString());
          await Team.save(team);
        } else {
          print('unable to find ' + user.teamId!);
        }
      } else {
        print("init team from local: " + team.toJson().toString());
      }
      return team;
    } catch (e) {
      print("Error loadTeam:" + e.toString());
    }
    return null;
  }

  Future<void> loadAppState(BuildContext context) async {
    AppState appState = context.read<AppState>();
    appState.currentUser = await loadUser(context);
    appState.currentTeam = await loadTeam(context, appState.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadAppState(context),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return LoadingPage();
          }

          AppState appState = context.read<AppState>();

          FirebaseService firebase = context.read<FirebaseService>();

          if (firebase.auth.currentUser == null) {
            print('FutureBuilder: login route');
            appState.route = RoutemasterDelegate(routesBuilder: (context) {
              return _signOutRouteMap();
            });
          } else {
            print('FutureBuilder: app route');
            appState.route = RoutemasterDelegate(routesBuilder: (context) {
              return _signInRouteMap();
            });
          }

          return MaterialApp.router(
            theme: ThemeData(
              scaffoldBackgroundColor: Constants.defaultScaffoldColor,
              appBarTheme: AppBarTheme(
                color: Constants.defaultPrimaryColor,
                brightness: Brightness.light,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
                textTheme: Theme.of(context).textTheme,
              ),
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
