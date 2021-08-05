import 'package:routemaster/routemaster.dart';
import 'package:wecare/models/team.dart';
import 'package:wecare/models/user.dart';

class AppState {
  AppUser? currentUser;
  Team? currentTeam;
  List<AppUser> caregivers = [];
  List<AppUser> recipients = [];
  List<AppUser> caremanagers = [];
  List<AppUser> practitioners = [];
  RoutemasterDelegate? route;
}
