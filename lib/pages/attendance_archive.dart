import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:san_group/drawer.dart';
import 'package:san_group/main.dart';
import 'package:intl/intl.dart';

class attendance_archive extends StatefulWidget {
  const attendance_archive({super.key});

  @override
  State<attendance_archive> createState() => _attendance_archiveState();
}

class _attendance_archiveState extends State<attendance_archive> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Attendance Archive',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      drawer: home_drawer(),
      body: attendance_archive_widget(),
    );
  }
}

class attendance_archive_widget extends StatefulWidget {
  const attendance_archive_widget({super.key});

  @override
  State<attendance_archive_widget> createState() =>
      _attendance_archive_widgetState();
}

class _attendance_archive_widgetState extends State<attendance_archive_widget> {
  @override
  final Stream<QuerySnapshot> _tour_report_Stream = FirebaseFirestore.instance
      .collection('id')
      .doc(emp_id)
      .collection('attendance archive')
      .doc(DateFormat.y('en_US').format(DateTime.now()))
      .collection(DateFormat.MMMM('en_US').format(DateTime.now()))
      .orderBy('time', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _tour_report_Stream,
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
                                  "Date : ${DateFormat.yMMMMd('en_US').format(data['time'].toDate())}"),
                              if (data['attendance status'] != null)
                                Text(data['attendance status'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: (data['attendance status']
                                                    .toString() ==
                                                "Approved")
                                            ? Colors.green
                                            : (data['attendance status']
                                                        .toString() ==
                                                    "Rejected")
                                                ? Colors.red
                                                : Colors.black))
                            ]),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                            "Location :  ${data['attendance location'] ?? ''}"),
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
