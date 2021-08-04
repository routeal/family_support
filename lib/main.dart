import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wecare/globals.dart' as globals;
import 'package:wecare/launcher.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/utils/logger.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/widgets/fatal_error_widget.dart';
import 'package:wecare/widgets/loading.dart';

void main() async {
  initLogger(() async {
    // Status bar style on Android/iOS
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle());

    if (kIsWeb) {
      // Increase Skia cache size to support bigger images.
      const int megabyte = 1000000;
      SystemChannels.skia
          .invokeMethod('Skia.setResourceCacheMaxBytes', 512 * megabyte);
      // TODO: cant' await on invokeMethod due to https://github.com/flutter/flutter/issues/77018  so awaiting on Future.delayed instead.
      await Future<void>.delayed(Duration.zero);
    }

    runApp(MultiProvider(
      providers: [
        Provider(create: (_) => FirebaseService()),
        Provider(create: (_) => AppState()),
      ],
      child: InitFirebase(),
    ));
  });
}

// first of all, check firebase but necessary???
class InitFirebase extends StatefulWidget {
  @override
  _InitFirebaseState createState() => _InitFirebaseState();
}

class _InitFirebaseState extends State<InitFirebase>
    with WidgetsBindingObserver {
  bool _initialized = false;
  bool _error = false;
  String? _errorStr;

  void init() async {
    // For testing
    //AppUser.save(null);

    FirebaseService firebase = context.read<FirebaseService>();
    try {
      await firebase.init();
      setState(() {
        _initialized = true;
      });
    } catch (error) {
      setState(() {
        _error = true;
        _errorStr = error.toString();
      });
    }
  }

  @override
  void initState() {
    init();
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print('state = $state');
  }

  @override
  Widget build(BuildContext context) {
    Widget? widget;
    if (_error) {
      widget = FatalErrorWidget(error: _errorStr);
    } else if (!_initialized) {
      widget = LoadingWidget(true);
    }

    if (widget != null) {
      return MaterialApp(
        theme: ThemeData(primaryColor: globals.defaultScaffoldColor),
        home: widget,
      );
    }

    FirebaseService firebase = context.watch<FirebaseService>();
    return StreamBuilder<User?>(
        stream: firebase.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            print('StreamBuilder: ' + snapshot.data!.email!);
          }
          return Launcher();
        });
  }
}
