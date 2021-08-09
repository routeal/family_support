import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wecare/models/team.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/views/user_page.dart';

typedef UserCallback = void Function(User user);

class TeamMembers extends StatefulWidget {
  @override
  State<TeamMembers> createState() => _TeamMembers();
}

class _TeamMembers extends State<TeamMembers> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> removeUser(User user) async {
    AppState appState = context.read<AppState>();
    Team team = appState.currentTeam!;
    bool updated = await team.removeUser(context, user);
    if (updated) {
      await Team.save(team);
    }
  }

  Widget groupMembers(
      {required int role,
      required List<User> users,
      required String header,
      required String button,
      required VoidCallback add,
      required UserCallback remove,
      required UserCallback tap}) {
    AppState appState = context.read<AppState>();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CategoryHeader(icon: Icons.people_outline_outlined, title: header),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListUserItem(
                      user: users[index],
                      me: users[index].id == appState.currentUser!.id,
                      tap: tap,
                      remove: remove,
                    ),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(
            title: button,
            onTap: add,
          ),
        ]);
  }

  Future<void> shareQrCode({required String data, double? size}) async {
    Widget widget = Center(
      child: Container(
        color: Colors.white,
        child: QrImage(
          data: data,
          version: QrVersions.auto,
          size: size ?? 300,
        ),
      ),
    );

    final Uint8List? imgBytes = await createImageDataFromWidget(widget: widget);

    if (imgBytes == null) {
      print('error');
    } else {
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/qrimage.png').create();
      await file.writeAsBytes(imgBytes);

      final box = context.findRenderObject() as RenderBox?;

      await Share.shareFiles([file.path],
          text: 'Care Team QR Code',
          subject: 'Care Team QR Code',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);

      file.deleteSync();
    }
  }

  Future _refresh() async {
    await Future.delayed(Duration(seconds: 1));
  }

  final List<Map<String, String>> labels = [
    {},
    {
      "header": "Caregivers",
      "button": "Add caregiver",
      "title": "New Caregiver"
    },
    {
      "header": "Recipients",
      "button": "Add recipient",
      "title": "New Recipient"
    },
    {
      "header": "Care managers",
      "button": "Add care manager",
      "title": "New Care Manager"
    },
    {
      "header": "Practitioner",
      "button": "Add practitioner",
      "title": "New Practitioner"
    },
  ];

  @override
  Widget build(BuildContext context) {
    AppState appState = context.read<AppState>();
    final groups = appState.currentTeam!.groups;
    return Scaffold(
        appBar: AppBar(title: Text('Your Care Team')),
        body: LayoutBuilder(builder: (context, constraints) {
          return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: groups.map<Widget>((g) {
                          final label = labels[g.role!];
                          return groupMembers(
                              role: g.role!,
                              users: g.users,
                              header: label['header']!,
                              button: label['button']!,
                              add: () {
                                if (g.role! == UserRole.caregiver) {
                                  final teamId = appState.currentTeam!.id!;
                                  final role = UserRole.caregiver.toString();
                                  final data = teamId + ':' + role;
                                  shareQrCode(data: data);
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AddUserPage(
                                        title: label['title'], role: g.role!),
                                  ));
                                }
                              },
                              remove: (User user) async {
                                await removeUser(user);
                                setState(() {});
                              },
                              tap: (User user) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        UpdateUserPage(user: user)));
                              });
                        }).toList(),
                      ))));
        }));
  }
}

class CategoryHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  const CategoryHeader(
      {Key? key, required this.icon, required this.title, this.color})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4),
        color: color ?? Colors.pink[100]!,
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(icon),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ));
  }
}

class ListUserItem extends StatelessWidget {
  final User user;
  final bool me;
  final UserCallback tap;
  final UserCallback remove;
  const ListUserItem(
      {Key? key,
      required this.user,
      required this.me,
      required this.tap,
      required this.remove})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (me) {
      return ListTile(
        leading: user.avatar,
        title: Text(user.displayName!),
        onTap: () => tap(user),
      );
    } else {
      return Slidable(
          actionPane: SlidableScrollActionPane(),
          secondaryActions: [
            IconSlideAction(
              caption: 'Delete',
              color: Theme.of(context).colorScheme.error,
              icon: Icons.delete_forever_outlined,
              onTap: () => remove(user),
            ),
          ],
          child: ListTile(
              leading: user.avatar,
              title: Text(user.displayName!),
              onTap: () => tap(user)));
    }
  }
}

class AddCategoryItem extends StatelessWidget {
  final String title;
  final Color? color;
  final VoidCallback? onTap;
  const AddCategoryItem({Key? key, this.onTap, required this.title, this.color})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
            padding:
                const EdgeInsets.only(left: 8, top: 10, bottom: 10, right: 8),
            color: color,
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.add_outlined),
                const SizedBox(width: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            )));
  }
}

Future<Uint8List?> createImageDataFromWidget(
    {required Widget widget, double? size}) async {
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

  final RenderView renderView = RenderView(
    window: WidgetsBinding.instance!.window,
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      size: Size.square(size ?? 300),
      devicePixelRatio: 1.0,
    ),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

  //pipelineOwner.rootNode = renderView;
  renderView.attach(pipelineOwner);
  renderView.prepareInitialFrame();
  pipelineOwner.requestVisualUpdate();

  final RenderObjectToWidgetElement<RenderBox> rootElement =
      RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: widget,
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);
  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();
  renderView.compositeFrame();
  pipelineOwner.flushSemantics();
  buildOwner.finalizeTree();

  final ui.Image image = await repaintBoundary.toImage(pixelRatio: 3);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData?.buffer.asUint8List();
}
