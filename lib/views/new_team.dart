import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:wecare/models/team.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/widgets/dialogs.dart';

class JoinTeamPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Care Team')),
        body: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Care team is a group of members who provide and receive care service.   The members typically include a family of caregivers and recipients, care managers, and medical practitioners.',
                  style: Theme.of(context).textTheme.headline5,
                ),
                /*
                Spacer(),
                Text(
                  'You need to create a new team or join a team to continue.',
                  style: Theme.of(context).textTheme.headline5,
                ),
                */
                Spacer(flex: 2),
                Align(
                  child: Wrap(
                      spacing: 24.0,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => NewTeamPage(),
                              ));
                            },
                            child: Text('Create a new team')),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ScanTeamQRPage(),
                            ));
                          },
                          child: Text(
                            'Scan QR code to join a team',
                          ),
                        ),
                      ]),
                ),
                Spacer(
                  flex: 5,
                ),
              ],
            )));
  }
}

class NewTeamPage extends StatelessWidget {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          final result = controller.text.isNotEmpty
              ? await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: AlertDialog(
                        content: Text("Your changes have not been saved"),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Discard"),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                          TextButton(
                            child: Text("Continue"),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                        ],
                      ),
                    );
                  })
              : true;
          return result;
        },
        child: Scaffold(
            appBar: AppBar(title: Text('New Care Team')),
            body: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'A name of care team can be anything.  Use your family name for now if you do not have any good idea.  You can change it later.',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Spacer(),
                    TextField(
                      controller: controller,
                      decoration: new InputDecoration(
                        icon: Icon(
                          Icons.group_outlined,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        labelText: 'Care Team Name',
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0),
                          borderSide: new BorderSide(),
                        ),
                      ),
                    ),
                    Spacer(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              submit(context);
                            },
                            child: Text(
                              'Submit',
                            ),
                          ),
                          Spacer(),
                        ]),
                    Spacer(
                      flex: 5,
                    ),
                  ],
                ))));
  }

  Future<void> submit(BuildContext context) async {
    if (controller.text.isEmpty) {
      return;
    }

    // display loading icon
    loadingDialog(context);

    AppState appState = context.read<AppState>();

    String? error;

    try {
      FirebaseService firebase = context.read<FirebaseService>();

      final team = Team(name: controller.text);

      await firebase.createTeam(team);

      appState.currentTeam = team;

      if (appState.currentUser == null) {
        appState.currentUser = AppUser(teamId: team.id,
            email: firebase.auth.currentUser?.email);
        await firebase.createUser(appState.currentUser!);
      } else {
        appState.currentUser!.teamId = team.id;
      }

      controller.clear();
    } catch (e) {
      error = e.toString();
    }

    // loading
    Navigator.of(context).pop();

    // current page
    Navigator.of(context).pop();

    if (error != null) {
      // context comes from scaffold
      showSnackBar(context: context, message: error);
    } else {
      appState.route!.push('/');
    }
  }
}

class ScanTeamQRPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanTeamQRPageState();
}

class _ScanTeamQRPageState extends State<ScanTeamQRPage> {
  //Barcode? result;
  QRViewController? controller;
  final picker = ImagePicker();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Care Team QR Code')),
        body: Stack(children: <Widget>[
          Column(children: <Widget>[
            Expanded(flex: 4, child: _buildQrView(context)),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('Scan a QR code to join a care team.'),
              ),
            )
          ]),
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Align(
              alignment: Alignment(0.8, 0.5),
              child: IconButton(
                iconSize: 48,
                icon: Icon(Icons.photo_album_outlined, color: Colors.white),
                onPressed: () => _getPhotoByGallery(),
              ),
            ),
          ),
        ]));
  }

  double get scanArea {
    var size = min(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    return (size * 3 / 5);
  }

  Widget _buildQrView(BuildContext context) {
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      _data = scanData.code;
      Future.delayed(const Duration(milliseconds: 1), _onQrCodeLoaded);
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No Permission for using a camera')),
      );
    }
  }

  String _data = '';

  void _getPhotoByGallery() async {
    picker.pickImage(source: ImageSource.gallery).then((XFile? value) {
      if (value == null) {
        throw ('Unknown error: try again');
      }
      return QrCodeToolsPlugin.decodeFrom(value.path);
    }).then((String value) {
      _data = value;
      Future.delayed(const Duration(milliseconds: 10), _onQrCodeLoaded);
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    });
  }

  void _onQrCodeLoaded() {
    print(_data);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
