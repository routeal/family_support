import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wecare/models/team.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/views/chat_page.dart';
import 'package:wecare/views/timeline_page.dart';
import 'package:wecare/views/user_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Stream<void> watchTeam(String teamId) {
    FirebaseService firebase = context.read<FirebaseService>();
    return firebase.teamsRef.doc(teamId).snapshots().asyncMap((doc) async {
      final data = doc.data();
      if (data == null) {
        return;
      }
      try {
        data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
      } catch (e) {}

      AppState appState = context.read<AppState>();
      appState.currentTeam = Team.fromJson(data);

      await Members.loadUsers(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.read<AppState>();

    final appBar = AppBar(
      title: Text(AppLocalizations.of(context)!.appName),
      actions: [
        IconButton(
          icon: appState.currentUser!.avatar,
          onPressed: () => userDialog(context),
        ),
      ],
    );

    return Scaffold(
        appBar: appBar,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline_outlined),
              label: 'Timeline',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              label: 'Event',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes_outlined),
              label: 'Shift',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              label: 'Chat',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        body: StreamBuilder<void>(
          stream: watchTeam(appState.currentUser!.teamId!),
          builder: (context, snapshot) {
            List<Widget> _pageList = [
              TimelinePage(),
              EventPage(),
              ShiftPage(),
              ChatPage(),
            ];
            return _pageList[_selectedIndex];
          },
        ));
  }
}

class EventPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Event page')));
  }
}

class ShiftPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Shift page')));
  }
}
