import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/utils/colors.dart';
import 'package:wecare/globals.dart' as globals;
import 'package:wecare/views/app_state.dart';
import 'package:wecare/widgets/loading.dart';
import 'package:wecare/widgets/timeline_widget.dart';

class TimelinePage extends StatefulWidget {
  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadMembers(BuildContext context) async {
    AppState appState = context.read<AppState>();
    assert(appState.currentUser != null);
    assert(appState.currentTeam != null);

    if (appState.caregivers.isNotEmpty) return;

    FirebaseService firebase = context.read<FirebaseService>();

    appState.caregivers.clear();
    for (String id in appState.currentTeam!.caregivers) {
      if (id == appState.currentUser!.id) {
        if (appState.caregivers.where((u) => id == u.id).isEmpty) {
          appState.caregivers.add(appState.currentUser!);
        }
      } else {
        AppUser? user = await firebase.getUser(id);
        if (user != null) {
          if (appState.caregivers.where((u) => user.id == u.id).isEmpty) {
            appState.caregivers.add(user);
          }
        }
      }
    }

    int idx = appState.caregivers
        .indexWhere((element) => element.id == appState.currentUser!.id);
    if (idx >= 0) {
      appState.caregivers.insert(0, appState.caregivers.removeAt(idx));
    }

    appState.recipients.clear();
    for (String id in appState.currentTeam!.recipients) {
      if (id == appState.currentUser!.id) {
        if (appState.recipients.where((u) => id == u.id).isEmpty) {
          appState.recipients.add(appState.currentUser!);
        }
      } else {
        AppUser? user = await firebase.getUser(id);
        if (user != null) {
          if (appState.recipients.where((u) => user.id == u.id).isEmpty) {
            appState.recipients.add(user);
          }
        }
      }
    }

    idx = appState.recipients
        .indexWhere((element) => element.id == appState.currentUser!.id);
    if (idx >= 0) {
      appState.recipients.insert(0, appState.recipients.removeAt(idx));
    }

    appState.caremanagers.clear();
    for (String id in appState.currentTeam!.caremanagers) {
      if (id == appState.currentUser!.id) {
        if (appState.caremanagers.where((u) => id == u.id).isEmpty) {
          appState.caremanagers.add(appState.currentUser!);
        }
      } else {
        AppUser? user = await firebase.getUser(id);
        if (user != null) {
          if (appState.caremanagers.where((u) => user.id == u.id).isEmpty) {
            appState.caremanagers.add(user);
          }
        }
      }
    }

    idx = appState.caremanagers
        .indexWhere((element) => element.id == appState.currentUser!.id);
    if (idx >= 0) {
      appState.caremanagers.insert(0, appState.caremanagers.removeAt(idx));
    }

    appState.practitioners.clear();
    for (String id in appState.currentTeam!.practitioners) {
      if (id == appState.currentUser!.id) {
        if (appState.practitioners.where((u) => id == u.id).isEmpty) {
          appState.practitioners.add(appState.currentUser!);
        }
      } else {
        AppUser? user = await firebase.getUser(id);
        if (user != null) {
          if (appState.practitioners.where((u) => user.id == u.id).isEmpty) {
            appState.practitioners.add(user);
          }
        }
      }
    }

    idx = appState.practitioners
        .indexWhere((element) => element.id == appState.currentUser!.id);
    if (idx >= 0) {
      appState.practitioners.insert(0, appState.practitioners.removeAt(idx));
    }
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.read<AppState>();
    return FutureBuilder(
        future: loadMembers(context),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return LoadingPage();
          }

          return DefaultTabController(
              length: appState.recipients.length,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.fromLTRB(24, 6, 24, 0),
                      child: TabBar(
                    indicator: BoxDecoration(
                      border: Border.all(color: Colors.black38, width: 2),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(50),
                      color: globals.defaultThemeColor,
                    ),
                        indicatorColor: Colors.transparent,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black45,
                        isScrollable: false,
                        tabs: appState.recipients.map<Widget>((item) {
                          return Container(
                            padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                            //width: 100,
                            //height: 40,
                            child: Center(
                              child: Text(
                                item.displayName!,
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .fontSize),
                              ),
                            ),
                          );
                          /*
                      return Tab(
                        text: item.displayName,
                      );
*/
                        }).toList(),
                      )),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 0, right: 0),
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        //controller: _tabController,
                        children: appState.recipients.map<Widget>((item) {
                          return CareTimelineMatrix(
                            topBarBackgroundColor: Colors.pink[50],
                            sideBarBackgroundColor: Colors.pink[50],
                            chooserFontSize: 12,
                            topBarFontSize: 12,
                            sideBarFontSize: 12,
                            startTime: 8,
                            workHours: 12,
                            recipient: item,
                          );
                          //return Container(
                          //  color: HexColor(item.color!),
                          //);
                        }).toList(),
                      ),
                    ),
                  )
                ],
              ));
        });
  }
}
