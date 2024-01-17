import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/main.dart';
import 'package:intl/intl.dart';

class leave_report extends StatefulWidget {
  const leave_report({super.key});

  @override
  State<leave_report> createState() => _leave_reportState();
}

class _leave_reportState extends State<leave_report> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('leave Report',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      drawer: home_drawer(),
      body: leave_report_widget(),
    );
  }
}

class leave_report_widget extends StatefulWidget {
  const leave_report_widget({super.key});

  @override
  State<leave_report_widget> createState() => _leave_report_widgetState();
}

class _leave_report_widgetState extends State<leave_report_widget> {
  @override
  final Stream<QuerySnapshot> _leave_report_Stream = FirebaseFirestore.instance
      .collection('id')
      .doc(emp_id)
      .collection('report')
      .doc('leave report')
      .collection(DateFormat.y('en_US').format(DateTime.now()))
      .orderBy('time', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _leave_report_Stream,
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
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'From: ${DateFormat.yMMMMd('en_US').format(data['starting date'].toDate())}'),
                              Text(data['request status'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          (data['request status'].toString() ==
                                                  "Approved")
                                              ? Colors.green
                                              : (data['request status']
                                                          .toString() ==
                                                      "Rejected")
                                                  ? Colors.red
                                                  : Colors.black))
                            ]),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'To: ${DateFormat.yMMMMd('en_US').format(data['ending date'].toDate())}',
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                    subtitle: Text("Remarks:  ${data['reason'] ?? ''}"),
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
