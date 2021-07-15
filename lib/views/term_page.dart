import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermPage extends StatefulWidget {
  @override
  _TermPageState createState() => _TermPageState();
}

class _TermPageState extends State<TermPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool _isLoading = false;
  String _title = '';

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            Expanded(
              child: _buildWebView(),
            ),
          ],
        ));
  }

  Widget _buildWebView() {
    return WebView(
      initialUrl: 'https://www.caremanagement.jp/inquiries/terms',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: _controller.complete,
      onPageStarted: (String url) {
        setState(() {
          _isLoading = true;
        });
      },
      onPageFinished: (String url) async {
        setState(() {
          _isLoading = false;
        });
        final controller = await _controller.future;
        final title = await controller.getTitle();
        setState(() {
          if (title != null) {
            _title = title;
          }
        });
      },
    );
  }
}
