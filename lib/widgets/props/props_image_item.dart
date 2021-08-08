import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PropsImageItem extends FormField<String> {
  final ValueChanged<String>? onChanged;
  PropsImageItem({
    String? initialValue, // image url
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    this.onChanged,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<String> state) {
              return state.build(state.context);
            });
  @override
  FormFieldState<String> createState() {
    return _PropsImageItemImageState(onChanged: onChanged);
  }
}

class _PropsImageItemImageState extends FormFieldState<String> {
  final ValueChanged<String>? onChanged;

  _PropsImageItemImageState({this.onChanged});

  String? _imageUrl;
  File? _croppedFile;
  final _picker = ImagePicker();

  Future _showDialog() async {
    var pane = ((_imageUrl?.isEmpty ?? false) &&
            (_croppedFile == null || !_croppedFile!.existsSync()))
        ? [
            TextButton(
              child: Text("Take photo"),
              onPressed: () => Navigator.pop(context, "camera"),
            ),
            TextButton(
              child: Text("Choose photo"), // Select new photo
              onPressed: () => Navigator.pop(context, "photo"),
            ),
          ]
        : [
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
    super.initState();
    _imageUrl = value;
  }

  Future<void> removePhoto() async {
    if (_croppedFile != null && _croppedFile!.existsSync()) {
      await _croppedFile!.delete();
      _croppedFile = null;
    }
    if (_imageUrl != null) {
      _imageUrl = null;
    }
    setValue(null);
    setState(() {});
    if (onChanged != null) {
      onChanged!('');
    }
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      if (file.existsSync()) {
        _cropImage(pickedFile.path);
      }
    }
  }

  Future<void> _cropImage(String imageSource) async {
    File? croppedImage = await ImageCropper.cropImage(
      sourcePath: imageSource,
      maxWidth: 120,
      maxHeight: 120,
      compressQuality: 70,
      cropStyle: CropStyle.circle,
    );

    // delete file anyway
    File file = File(imageSource);
    if (file.existsSync()) {
      file.delete();
    }

    if (croppedImage != null) {
      // disable the original image
      _imageUrl = null;
      _croppedFile = croppedImage;
      setValue(_croppedFile?.path);
      setState(() {});
      if (onChanged != null) {
        onChanged!('');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? icon;

    if (!(_imageUrl?.isEmpty ?? true)) {
      icon = CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(_imageUrl!),
        radius: 32,
      );
    } else if (_croppedFile != null && _croppedFile!.existsSync()) {
      icon = CircleAvatar(
        backgroundImage: FileImage(_croppedFile!),
        radius: 32,
      );
    } else {
      icon = CircleAvatar(
        child: Icon(Icons.add_a_photo_outlined, size: 32),
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightBlueAccent,
        radius: 32,
      );
    }

    return Container(
        child: Column(children: [
      SizedBox(
          height: 100,
          child: IconButton(
            icon: icon,
            iconSize: 64,
            onPressed: _showDialog,
          )),
      (errorText != null)
          ? Text(errorText!,
              style: TextStyle(color: Theme.of(context).errorColor))
          : Container(),
    ]));
  }
}
