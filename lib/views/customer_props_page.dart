import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:wecare/models/customer.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/widgets/dialogs.dart';
import 'package:wecare/widgets/props/props_values.dart';
import 'package:wecare/widgets/props/props_widget.dart';

class CustomerPropsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PropsWidget(CustomerProps(context));
  }
}

class CustomerProps extends PropsValues {
  bool _imageDirty = false;
  bool _dirty = false;
  bool _isNewUser = true;
  late Customer _customer;

  CustomerProps(BuildContext context) {
    title = "Create Customer";
    _customer = Customer();
    _isNewUser = true;
  }

  bool get dirty => _dirty || _imageDirty;

  List<PropsValueItem> items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: _customer.image_url,
        onSaved: (String? value) {
          if (value != null || value!.isNotEmpty) {
            _customer.filepath = value;
          }
        },
        validator: (_) {
          // not necessarily set
          return null;
        },
        onChanged: (_) => _imageDirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: _customer.name,
        icon: Icons.business_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Company is required";
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
          await firebase.customersRef.add(_customer);

      _customer.id = value.id;

      if (_customer.filepath != null && _customer.filepath!.isNotEmpty) {
        final imagePath = 'images/' + _customer.id! + '/customer.jpg';

        // upload the image file
        _customer.image_url =
            await firebase.uploadFile(imagePath, _customer.filepath!);

        firebase.customersRef
            .doc(_customer.id!)
            .update({'image_url': _customer.image_url});
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
    }

    // pop down the loading icon
    Navigator.of(context).pop();

    if (error != null) {
      // context comes from scaffold
      showSnackBar(context: context, message: error);
    } else {
      // replace the current page with the root page
      AppState appState = context.read<AppState>();
      appState.route?.replace('/');
    }
  }
}
