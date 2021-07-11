import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wecare/models/customer.dart';
import 'package:wecare/views/home_page.dart';
import 'package:wecare/widgets/dialogs.dart';
import 'package:wecare/widgets/props/props_values.dart';
import 'package:wecare/widgets/props/props_widget.dart';

class CustomerPropsPage extends StatelessWidget {
  final props = CustomerProps();

  @override
  Widget build(BuildContext context) {
    return PropsWidget(props);
  }
}

class CustomerProps extends PropsValues {
  final customer = Customer();

  CustomerProps() {
    title = "Create Customer";
  }

  List<PropsValueItem> items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: customer.image,
        onSaved: (String? value) {
          if (value != null || value!.isNotEmpty) {
            customer.filepath = value;
          }
        },
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return "Photo is required";
          }
          File file = File(value);
          if (!file.existsSync()) {
            return 'Photo is not saved in ' + value;
          }
          return null;
        },
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: customer.name,
        icon: Icons.business_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Company is required";
          return null;
        },
        onSaved: (String? value) => customer.name = value!,
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Phone",
        init: customer.phone,
        icon: Icons.phone_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Phone is required";
          return null;
        },
        onSaved: (String? value) => customer.phone = value!,
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Email",
        init: customer.email,
        icon: Icons.email_outlined,
        onSaved: (String? value) => customer.email = value!,
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: customer.address,
        icon: Icons.place_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Address is required";
          return null;
        },
        onSaved: (String? value) => customer.address = value!,
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Website",
        init: customer.website,
        icon: Icons.public_outlined,
        onSaved: (String? value) => customer.website = value!,
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Representative",
        init: customer.representative,
        icon: Icons.support_agent_outlined,
        onSaved: (String? value) => customer.representative = value!,
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
      ),
    ];
  }

  final customersRef = FirebaseFirestore.instance
      .collection('customers')
      .withConverter<Customer>(
        fromFirestore: (snapshots, _) => Customer.fromJson(snapshots.data()!),
        toFirestore: (customer, _) => customer.toJson(),
      );

  Future<void> submit(context) async {
    // check the validation of each field
    bool hasValidated = key?.currentState?.validate() ?? false;
    if (!hasValidated) {
      return;
    }

    // save the form fields
    key?.currentState?.save();

    // display loading icon
    loadingDialog(context);

    // create a new customer
    customersRef.add(customer).then((value) {
      customer.id = value.id;
    }).then((_) {
      return File(customer.filepath);
    }).then((file) {
      final filename = 'images/' + customer.id + '/customer.jpg';
      return FirebaseStorage.instance.ref(filename).putFile(file);
    }).then((taskSnapshot) {
      // get the url of the image in the cloud storage
      return taskSnapshot.ref.getDownloadURL();
    }).then((downloadURL) {
      // update the customer
      return FirebaseFirestore.instance
          .collection('customers')
          .doc(customer.id)
          .update({'image': downloadURL});
    }).catchError((error) {
      // close the loading dialog
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Theme.of(context).canvasColor,
          textColor: Theme.of(context).errorColor);
    }).whenComplete(() {
      // go back to Home screen in anyway
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false);
    });
  }
}
