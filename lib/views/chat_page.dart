import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:wecare/constants.dart' as Constants;
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/utils/colors.dart';
import 'package:wecare/views/app_state.dart';

String randomString() {
  var random = Random.secure();
  var values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  late String _teamId;
  late types.User _user;
  List<types.User> _teamUsers = [];

  types.User convertChatUser(User user) {
    return types.User(
      id: user.id!,
      imageUrl: user.imageUrl,
      lastName: user.lastName,
      firstName: user.firstName,
    );
  }

  @override
  void initState() {
    AppState appState = context.read<AppState>();
    _user = convertChatUser(appState.currentUser!);
    _teamId = appState.currentTeam!.id!;
    for (User u in appState.currentMembers) {
      _teamUsers.add(convertChatUser(u));
    }
    super.initState();
  }

  Stream<List<types.Message>> messages() {
    return FirebaseFirestore.instance
        .collection('chat/$_teamId/messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.fold<List<types.Message>>(
          [],
          (previousValue, element) {
            final data = element.data();
            final author = _teamUsers.firstWhere(
              (u) => u.id == data['authorId'],
              orElse: () => types.User(id: data['authorId'] as String),
            );

            data['author'] = author.toJson();
            data['id'] = element.id;
            try {
              data['createdAt'] = element['createdAt']?.millisecondsSinceEpoch;
              data['updatedAt'] = element['updatedAt']?.millisecondsSinceEpoch;
            } catch (e) {
              // Ignore errors, null values are ok
            }
            data.removeWhere((key, value) => key == 'authorId');
            return [...previousValue, types.Message.fromJson(data)];
          },
        );
      },
    );
  }

  void sendMessage(dynamic partialMessage) async {
    types.Message? message;

    if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        author: types.User(id: _user.id),
        id: '',
        partialFile: partialMessage,
        roomId: _teamId,
      );
    } else if (partialMessage is types.PartialImage) {
      message = types.ImageMessage.fromPartial(
        author: types.User(id: _user.id),
        id: '',
        partialImage: partialMessage,
        roomId: _teamId,
      );
    } else if (partialMessage is types.PartialText) {
      message = types.TextMessage.fromPartial(
        author: types.User(id: _user.id),
        id: '',
        partialText: partialMessage,
        roomId: _teamId,
      );
    }

    print('a');

    if (message != null) {
      print('b');
      final messageMap = message.toJson();
      messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
      messageMap['authorId'] = _user.id;
      messageMap['createdAt'] = FieldValue.serverTimestamp();
      messageMap['updatedAt'] = FieldValue.serverTimestamp();

      print(messageMap.toString());

      FirebaseService firebase = context.read<FirebaseService>();
      await firebase.sendMessage(_teamId, messageMap);
    }
  }

  void _addMessage(types.Message message) {
    sendMessage(message);
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path ?? '',
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: randomString(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFile.open(message.uri);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    /*
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );
    */

    sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.read<AppState>();
    return Scaffold(
        body: StreamBuilder<List<types.Message>>(
            initialData: const [],
            stream: messages(),
            builder: (context, snapshot) {
              return Chat(
                l10n: ChatL10nJp(),
                theme: DefaultChatTheme(
                  backgroundColor: Constants.defaultScaffoldColor,
                  inputBackgroundColor: Constants.defaultPrimaryColor,
                  inputTextColor: Colors.black87,
                  primaryColor: HexColor(appState.currentUser?.color),
                ),
                messages: snapshot.data ?? [],
                onAttachmentPressed: _handleAttachmentPressed,
                onMessageTap: _handleMessageTap,
                onPreviewDataFetched: _handlePreviewDataFetched,
                onSendPressed: _handleSendPressed,
                showUserAvatars: true,
                showUserNames: true,
                user: _user,
              );
            }));
  }
}

@immutable
class ChatL10nJp extends ChatL10n {
  /// Creates Ukrainian l10n. Use this constructor if you want to
  /// override only a couple of variables, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nJp({
    String attachmentButtonAccessibilityLabel = 'Send media',
    String emptyChatPlaceholder = 'No messages here yet',
    String fileButtonAccessibilityLabel = 'File',
    String inputPlaceholder = 'Message',
    String sendButtonAccessibilityLabel = 'Send',
  }) : super(
          attachmentButtonAccessibilityLabel:
              attachmentButtonAccessibilityLabel,
          emptyChatPlaceholder: emptyChatPlaceholder,
          fileButtonAccessibilityLabel: fileButtonAccessibilityLabel,
          inputPlaceholder: inputPlaceholder,
          sendButtonAccessibilityLabel: sendButtonAccessibilityLabel,
        );
}
