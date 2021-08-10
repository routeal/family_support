
import 'package:flutter/material.dart';
import 'package:wecare/models/team.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/widgets/shift_widget.dart';
import 'package:wecare/constants.dart' as Constants;

class ShiftPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final users = Members.getUsers(context, UserRole.recipient);

    return Scaffold(body:
    Center(child:
    ResourceScheduler(
      pastMonths: 2,
      futureMonths: 3,
      users: users,
      datesBackgroundColor: Constants.defaultPrimaryColor,
      frameColor: Constants.defaultPrimaryColor,
    )));
  }
}
