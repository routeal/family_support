import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PropsImageItem extends FormField<String> {
  PropsImageItem({
    String? initialValue,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue ?? "",
            builder: (state) {
              return _PropsImageItemState(state);
            });
}

class _PropsImageItemState extends StatefulWidget {
  final FormFieldState<String> state;

  _PropsImageItemState(this.state);

  @override
  _PropsImageItemImageState createState() => _PropsImageItemImageState(state);
}

class _PropsImageItemImageState extends State<_PropsImageItemState> {
  FormFieldState<String> state;

  _PropsImageItemImageState(this.state);

  String? _url;
  File? _file;
  final picker = ImagePicker();

  Future _showDialog() async {
    var pane = (_file != null)
        ? [
            TextButton(
              child: Text("Remove photo"),
              onPressed: () => Navigator.pop(context, "remove"),
            ),
            TextButton(
              child: Text("Take photo"),
              onPressed: () => Navigator.pop(context, "camera"),
            ),
            TextButton(
              child: Text("Select new photo"),
              onPressed: () => Navigator.pop(context, "photo"),
            ),
          ]
        : [
            TextButton(
              child: Text("Take photo"),
              onPressed: () => Navigator.pop(context, "camera"),
            ),
            TextButton(
              child: Text("Choose photo"), // Select new photo
              onPressed: () => Navigator.pop(context, "photo"),
            ),
          ];

    final result = await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Change photo"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pane,
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context, "test"),
              ),
            ],
          );
        });

    switch (result) {
      case "camera":
        {
          getImage(ImageSource.camera);
          break;
        }
      case "photo":
        {
          getImage(ImageSource.gallery);
          break;
        }
      case "remove":
        {
          removePhoto();
          break;
        }
      default:
        break;
    }
  }

  @override
  void initState() {
    _url = state.value;
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    state.setValue(_file?.path ?? "");
  }

  Future removePhoto() async {
    if (_file != null && _file!.existsSync()) {
      await _file!.delete();
      _file = null;
      setState(() {});
    }
  }

  Future getImage(source) async {
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      if (file.existsSync()) {
        _cropImage(pickedFile.path);
      }
    }
  }

  Future _cropImage(filepath) async {
    File? croppedImage = await ImageCropper.cropImage(
      sourcePath: filepath,
      maxWidth: 120,
      maxHeight: 120,
      compressQuality: 70,
      cropStyle: CropStyle.circle,
    );

    if (croppedImage != null) {
      _file = croppedImage;
      setState(() {});
    }

    // delete file anyway
    File file = File(filepath);
    if (file.existsSync()) {
      file.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? icon;

    if (_file != null && _file!.existsSync()) {
      icon = CircleAvatar(
        backgroundImage: FileImage(_file!),
        radius: 64.0,
      );
    } else if (_url != null && _url!.isNotEmpty) {
      icon = CircleAvatar(
        backgroundImage: NetworkImage(_url!),
        radius: 64.0,
      );
    } else {
      icon = CircleAvatar(
        child: Icon(Icons.add_a_photo_outlined),
        radius: 64.0,
        foregroundColor: Colors.white,
      );
    }

    return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(children: [
          Center(
              child: IconButton(
            iconSize: 64,
            icon: icon,
            onPressed: _showDialog,
          )),
          Text(state.errorText ?? '',
              style: TextStyle(color: Theme.of(context).errorColor)),
        ]));
  }
}

class PhotoImage extends StatefulWidget {
  @override
  _PhotoImageState createState() => _PhotoImageState();
}

class _PhotoImageState extends State<PhotoImage> {
  File? _file;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future _showDialog() async {
    var pane = (_file != null)
        ? [
            TextButton(
              child: Text("Remove photo"),
              onPressed: () => Navigator.pop(context, "remove"),
            ),
            TextButton(
              child: Text("Take photo"),
              onPressed: () => Navigator.pop(context, "camera"),
            ),
            TextButton(
              child: Text("Select new photo"),
              onPressed: () => Navigator.pop(context, "photo"),
            ),
          ]
        : [
            TextButton(
              child: Text("Take photo"),
              onPressed: () => Navigator.pop(context, "camera"),
            ),
            TextButton(
              child: Text("Choose photo"), // Select new photo
              onPressed: () => Navigator.pop(context, "photo"),
            ),
          ];

    final result = await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Change photo"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pane,
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context, "test"),
              ),
            ],
          );
        });

    switch (result) {
      case "camera":
        {
          getImage(ImageSource.camera);
          break;
        }
      case "photo":
        {
          getImage(ImageSource.gallery);
          break;
        }
      case "remove":
        {
          removePhoto();
          break;
        }
      default:
        break;
    }
  }

  Future removePhoto() async {
    if (_file != null && _file!.existsSync()) {
      await _file!.delete();
      _file = null;
      setState(() {});
    }
  }

  Future getImage(source) async {
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      if (file.existsSync()) {
        _cropImage(pickedFile.path);
      }
    }
  }

  Future _cropImage(filepath) async {
    File? croppedImage = await ImageCropper.cropImage(
      sourcePath: filepath,
      maxWidth: 640,
      maxHeight: 640,
    );

    if (croppedImage != null) {
      _file = croppedImage;
      setState(() {});
    }

    // delete file anyway
    File file = File(filepath);
    if (file.existsSync()) {
      file.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? icon;

    if (_file != null) {
      icon = CircleAvatar(
        backgroundImage: FileImage(_file!),
        radius: 64.0,
      );
    } else {
      icon = CircleAvatar(
        child: Icon(Icons.add_a_photo_outlined),
        radius: 64.0,
        foregroundColor: Colors.white,
      );
    }

    return Container(
      padding: EdgeInsets.all(24.0),
      child: Center(
          child: IconButton(
        iconSize: 64,
        icon: icon,
        onPressed: _showDialog,
      )),
    );
  }
}
