import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class Caregiver {
  String displayName;
  Caregiver({required this.displayName});
}

class Recipient {
  String displayName;
  Recipient({required this.displayName});
}

class Doctor {
  String displayName;
  Doctor({required this.displayName});
}

class CareManager {
  String displayName;
  CareManager({required this.displayName});
}

class TeamMembers extends StatefulWidget {
  List<Caregiver> caregivers = [];
  List<Recipient> recipents = [];
  List<Doctor> doctors = [];
  List<CareManager> careManagers = [];
  TeamMembers() {
    caregivers.add(Caregiver(displayName: 'Hiroshi'));
    caregivers.add(Caregiver(displayName: 'Keiko'));
    recipents.add(Recipient(displayName: 'Takahashi'));
    doctors.add(Doctor(displayName: 'Black Jack'));
    careManagers.add(CareManager(displayName: 'Fukuchan'));
  }
  @override
  State<TeamMembers> createState() => _TeamMembers();
}

class _TeamMembers extends State<TeamMembers> {
  Widget get caregivers {
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
              itemCount: widget.caregivers.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text(widget.caregivers[index].displayName),
                    ),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(
              title: 'Add caregiver', onTap: () => _shareQrCode(data: 'tako')),
        ]);
  }

  Widget get recipients {
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
              itemCount: widget.recipents.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text(widget.recipents[index].displayName),
                    ),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(title: 'Add recipient', onTap: () => {}),
        ]);
  }

  Widget get doctors {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CategoryHeader(
              icon: Icons.people_outline_outlined, title: 'Doctors'),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: widget.recipents.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text(widget.doctors[index].displayName),
                    ),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(title: 'Add doctor', onTap: () => {}),
        ]);
  }

  Widget get careManagers {
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
              itemCount: widget.recipents.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text(widget.careManagers[index].displayName),
                    ),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(title: 'Add care manager', onTap: () => {}),
        ]);
  }

  Future<void> _shareQrCode({required String data, double? size}) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Team Members')),
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            caregivers,
            recipients,
            careManagers,
            doctors,
          ],
        )));
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
