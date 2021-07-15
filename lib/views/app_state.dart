import 'package:routemaster/routemaster.dart';
import 'package:wecare/models/user.dart';

class AppState {
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  set currentUser(AppUser? user) => _currentUser = user;

  RoutemasterDelegate? _route;
  RoutemasterDelegate? get route => _route;
  set route(RoutemasterDelegate? r) => _route = r;
}
