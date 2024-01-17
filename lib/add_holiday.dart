import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/pages/my_information.dart';

class add_holiday extends StatefulWidget {
  const add_holiday({super.key});

  @override
  State<add_holiday> createState() => _add_holidayState();
}

class _add_holidayState extends State<add_holiday> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Add a new holiday',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      drawer: home_drawer(),
      body: add_holiday_widget(),
    );
  }
}

class add_holiday_widget extends StatefulWidget {
  const add_holiday_widget({super.key});

  @override
  State<add_holiday_widget> createState() => _add_holiday_widgetState();
}

class _add_holiday_widgetState extends State<add_holiday_widget> {
  DateTime? _pick_date;
  bool _is_add_holiday_loading = false;
  var _show_in_pick_date = 'Pick a date';
  TextEditingController _holiday_cause_controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return (_is_add_holiday_loading == true)
        ? Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
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
                                  _pick_date = value;
                                  _show_in_pick_date =
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
                              _show_in_pick_date,
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
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        minLines: 4,
                        maxLines: 5,
                        autofocus: false,
                        controller: _holiday_cause_controller,
                        keyboardType: TextInputType.name,
                        onSaved: (value) {
                          _holiday_cause_controller.text = value!;
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
                          hintText: "Reason of holiday",
                          hintStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black45),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    TextButton(
                        onPressed: () async {
                          if (_pick_date == null) {
                            Fluttertoast.showToast(
                                msg: 'Please pick a date to add');
                          } else if (_holiday_cause_controller.text == '' ||
                              _holiday_cause_controller.text == ' ') {
                            Fluttertoast.showToast(
                                msg: 'Please write a reason');
                          } else {
                            setState(() {
                              _is_add_holiday_loading = true;
                            });
                            Navigator.pushReplacement(
                                (this.context),
                                MaterialPageRoute(
                                    builder: (context) => my_information()));

                            await FirebaseFirestore.instance
                                .collection('information')
                                .doc('holiday')
                                .collection(DateFormat.yMMMM('en_US')
                                    .format(_pick_date!))
                                .doc(DateFormat.MMMMd('en_US')
                                    .format(_pick_date!))
                                .set({
                              'time': _pick_date,
                              'reason': _holiday_cause_controller.text
                            }).then((value) async {
                              await FirebaseFirestore.instance
                                  .collection('id')
                                  .get()
                                  .then((value) {
                                value.docs.forEach(
                                  (element) async {
                                    var docRef = FirebaseFirestore.instance
                                        .collection('id')
                                        .doc(element.id)
                                        .collection('report')
                                        .doc('attendance report')
                                        .collection(DateFormat.y('en_US')
                                            .format(DateTime.now()))
                                        .doc(DateFormat.MMMM('en_US')
                                            .format(DateTime.now()));

                                    await docRef.get().then((value) async {
                                      if (value.exists) {
                                        docRef.update({
                                          'holiday': FieldValue.increment(1),
                                        });
                                      } else {
                                        docRef.set({
                                          'present': 0,
                                          'late': 0,
                                          'absent': 0,
                                          'holiday': 1,
                                          'tour': 0,
                                          'leave': 0,
                                        });
                                      }
                                    });
                                  },
                                );
                              });
                              Fluttertoast.showToast(
                                  msg: 'Holiday added successfully');
                              setState(() {
                                _is_add_holiday_loading = false;
                              });
                            });

                            _holiday_cause_controller.clear();
                          }
                        },
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontStyle: FontStyle.italic),
                        ))
                  ],
                ),
              ),
            ),
          );
  }
}
