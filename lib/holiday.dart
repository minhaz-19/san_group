import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/main.dart';
import 'package:intl/intl.dart';

bool _is_holiday_loading = false;

class holiday extends StatefulWidget {
  const holiday({super.key});

  @override
  State<holiday> createState() => _holidayState();
}

class _holidayState extends State<holiday> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Holidays of ${DateFormat.yMMMM('en_US').format(DateTime.now())}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      drawer: home_drawer(),
      body: holiday_widget(),
    );
  }
}

class holiday_widget extends StatefulWidget {
  const holiday_widget({super.key});

  @override
  State<holiday_widget> createState() => _holiday_widgetState();
}

class _holiday_widgetState extends State<holiday_widget> {
  bool _is_data_available = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _is_holiday_loading = true;
    });
    FirebaseFirestore.instance
        .collection('information')
        .doc('holiday')
        .collection(DateFormat.yMMMM('en_US').format(DateTime.now()))
        .get()
        .then((value) {
      if (value.size == 0) {
        setState(() {
          _is_data_available = false;
          _is_holiday_loading = false;
        });
      } else {
        setState(() {
          _is_data_available = true;
          _is_holiday_loading = false;
        });
      }
    });
  }

  @override
  final Stream<QuerySnapshot> _add_holiday_Stream = FirebaseFirestore.instance
      .collection('information')
      .doc('holiday')
      .collection(DateFormat.yMMMM('en_US').format(DateTime.now()))
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return (_is_holiday_loading == true)
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : (_is_data_available == false)
            ? Scaffold(
                body: Center(
                  child: Text(
                      'Holidays of ${DateFormat.yMMMM('en_US').format(DateTime.now())} is not declared yet'),
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: _add_holiday_Stream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat.yMMMMd('en_US')
                                        .format(data['time'].toDate()),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Reason: ${data['reason']}',
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
