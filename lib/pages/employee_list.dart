import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/pages/employee_info.dart';

String editing_employee_name = '';
String editing_employee_id = '';
String editing_employee_image = '';
String editing_employee_post = '';
String editing_employee_mobile = '';
String editing_employee_office = '';
String editing_employee_reporting_to = '';

class employee_list extends StatefulWidget {
  const employee_list({super.key});

  @override
  State<employee_list> createState() => _employee_listState();
}

class _employee_listState extends State<employee_list> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Employee List',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      drawer: home_drawer(),
      body: employee_list_widget(),
    );
  }
}

class employee_list_widget extends StatefulWidget {
  const employee_list_widget({super.key});

  @override
  State<employee_list_widget> createState() => _employee_list_widgetState();
}

class _employee_list_widgetState extends State<employee_list_widget> {
  @override
  final Stream<QuerySnapshot> _employee_list_Stream =
      FirebaseFirestore.instance.collection('id').snapshots();

  String _name = '';
  String _id = '';
  String _image = '';
  String _post = '';
  String _mobile = '';
  String _office = '';
  String _reporting_to = '';

  String _show_employee_id(String empId) {
    int eid = int.parse(empId);
    if (eid <= 9) {
      return 'SG-0000$eid';
    } else if (eid <= 99) {
      return 'SG-000$eid';
    } else if (eid <= 999) {
      return 'SG-00$eid';
    } else if (eid <= 9999) {
      return 'SG-0$eid';
    } else {
      return 'SG-$eid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _employee_list_Stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs
              .map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return Card(
                  borderOnForeground: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        editing_employee_name = data['name'];
                        editing_employee_image = data['image'];
                        editing_employee_post = data['post'];
                        editing_employee_mobile = data['mobile'];
                        editing_employee_office = data['office'];
                        editing_employee_reporting_to =
                            data['attendance approver'];
                        editing_employee_id = _show_employee_id(data['id']);
                      });

                      Navigator.push(
                          (this.context),
                          MaterialPageRoute(
                              builder: (context) => employee_info()));
                    },
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: data['image'] ?? " ",
                        imageBuilder: (context, imageProvider) => Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      title: Text(
                        data['name'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_show_employee_id(data['id'] ?? '')),
                          Text(data['post'] ?? ''),
                        ],
                      ),
                    ),
                  ),
                );
              })
              .toList()
              .cast(),
        );
      },
    );
  }
}
