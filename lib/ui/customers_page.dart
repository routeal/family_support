import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';
import 'package:wecare/ui/customer_props_page.dart';
import 'package:wecare/models/customer.dart';
import 'package:wecare/services/firebase/firebase_service.dart';

class CustomersPage extends StatefulWidget {
  CustomersPage({Key? key}) : super(key: key);
  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late Stream<QuerySnapshot<Customer>> _customers;

  final customersRef = FirebaseFirestore.instance
      .collection('customers')
      .withConverter<Customer>(
        fromFirestore: (snapshots, _) => Customer.fromJson(snapshots.data()!),
        toFirestore: (customer, _) => customer.toJson(),
      );

  @override
  void initState() {
    getCustomers();
    super.initState();
  }

  void getCustomers() {
    setState(() {
      _customers = customersRef.snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('wecare'),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                context.read<FirebaseService>().signOut();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CustomerPropsPage()));
          },
        ),
        body: StreamBuilder<QuerySnapshot<Customer>>(
            stream: _customers,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.requireData;

              if (data.size == 0) {
                return const Center(child: Text('No customer yet'));
              }

              return Container(
                  padding: EdgeInsets.only(
                      top: 8.0, bottom: 4.0, left: 4.0, right: 4.0),
                  child: ListView.builder(
                    itemCount: data.size,
                    itemBuilder: (context, index) {
                      return _CustomerItem(
                        data.docs[index].data(),
                        data.docs[index].reference,
                      );
                    },
                  ));
            }));
  }
}

class _CustomerItem extends StatelessWidget {
  _CustomerItem(this.customer, this.reference) {
    customer.id = reference.id;
    print(customer.id);
  }

  final Customer customer;
  final DocumentReference<Customer> reference;

  /// Returns the customer image
  Widget photo(BuildContext context) {
    return Material(
      child: (customer.image?.isNotEmpty ?? false)
          ? CircleAvatar(
              backgroundImage: NetworkImage(customer.image!),
              radius: 25.0,
            )
          : CircleAvatar(
              child: Icon(
                Icons.account_circle,
                size: 50.0,
                color: Theme.of(context).disabledColor,
              ),
              radius: 25.0,
              backgroundColor: Theme.of(context).canvasColor,
            ),
      borderRadius: BorderRadius.all(Radius.circular(25.0)),
      clipBehavior: Clip.hardEdge,
    );
  }

  /// Returns Customer details.
  Widget details(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          since(context),
          name(context),
          address(context),
        ],
      ),
    );
  }

  /// Return the Customer title.
  Widget name(BuildContext context) {
    return Container(
      child: Text(
        '${customer.name}',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark),
      ),
    );
  }

  Widget since(BuildContext context) {
    String str = '';
    if (customer.created_at != null) {
      str = DateFormat('yMMMd').format(customer.created_at!);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Text(
        '${str}',
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).primaryColorDark),
      ),
    ]);
  }

  // Returns metadata about the Customer.
  Widget address(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 4.0),
      child: Text(
        '${customer.address}',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).primaryColorDark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.0),
      child: TextButton(
        child: Row(
          children: <Widget>[
            photo(context),
            Flexible(child: details(context)),
          ],
        ),
        onPressed: () {},
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(Theme.of(context).canvasColor),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
          ),
        ),
      ),
    );
  }
}
