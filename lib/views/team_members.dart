import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/views/user_page.dart';

class TeamMembers extends StatefulWidget {
  @override
  State<TeamMembers> createState() => _TeamMembers();
}

class _TeamMembers extends State<TeamMembers> {
  @override
  void initState() {
    super.initState();
  }

  Widget get caregivers {
    AppState appState = context.read<AppState>();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CategoryHeader(
              icon: Icons.people_outline_outlined, title: 'Caregivers'),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: appState.caregivers.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListUserItem(user: appState.caregivers[index]),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(
              title: 'Add caregiver',
              onTap: () {
                final teamId = appState.currentTeam!.id!;
                final role = UserRole.caregiver.toString();
                final data = teamId + ':' + role;
                shareQrCode(data: data);
              }),
        ]);
  }

  Widget get recipients {
    AppState appState = context.read<AppState>();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CategoryHeader(
              icon: Icons.people_outline_outlined, title: 'Recipients'),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: appState.recipients.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListUserItem(user: appState.recipients[index]),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(
              title: 'Add recipient',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddUserPage(
                      title: 'New Recipient', role: UserRole.recipient),
                ));
              }),
        ]);
  }

  Widget get practitioners {
    AppState appState = context.read<AppState>();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CategoryHeader(
              icon: Icons.people_outline_outlined, title: 'Practitioners'),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: appState.practitioners.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListUserItem(user: appState.practitioners[index]),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(
              title: 'Add practitioner',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddUserPage(
                      title: 'New Practitioner', role: UserRole.practitioner),
                ));
              }),
        ]);
  }

  Widget get careManagers {
    AppState appState = context.read<AppState>();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CategoryHeader(
              icon: Icons.people_outline_outlined, title: 'Care Managers'),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: appState.caremanagers.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListUserItem(user: appState.caremanagers[index]),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(
              title: 'Add care manager',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddUserPage(
                      title: 'New Care Manager', role: UserRole.caremanager),
                ));
              }),
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

  @override
  Widget build(BuildContext context) {
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
                        children: <Widget>[
                          caregivers,
                          recipients,
                          careManagers,
                          practitioners,
                        ],
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
  final AppUser user;
  const ListUserItem({Key? key, required this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: user.avatar,
        title: Text(user.displayName!),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UpdateUserPage(user: user)));
        });
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
