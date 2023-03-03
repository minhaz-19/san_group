import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/main.dart';
import 'package:san_group/pages/my_information.dart';

class tour_entry extends StatefulWidget {
  const tour_entry({super.key});

  @override
  State<tour_entry> createState() => _tour_entryState();
}

class _tour_entryState extends State<tour_entry> {
  bool _is_loading = false;
  var show_in_starting_date = 'Pick starting date';
  var show_in_ending_date = 'Pick ending date';
  TextEditingController _tour_remarks_controller = TextEditingController();
  DateTime? _starting_date;
  DateTime? _ending_date;
  String _approver_id = '';
  String _my_image = '';
  Timestamp _timestamp = Timestamp.now();
  DateTime _date = DateTime.now();
  String _show_date = '';
  DateTime? _suspension_date = DateTime(1990);
  int _current_year = -1;
  int _current_month = -1;
  int _current_day = -1;
  int _suspension_year = 0;
  int _suspension_month = 0;
  int _suspension_day_of_month = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    set_check_time();
  }

  Future set_check_time() async {
    setState(() {
      _is_loading = true;
    });
    await FirebaseFirestore.instance
        .collection('id')
        .doc(emp_id)
        .update({'check time': FieldValue.serverTimestamp()})
        .timeout(const Duration(seconds: 10))
        .catchError((e) {
          Fluttertoast.showToast(msg: 'Something went wrong');
          setState(() {
            _is_loading = false;
          });
          Navigator.pushReplacement((context),
              MaterialPageRoute(builder: (context) => my_information()));
        });

    FirebaseFirestore.instance
        .collection('id')
        .doc(emp_id)
        .snapshots()
        .listen((event) {
      setState(() {
        _approver_id = event['attendance approver'];
        _my_image = event['image'];
        _timestamp = event['check time'];
        _date = _timestamp.toDate();
        show_in_starting_date = DateFormat.yMMMMd('en_US').format(_date);
        _starting_date = _date;
        _current_day = _date.day;
        _current_month = _date.month;
        _current_year = _date.year;
        _show_date = DateFormat.yMMMMd('en_US').format(_date);
        _timestamp = event['suspension date'];
        _suspension_date = _timestamp.toDate();

        _suspension_year = _suspension_date!.year;
        _suspension_month = _suspension_date!.month;
        _suspension_day_of_month = _suspension_date!.day;
      });
    });

    setState(() {
      _is_loading = false;
    });
  }

  void submit_tour_entry_approve_request() async {
    setState(() {
      _is_loading = true;
    });

    await FirebaseFirestore.instance
        .collection('id')
        .doc(_approver_id)
        .collection('tour approval')
        .doc('$emp_id $_date')
        .set({
      'reason': _tour_remarks_controller.text,
      'emp id': emp_id,
      'image': _my_image,
      'starting date': _starting_date,
      'ending date': _ending_date,
      'name': name,
      'time': _date,
      'post': post,
    }).then((value) {
      FirebaseFirestore.instance.collection('id').doc(emp_id).update({
        'suspension date': _ending_date,
      });
      Fluttertoast.showToast(msg: 'Request added successfully');
    });

    await FirebaseFirestore.instance
        .collection('id')
        .doc(emp_id)
        .collection('report')
        .doc('tour report')
        .collection(DateFormat.y('en_US').format(_date))
        .doc('$_date')
        .set({
      'reason': _tour_remarks_controller.text,
      'request status': 'Pending',
      'starting date': _starting_date,
      'ending date': _ending_date,
      'time': _date,
    });

    _tour_remarks_controller.clear();
    setState(() {
      _is_loading = false;
    });
    Navigator.pushReplacement(
        (context), MaterialPageRoute(builder: (context) => my_information()));
  }

  @override
  Widget build(BuildContext context) {
    return (_is_loading == true)
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blueGrey,
              title: const Text('Tour Entry',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            drawer: home_drawer(),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.black45,
                            //width: 5,
                          )),
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      child: Text(
                        '$emp_id',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45),
                      ),
                    ),
                    const SizedBox(height: 30),
                    MaterialButton(
                        // pick starting date button
                        height: 60,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.black45)),
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        minWidth: MediaQuery.of(context).size.width,
                        onPressed: () {
                          // showDatePicker(
                          //         context: context,
                          //         initialDate: DateTime.now(),
                          //         firstDate: DateTime(2000),
                          //         lastDate: DateTime(2100))
                          //     .then((value) {
                          //   setState(() {
                          //     if (value != null) {
                          //       setState(() {
                          //         _starting_date = value;
                          //         show_in_starting_date =
                          //             DateFormat.yMMMMd('en_US').format(value);
                          //       });
                          //     }
                          //   });
                          // });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              show_in_starting_date,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.black45,
                            )
                          ],
                        )),
                    const SizedBox(height: 30),
                    MaterialButton(
                        // pick ending date button
                        height: 60,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.black45)),
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        minWidth: MediaQuery.of(context).size.width,
                        onPressed: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100))
                              .then((value) {
                            setState(() {
                              if (value != null) {
                                setState(() {
                                  _ending_date = value;
                                  show_in_ending_date =
                                      DateFormat.yMMMMd('en_US').format(value);
                                });
                              }
                            });
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              show_in_ending_date,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.black45,
                            )
                          ],
                        )),
                    const SizedBox(height: 20),
                    TextFormField(
                        minLines: 4,
                        maxLines: 5,
                        autofocus: false,
                        controller: _tour_remarks_controller,
                        keyboardType: TextInputType.name,
                        onSaved: (value) {
                          _tour_remarks_controller.text = value!;
                        },
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45),
                        cursorColor: Colors.black45,
                        decoration: InputDecoration(
                          focusColor: Colors.black45,
                          iconColor: Colors.black45,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.black)),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          hintText: "Write description",
                          hintStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black45),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        )),
                    TextButton(
                      onPressed: () {
                        if (_tour_remarks_controller.text == '') {
                          Fluttertoast.showToast(
                              msg: 'Please enter the remarks');
                        } else if (_starting_date == null) {
                          Fluttertoast.showToast(
                              msg: 'Please select a starting date');
                        } else if (_ending_date == null) {
                          Fluttertoast.showToast(
                              msg: 'Please select an ending date');
                        } else if ((_starting_date!.month != _date.month) ||
                            (_starting_date!.year != _date.year) ||
                            (_ending_date!.month != _date.month) ||
                            (_ending_date!.year != _date.year)) {
                          Fluttertoast.showToast(
                              msg:
                                  'You can not request for tour entry outside this month');
                        } else if (_ending_date!.day < _date.day) {
                          Fluttertoast.showToast(
                              msg:
                                  'Tour ending date can not be less than current date');
                        } else if ((_suspension_date == null) ||
                            (_current_day > _suspension_day_of_month) ||
                            (_current_month > _suspension_month) ||
                            (_current_year > _suspension_year)) {
                          submit_tour_entry_approve_request();
                        } else {
                          Fluttertoast.showToast(
                              msg:
                                  'You are not allowed to request till\n${DateFormat.yMMMMd('en_US').format(_suspension_date!)}');
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
