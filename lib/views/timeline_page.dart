
import 'package:flutter/material.dart';
import 'package:wecare/utils/colors.dart';
import 'package:wecare/views/app_state.dart';
import 'package:provider/provider.dart';

class TimelinePage extends StatefulWidget {

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    AppState appState = context.read<AppState>();
    var length = appState.recipients.length;
    _tabController = new TabController(length: length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.read<AppState>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TabBar(
          controller: _tabController,
          indicatorColor: Colors.transparent,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.black54,
          isScrollable: false,
          tabs: appState.recipients.map<Widget>((item) {
            return Tab(text: item.displayName, );
          }).toList(),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 0, right: 0),
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: appState.recipients.map<Widget>((item) {
                return Container(
                  color: HexColor(item.color!),
                );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }
}
