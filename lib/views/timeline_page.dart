import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecare/constants.dart' as Constants;
import 'package:wecare/models/team.dart';
import 'package:wecare/models/user.dart';
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

  @override
  Widget build(BuildContext context) {
    double fontSize = Theme.of(context).textTheme.subtitle1?.fontSize ?? 18;

    final users = Members.getUsers(context, UserRole.recipient);

    if (users.isEmpty) {
      return Container(
          child: Center(
              child: Text('Please add a recipient.',
                  style: Theme.of(context).textTheme.headline6)));
    }

    return DefaultTabController(
        length: users.length,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(fontSize, 6, fontSize, 0),
                child: TabBar(
                  indicator: BoxDecoration(
                    border: Border.all(color: Colors.black38, width: 2),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(50),
                    color: Constants.defaultPrimaryColor,
                  ),
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black45,
                  isScrollable: false,
                  tabs: users.map<Widget>((item) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: (fontSize * 1.5),
                              child: item.avatar,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                                flex: 2,
                                child: Text(
                                  item.displayName!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: fontSize),
                                )),
                          ]),
                    );
                  }).toList(),
                )),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 0, right: 0),
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  //controller: _tabController,
                  children: users.map<Widget>((item) {
                    return CareTimelineMatrix(
                      topBarBackgroundColor: Constants.defaultPrimaryColor,
                      sideBarBackgroundColor: Constants.defaultPrimaryColor,
                      chooserFontSize:
                          Theme.of(context).textTheme.button?.fontSize,
                      topBarFontSize:
                          Theme.of(context).textTheme.caption?.fontSize,
                      sideBarFontSize:
                          Theme.of(context).textTheme.caption?.fontSize,
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
  }
}
