import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/views/customers_page.dart';
import 'package:wecare/views/user_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    print('_HomePageState');

    FirebaseService firebase = context.read<FirebaseService>();

    AppState appState = context.read<AppState>();
    assert(appState.currentUser != null);
    assert(appState.currentTeam != null);

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

  static List<Widget> _pageList = [
    CustomersPage(),
    EventPage(),
    ShiftPage(),
    ChatPage(),
    AlbumPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
      body: _pageList[_selectedIndex],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album_outlined),
            label: 'Album',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
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

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Chat page')));
  }
}

class AlbumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Album page')));
  }
}
