import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:san_group/component/progressbar.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/main.dart';
import 'package:intl/intl.dart';
import 'package:san_group/pages/my_information.dart';

class tour_approval extends StatefulWidget {
  const tour_approval({super.key});

  @override
  State<tour_approval> createState() => _tour_approvalState();
}

class _tour_approvalState extends State<tour_approval> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Tour approvals',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      drawer: home_drawer(),
      body: tour_approval_widget(),
    );
  }
}

class tour_approval_widget extends StatefulWidget {
  const tour_approval_widget({super.key});

  @override
  State<tour_approval_widget> createState() => _tour_approval_widgetState();
}

class _tour_approval_widgetState extends State<tour_approval_widget> {
  String _requester_id = ' ';
  String _request_reason = '';
  String _request_month = " ";
  String _request_year = ' ';
  String _requester_post = '';
  String _requester_name = '';
  Timestamp _request_timestamp = Timestamp.now();
  DateTime _request_doc_id = DateTime.now();
  var _request_duratio;
  DateTime _request_start_date = DateTime.now();
  DateTime _request_end_date = DateTime.now();
  String _approver_id = '';
  String _requester_image = '';

  @override
  final Stream<QuerySnapshot> _pending_tour_approval_Stream = FirebaseFirestore
      .instance
      .collection('id')
      .doc(emp_id)
      .collection('tour approval')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _pending_tour_approval_Stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ProgressBar());
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
                        _requester_name = data['name'];
                        _requester_image = data['image'];
                        _requester_post = data['post'];
                        _requester_id = data['emp id'];
                        _request_reason = data['reason'];
                        _request_timestamp = data['time'];
                        _request_doc_id = _request_timestamp.toDate();
                        _request_timestamp = data['starting date'];
                        _request_start_date = _request_timestamp.toDate();
                        _request_month = DateFormat.MMMM('en_US')
                            .format(_request_timestamp.toDate());
                        _request_year = DateFormat.y('en_US')
                            .format(_request_timestamp.toDate());
                        _request_timestamp = data['ending date'];
                        _request_end_date = _request_timestamp.toDate();
                        _request_duratio =
                            (_request_end_date.day != _request_start_date.day)
                                ? (_request_end_date
                                        .difference(_request_start_date)
                                        .inDays
                                        .toInt() +
                                    1)
                                : (_request_end_date
                                    .difference(_request_start_date)
                                    .inDays
                                    .toInt());
                        _request_duratio++;
                      });
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              scrollable: true,
                              title: const Center(
                                  child: Text('Request for tour entry')),
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Name: ${data['name']}'),
                                    Text('Emp id: $_requester_id'),
                                    Text(
                                        'From: ${DateFormat.yMMMMd('en_US').format(_request_start_date)} ( ${DateFormat.EEEE('en_US').format(data['starting date'].toDate())} )'),
                                    Text(
                                        'To: ${DateFormat.yMMMMd('en_US').format(_request_end_date)} ( ${DateFormat.EEEE('en_US').format(data['ending date'].toDate())} )'),
                                  ],
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueGrey,
                                        ),
                                        child: const Text("Reject"),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('id')
                                              .doc(emp_id)
                                              .collection('tour approval')
                                              .doc(
                                                  '$_requester_id $_request_doc_id')
                                              .delete();

                                          await FirebaseFirestore.instance
                                              .collection('id')
                                              .doc(_requester_id)
                                              .collection('report')
                                              .doc('tour report')
                                              .collection(_request_year)
                                              .doc('$_request_doc_id')
                                              .update({
                                            'request status': 'Rejected'
                                          });
                                          setState(() {
                                            pending_request_in_tour_approval--;
                                            total_pending_request--;
                                          });
                                          Fluttertoast.showToast(
                                              msg: 'Request rejected');
                                          Navigator.of(context).pop();
                                        }),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueGrey,
                                        ),
                                        child: const Text("Accept"),
                                        onPressed: () async {
                                          if (post == 'Zonal Head' &&
                                              _requester_post == 'Executive') {
                                            await FirebaseFirestore.instance
                                                .collection('id')
                                                .doc(approver_id)
                                                .collection('tour approval')
                                                .doc(
                                                    '$_requester_id $_request_doc_id')
                                                .set({
                                              'reason': _request_reason,
                                              'emp id': _requester_id,
                                              'image': _requester_image,
                                              'starting date':
                                                  _request_start_date,
                                              'ending date': _request_end_date,
                                              'name': _requester_name,
                                              'time': _request_doc_id,
                                              'post': _requester_post,
                                            });
                                            await FirebaseFirestore.instance
                                                .collection('id')
                                                .doc(emp_id)
                                                .collection('tour approval')
                                                .doc(
                                                    '$_requester_id $_request_doc_id')
                                                .delete();
                                            setState(() {
                                              pending_request_in_tour_approval--;
                                              total_pending_request--;
                                            });
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Tour request accepted\nduration: $_request_duratio days');
                                            Navigator.of(context).pop();
                                          } else {
                                            var attendance_reference =
                                                FirebaseFirestore.instance
                                                    .collection('id')
                                                    .doc(_requester_id)
                                                    .collection('report')
                                                    .doc('attendance report')
                                                    .collection(_request_year)
                                                    .doc(_request_month);
                                            await attendance_reference
                                                .get()
                                                .then((value) async {
                                              if (value.exists) {
                                                attendance_reference.update({
                                                  'tour': FieldValue.increment(
                                                      _request_duratio),
                                                });
                                              } else {
                                                attendance_reference.set({
                                                  'present': 0,
                                                  'late': 0,
                                                  'absent': 0,
                                                  'holiday': 0,
                                                  'tour': _request_duratio,
                                                  'leave': 0,
                                                });
                                              }
                                              await FirebaseFirestore.instance
                                                  .collection('id')
                                                  .doc(emp_id)
                                                  .collection('tour approval')
                                                  .doc(
                                                      '$_requester_id $_request_doc_id')
                                                  .delete();
                                              setState(() {
                                                pending_request_in_tour_approval--;
                                                total_pending_request--;
                                              });
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'Tour request accepted\nduration: $_request_duratio days');
                                              Navigator.of(context).pop();
                                            });

                                            await FirebaseFirestore.instance
                                                .collection('id')
                                                .doc(_requester_id)
                                                .collection('report')
                                                .doc('tour report')
                                                .collection(_request_year)
                                                .doc('$_request_doc_id')
                                                .update({
                                              'request status': 'Approved'
                                            });
                                          }

                                          // popping the dialog box. routine will update in the background if device is not online
                                        }),
                                  ],
                                ),
                              ],
                            );
                          });
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
                            ProgressBar(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      title: Text(
                        data['name'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['emp id'] ?? ''),
                          Text(
                              'From: ${DateFormat.yMMMMd('en_US').format(data['starting date'].toDate())} ( ${DateFormat.EEEE('en_US').format(data['starting date'].toDate())} )'),
                          Text(
                              'To: ${DateFormat.yMMMMd('en_US').format(data['ending date'].toDate())} ( ${DateFormat.EEEE('en_US').format(data['ending date'].toDate())} )'),
                          Text('Remarks: ${data['reason']}')
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
