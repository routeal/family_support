import 'package:routemaster/routemaster.dart';
import 'package:wecare/models/team.dart';
import 'package:wecare/models/user.dart';

class AppState {
  User? currentUser;
  Team? currentTeam;
  List<User> currentMembers = [];
  RoutemasterDelegate? route;
}
