import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';
import 'package:wecare/globals.dart' as globals;
import 'package:wecare/models/team.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/views/auth_page.dart';
import 'package:wecare/views/customers_page.dart';
import 'package:wecare/views/home_page.dart';
import 'package:wecare/views/new_team.dart';
import 'package:wecare/views/team_members.dart';
import 'package:wecare/views/term_page.dart';
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
              appState.currentUser!.role == null) {
            print("no currentuser or role");
            return false;
          }
          print("can navigate");
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
              appState.currentUser!.role == null) {
            print('user redirect');
            //return Redirect('/user?title=\'Your Profile\'?logout=\'Logout\'');
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
          child: CustomersPage(),
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
          await AppUser.save(user);
        }
      }
      return user;
    }
  }

  Future<Team?> loadTeam(BuildContext context, AppUser? user) async {
    if (user == null || user.teamId == null) {
      await Team.save(null);
      return null;
    }
    Team? team = await Team.load();
    if (team == null) {
      FirebaseService firebase = context.read<FirebaseService>();
      team = await firebase.getTeam(user.teamId!);
      if (team != null) {
        await Team.save(team);
      }
    }
    return team;
  }

  Future<void> loadAppState(BuildContext context) async {
    AppState appState = context.read<AppState>();
    appState.currentUser = await loadUser(context);
    if (appState.currentUser != null) {
      print("init user loaded: " + appState.currentUser!.toJson().toString());
    } else {
      print("init user loaded: none");
    }
    appState.currentTeam = await loadTeam(context, appState.currentUser);
    if (appState.currentTeam != null) {
      FirebaseService firebase = context.read<FirebaseService>();
      for (String id in appState.currentTeam!.caregivers) {
        final contain = appState.caregivers.where((v) => v.id == id);
        if (contain.isNotEmpty) continue;
        if (id == appState.currentUser!.id) {
          appState.caregivers.add(appState.currentUser!);
        } else {
          AppUser? user = await firebase.getUser(id);
          if (user != null) {
            appState.caregivers.add(user);
          }
        }
      }
      for (String id in appState.currentTeam!.recipients) {
        final contain = appState.recipients.where((v) => v.id == id);
        if (contain.isNotEmpty) continue;
        if (id == appState.currentUser!.id) {
          appState.recipients.add(appState.currentUser!);
        } else {
          AppUser? user = await firebase.getUser(id);
          if (user != null) {
            appState.recipients.add(user);
          }
        }
      }
      for (String id in appState.currentTeam!.caremanagers) {
        final contain = appState.caremanagers.where((v) => v.id == id);
        if (contain.isNotEmpty) continue;
        if (id == appState.currentUser!.id) {
          appState.caremanagers.add(appState.currentUser!);
        } else {
          AppUser? user = await firebase.getUser(id);
          if (user != null) {
            appState.caremanagers.add(user);
          }
        }
      }
      for (String id in appState.currentTeam!.practitioners) {
        final contain = appState.practitioners.where((v) => v.id == id);
        if (contain.isNotEmpty) continue;
        if (id == appState.currentUser!.id) {
          appState.practitioners.add(appState.currentUser!);
        } else {
          AppUser? user = await firebase.getUser(id);
          if (user != null) {
            appState.practitioners.add(user);
          }
        }
      }
    }
    return;
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
              scaffoldBackgroundColor: globals.defaultScaffoldColor,
              appBarTheme: AppBarTheme(
                color: globals.defaultThemeColor,
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
