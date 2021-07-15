import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:wecare/models/customer.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/widgets/dialogs.dart';
import 'package:wecare/widgets/props/props_values.dart';
import 'package:wecare/widgets/props/props_widget.dart';

class CustomerPropsPage extends StatelessWidget {
  Customer? customer;
  CustomerPropsPage([this.customer]);
  @override
  Widget build(BuildContext context) {
    return PropsWidget(CustomerProps(context, customer));
  }
}

class CustomerProps extends PropsValues {
  bool _imageDirty = false;
  bool _dirty = false;
  bool _isNewUser = true;
  late Customer _customer;
  Customer? _origin;

  CustomerProps(BuildContext context, Customer? customer) {
    if (customer == null) {
      title = "Create Customer";
      _isNewUser = true;
      _customer = Customer();
    } else {
      title = customer.name ?? '';
      _isNewUser = false;
      _customer = customer.clone();
      _origin = customer;
    }
  }

  bool get dirty => _dirty || _imageDirty;

  List<PropsValueItem> items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: _customer.image_url,
        onSaved: (String? value) => _customer.filepath = value,
        onChanged: (_) => _imageDirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Name",
        init: _customer.name,
        icon: Icons.person_outline,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Name is required";
          return null;
        },
        onSaved: (String? value) => _customer.name = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Phone",
        init: _customer.phone,
        icon: Icons.phone_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Phone is required";
          return null;
        },
        onSaved: (String? value) => _customer.phone = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Email",
        init: _customer.email,
        icon: Icons.email_outlined,
        onSaved: (String? value) => _customer.email = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: _customer.address,
        icon: Icons.place_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Address is required";
          return null;
        },
        onSaved: (String? value) => _customer.address = value!,
        onChanged: (_) => _dirty = true,
      ),
    ];
  }

  Future<String?> createCustomer(BuildContext context) async {
    String? error;
    try {
      FirebaseService firebase = context.read<FirebaseService>();

      // create a new customer
      DocumentReference<Customer> value =
          await firebase.createCustomer(_customer);

      _customer.id = value.id;

      if (!(_customer.filepath?.isEmpty ?? true)) {
        final path = firebase.customerImagePath(_customer.id!);

        print('create: ' + path);

        // upload the image file
        _customer.image_url =
            await firebase.uploadFile(path, _customer.filepath!);

        await firebase.updateCustomerImage(_customer.id!, _customer.image_url);
      }
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> updateCustomer(BuildContext context) async {
    String? error;
    try {
      FirebaseService firebase = context.read<FirebaseService>();

      final Map<String, Object?>? updates = _origin!.diff(_customer);
      if (updates != null) {
        updates.entries.forEach((entry) {
          print('${entry.key}:${entry.value}');
        });
        // update the user with the image url
        await firebase.updateCustomer(_origin!.id!, updates);
      }

      if (_imageDirty) {
        final path = firebase.customerImagePath(_customer.id!);

        if (_customer.filepath?.isEmpty ?? true) {
          print('remove: ' + path);

          _customer.image_url = null;
          await firebase.deleteFile(path);
          await firebase.updateCustomerImage(_customer.id!, null);
        } else if (_customer.filepath != _origin!.image_url) {
          print('replace: ' + path);

          // upload the image file
          _customer.image_url =
              await firebase.uploadFile(path, _customer.filepath!);
          await firebase.updateCustomerImage(
              _customer.id!, _customer.image_url);
        }
      }
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<void> submit(BuildContext context) async {
    // check the validation of each field
    bool hasValidated = key?.currentState?.validate() ?? false;
    if (!hasValidated) {
      return;
    }

    // save the form fields
    key?.currentState?.save();

    // display loading icon
    loadingDialog(context);

    String? error;

    if (_isNewUser) {
      error = await createCustomer(context);
    } else {
      error = await updateCustomer(context);
    }

    // pop down the loading icon
    Navigator.of(context).pop();

    if (error != null) {
      // context comes from scaffold
      showSnackBar(context: context, message: error);
    } else {
      Navigator.of(context).pop();
    }
  }
}
