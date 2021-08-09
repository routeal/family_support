import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
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

  static List<Widget> _pageList = [
    TimelinePage(),
    EventPage(),
    ShiftPage(),
    ChatPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.read<AppState>();

    //print('index=' + _selectedIndex.toString());

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
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
    //      });
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
