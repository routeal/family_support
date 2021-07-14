import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/widgets/props/props_image_item.dart';
import 'package:wecare/widgets/props/props_text_item.dart';
import 'package:wecare/widgets/props/props_textfield_item.dart';
import 'package:wecare/widgets/props/props_values.dart';

class PropsWidget extends StatelessWidget {
  final PropsValues props;

  PropsWidget(this.props);

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    props.key = _formKey;
    return WillPopScope(
      onWillPop: () async {
        final result = props.dirty
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
        appBar: AppBar(
          title: Text(props.title ?? 'Props'),
          actions: [
            (props.logoutButtonLabel != null)
                ? TextButton(
                    child: Text(props.logoutButtonLabel ?? 'Logout',
                        style: Theme.of(context).textTheme.button),
                    onPressed: () {
                      FirebaseService firebase =
                          context.read<FirebaseService>();
                      firebase.signOut();
                    })
                : Container(),
            TextButton(
                child: Text(props.saveButtonLabel ?? 'Save',
                    style: Theme.of(context).textTheme.button),
                onPressed: () => {props.submit(context)}),
          ],
        ),
        body: Container(
          child: SingleChildScrollView(
            child: FocusTraversalGroup(
              child: Column(
                children: [
                  //PhotoImage(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: props.items().map<Widget>((item) {
                        if (item.type == PropsType.Photo) {
                          return PropsImageItem(
                            initialValue: item.init,
                            onSaved: item.onSaved,
                            validator: item.validator,
                            onChanged: item.onChanged,
                          );
                        } else if (item.type == PropsType.Error) {
                          return PropsTextItem(
                            label: item.label,
                          );
                        } else if (item.type == PropsType.InputField) {
                          return PropsTextFieldItem(
                            icon: item.icon,
                            initialValue: item.init,
                            label: item.label,
                            validator: item.validator,
                            onSaved: item.onSaved,
                            onChanged: item.onChanged,
                            enabled: item.enabled,
                          );
                        } else {
                          return Container();
                        }
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
