import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/pages/add_new_office.dart';

class office_list extends StatefulWidget {
  const office_list({super.key});

  @override
  State<office_list> createState() => _office_listState();
}

class _office_listState extends State<office_list> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office List',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push((this.context),
              MaterialPageRoute(builder: (context) => add_new_office()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
      ),
      drawer: home_drawer(),
      body: office_list_widget(),
    );
  }
}

class office_list_widget extends StatefulWidget {
  const office_list_widget({super.key});

  @override
  State<office_list_widget> createState() => _office_list_widgetState();
}

class _office_list_widgetState extends State<office_list_widget> {
  @override
  final Stream<QuerySnapshot> _employee_list_Stream =
      FirebaseFirestore.instance.collection('office').snapshots();

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
                  child: ListTile(
                    title: Text(
                      "Office Location: ${data['office name'] ?? ''}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Office Latitude: ${data['latitude'] ?? ''}",
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          "Office Longitude: ${data['longitude'] ?? ''}",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
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
