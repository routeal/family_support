import 'package:flutter/material.dart';

class PropsTextFieldItem extends StatefulWidget {
  final String? initialValue;
  final String? label;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final IconData? icon;
  final bool enabled;

  const PropsTextFieldItem({
    this.initialValue,
    this.label,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.icon,
    this.enabled = true,
  });

  @override
  _PropsTextFieldItemState createState() => _PropsTextFieldItemState();
}

class _PropsTextFieldItemState extends State<PropsTextFieldItem> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.all(12.0),
      child: TextFormField(
        controller: controller,
        decoration: new InputDecoration(
          icon: Icon(
            widget.icon ?? Icons.person,
            color: (widget.icon == null)
                ? Theme.of(context).canvasColor
                : Theme.of(context).iconTheme.color,
          ),
          labelText: widget.label,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(5.0),
            borderSide: new BorderSide(),
          ),
        ),
        validator: widget.validator,
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
        enabled: widget.enabled,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void didUpdateWidget(PropsTextFieldItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.text = widget.initialValue ?? '';
  }
}
