import 'package:flutter/material.dart';

class Caregiver {
  String displayName;
  Caregiver({required this.displayName});
}

class Recipient {
  String displayName;
  Recipient({required this.displayName});
}

class Doctor {
  String displayName;
  Doctor({required this.displayName});
}

class CareManager {
  String displayName;
  CareManager({required this.displayName});
}

class SupportMembers extends StatefulWidget {
  List<Caregiver> caregivers = [];
  List<Recipient> recipents = [];
  List<Doctor> doctors = [];
  List<CareManager> careManagers = [];
  SupportMembers() {
    caregivers.add(Caregiver(displayName: 'Hiroshi'));
    caregivers.add(Caregiver(displayName: 'Keiko'));
    recipents.add(Recipient(displayName: 'Takahashi'));
    doctors.add(Doctor(displayName: 'Black Jack'));
    careManagers.add(CareManager(displayName: 'Fukuchan'));
  }
  @override
  State<SupportMembers> createState() => _SupportMembers();
}

class _SupportMembers extends State<SupportMembers> {
  Widget get caregivers {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CategoryHeader(
              icon: Icons.people_outline_outlined, title: 'Caregivers'),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: widget.caregivers.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text(widget.caregivers[index].displayName),
                    ),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(title: 'Add caregiver', onTap: () => {}),
        ]);
  }

  Widget get recipients {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CategoryHeader(
              icon: Icons.people_outline_outlined, title: 'Recipients'),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: widget.recipents.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text(widget.recipents[index].displayName),
                    ),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(title: 'Add recipient', onTap: () => {}),
        ]);
  }

  Widget get doctors {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CategoryHeader(icon: Icons.people_outline_outlined, title: 'Doctors'),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: widget.recipents.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text(widget.doctors[index].displayName),
                    ),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(title: 'Add doctor', onTap: () => {}),
        ]);
  }

  Widget get careManagers {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CategoryHeader(
              icon: Icons.people_outline_outlined, title: 'Care Managers'),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: widget.recipents.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text(widget.careManagers[index].displayName),
                    ),
                    const Divider(),
                  ],
                );
              }),
          AddCategoryItem(title: 'Add care manager', onTap: () => {}),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Team Members')),
        body: SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        caregivers,
        recipients,
        careManagers,
        doctors,
      ],
    )));
  }
}

class CategoryHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  const CategoryHeader(
      {Key? key, required this.icon, required this.title, this.color})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4),
        color: color ?? Colors.pink[100]!,
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(icon),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ));
  }
}

class AddCategoryItem extends StatelessWidget {
  final String title;
  final Color? color;
  final VoidCallback? onTap;
  const AddCategoryItem({Key? key, this.onTap, required this.title, this.color})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(8),
            color: color,
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.add_outlined),
                const SizedBox(width: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            )));
  }
}
