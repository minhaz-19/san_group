import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:san_group/component/progressbar.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/main.dart';
import 'package:intl/intl.dart';
import 'package:san_group/pages/my_information.dart';

class outside_office_entry_approval extends StatefulWidget {
  const outside_office_entry_approval({super.key});

  @override
  State<outside_office_entry_approval> createState() =>
      _outside_office_entry_approvalState();
}

class _outside_office_entry_approvalState
    extends State<outside_office_entry_approval> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Outside Office Approvals',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      drawer: home_drawer(),
      body: outside_office_entry_approval_widget(),
    );
  }
}

class outside_office_entry_approval_widget extends StatefulWidget {
  const outside_office_entry_approval_widget({super.key});

  @override
  State<outside_office_entry_approval_widget> createState() =>
      _outside_office_entry_approval_widgetState();
}

class _outside_office_entry_approval_widgetState
    extends State<outside_office_entry_approval_widget> {
  String _requester_id = ' ';
  String _request_reason = '';
  String _request_month = " ";
  String _request_year = ' ';
  Timestamp _request_timestamp = Timestamp.now();
  String _request_doc_id = " ";
  String _requester_post = '';
  String _approver_id = '';
  String _requester_image = '';
  String _requester_name = '';
  @override
  final Stream<QuerySnapshot> _pending_approval_Stream = FirebaseFirestore
      .instance
      .collection('id')
      .doc(emp_id)
      .collection('outside office approval')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _pending_approval_Stream,
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
                        _request_reason = data['description'];
                        _request_timestamp = data['time'];
                        _request_month = DateFormat.MMMM('en_US')
                            .format(_request_timestamp.toDate());
                        _request_year = DateFormat.y('en_US')
                            .format(_request_timestamp.toDate());
                        _request_doc_id = DateFormat.yMMMMd('en_US')
                            .format(_request_timestamp.toDate());
                      });
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              scrollable: true,
                              title: const Center(
                                  child:
                                      Text('Request for outside office entry')),
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Emp id: $_requester_id'),
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
                                              .doc(_requester_id)
                                              .collection('attendance archive')
                                              .doc(_request_year)
                                              .collection(_request_month)
                                              .doc(
                                                  '${_request_timestamp.toDate()}')
                                              .update({
                                            'time':
                                                '${_request_timestamp.toDate()}',
                                            'attendance location':
                                                'Outside Office',
                                            'attendance status': 'Rejected',
                                          });
                                          await FirebaseFirestore.instance
                                              .collection('id')
                                              .doc(emp_id)
                                              .collection(
                                                  'outside office approval')
                                              .doc(
                                                  '$_request_doc_id $_requester_id')
                                              .delete();
                                          setState(() {
                                            pending_request_in_outside_approval--;
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
                                                .collection(
                                                    'outside office approval')
                                                .doc(
                                                    '$_request_doc_id $_requester_id')
                                                .set({
                                              'description': _request_reason,
                                              'emp id': _requester_id,
                                              'image': _requester_image,
                                              'time':
                                                  _request_timestamp.toDate(),
                                              'name': _requester_name,
                                              'post': _requester_post,
                                            });

                                            FirebaseFirestore.instance
                                                .collection('id')
                                                .doc(emp_id)
                                                .collection(
                                                    'outside office approval')
                                                .doc(
                                                    '$_request_doc_id $_requester_id')
                                                .delete();
                                            setState(() {
                                              pending_request_in_outside_approval--;
                                              total_pending_request--;
                                            });
                                            Navigator.of(context).pop();
                                          } else {
                                            await FirebaseFirestore.instance
                                                .collection('id')
                                                .doc(_requester_id)
                                                .collection(
                                                    'attendance archive')
                                                .doc(_request_year)
                                                .collection(_request_month)
                                                .doc(
                                                    '${_request_timestamp.toDate()}')
                                                .update({
                                              'attendance status': 'Approved',
                                            });
                                            var attendance_reference =
                                                FirebaseFirestore.instance
                                                    .collection('id')
                                                    .doc(_requester_id)
                                                    .collection('report')
                                                    .doc('attendance report')
                                                    .collection(_request_year)
                                                    .doc(_request_month);
                                            attendance_reference
                                                .get()
                                                .then((value) => {
                                                      if (value.exists)
                                                        {
                                                          attendance_reference
                                                              .update({
                                                            'present':
                                                                FieldValue
                                                                    .increment(
                                                                        1),
                                                          })
                                                        }
                                                      else
                                                        {
                                                          attendance_reference
                                                              .set({
                                                            'present': 1,
                                                            'late': 0,
                                                            'absent': 0,
                                                            'holiday': 0,
                                                            'tour': 0,
                                                            'leave': 0,
                                                            'month': DateFormat
                                                                    .M('en_US')
                                                                .format(
                                                                    _request_timestamp
                                                                        .toDate())
                                                          }),
                                                        },
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              'Attendance request accepted')
                                                    });
                                            FirebaseFirestore.instance
                                                .collection('id')
                                                .doc(emp_id)
                                                .collection(
                                                    'outside office approval')
                                                .doc(
                                                    '$_request_doc_id $_requester_id')
                                                .delete();
                                            setState(() {
                                              pending_request_in_outside_approval--;
                                              total_pending_request--;
                                            });
                                            Navigator.of(context).pop();
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
                          Text('Remarks: ${data['description']}')
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
