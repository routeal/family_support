import 'package:flutter/material.dart';

class PropsTextItem extends StatefulWidget {
  final String? initialValue;
  final String? label;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final IconData? icon;

  const PropsTextItem({
    this.initialValue,
    this.label,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.icon,
  });

  @override
  _PropsTextItemState createState() => _PropsTextItemState();
}

class _PropsTextItemState extends State<PropsTextItem> {
  @override
  Widget build(BuildContext context) {
    //return Container();
    return Padding(
        padding: EdgeInsetsDirectional.only(start: 8, end: 8),
        child: Center(
          child: Text(widget.label!),
        ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(PropsTextItem oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}
