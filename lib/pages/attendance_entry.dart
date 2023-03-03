import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/main.dart';
import 'package:san_group/pages/my_information.dart';

class attendance_entry extends StatefulWidget {
  const attendance_entry({super.key});

  @override
  State<attendance_entry> createState() => _attendance_entryState();
}

class _attendance_entryState extends State<attendance_entry> {
  var _show_date = DateFormat.yMMMMd('en_US').format(DateTime.now());

  double distance = 0;
  double office_latitude = 23.7261;
  double office_longitude = 90.422401;
  double current_latitude = 23.7261;
  double curretn_longitude = 90.422401;
  Position? _current_position;
  String _current_id = 'Id';
  bool _is_loading = false;
  String _approver_id = 'id';
  DateTime? _suspension_date;
  Timestamp _timestamp = Timestamp.now();
  int year = 2000;
  int _current_year = -1;
  int _current_month = -1;
  int _current_day = -1;
  String month = 'January';
  int hour = 0;
  int minute = 0;
  int _suspension_year = 0;
  int _suspension_month = 0;
  int _suspension_day_of_month = 0;

  TextEditingController _description_controller = TextEditingController();

  final List<String> dropdown_list = [
    'Inside Office',
    'Outside Office',
  ];
  String? _location_value;
  List<Placemark> placemarks = [];
  var show_distance = '0';
  DateTime _date = DateTime.now();
  String? locality;
  String? subLocality;
  String _my_image = '';

// initialize page
  @override
  void initState() {
    call_in_initstate();
    // setState(() {
    //   _show_date = DateFormat.yMMMMd('en_US').format(_date);

    //   get_position();
    // });
  }

  void call_in_initstate() async {
    setState(() {
      _is_loading = true;
    });
    super.initState();
    FirebaseFirestore.instance
        .collection('office')
        .doc(brunch)
        .snapshots()
        .listen((event) {
      setState(() {
        office_latitude = double.parse(event['latitude']);
        office_longitude = double.parse(event['longitude']);
      });
    }).onError((e) {
      Fluttertoast.showToast(msg: 'Something went wrong');
      setState(() {
        _is_loading = false;
      });
      Navigator.pushReplacement((this.context),
          MaterialPageRoute(builder: (context) => my_information()));
    });

    await get_position();
    setState(() {
      _is_loading = false;
    });
  }

  Future<Position> determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future get_position() async {
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
          Navigator.pushReplacement((this.context),
              MaterialPageRoute(builder: (context) => my_information()));
        });

    FirebaseFirestore.instance
        .collection('id')
        .doc(emp_id)
        .snapshots()
        .listen((value) {
      setState(() {
        {
          _timestamp = value['check time'];
          _date = _timestamp.toDate();

          _show_date = DateFormat.yMMMMd('en_US').format(_date);
          year = _date.year;
          month = DateFormat.MMMM('en_US').format(_date);
          hour = _date.hour;
          minute = _date.minute;
          _current_day = _date.day;
          _current_month = _date.month;
          _current_year = _date.year;
          //Fluttertoast.showToast(msg: event['check time']);
          _timestamp = value['suspension date'];
          _suspension_date = _timestamp.toDate();
          _suspension_year = _suspension_date!.year;
          _suspension_month = _suspension_date!.month;
          _suspension_day_of_month = _suspension_date!.day;
        }
      });
    });
    // .catchError((e) {
    //   Fluttertoast.showToast(msg: 'Something went wrong');
    //   setState(() {
    //     _is_loading = false;
    //   });
    //   Navigator.pushReplacement((this.context),
    //       MaterialPageRoute(builder: (context) => my_information()));
    // })
    // ;

    _current_position = await determinePosition();
    setState(() {
      current_latitude = _current_position!.latitude;
      curretn_longitude = _current_position!.longitude;
      distance = Geolocator.distanceBetween(current_latitude, curretn_longitude,
          office_latitude, office_longitude);

      show_distance = distance.toStringAsFixed(2);
    });
    placemarks =
        await placemarkFromCoordinates(office_latitude, office_longitude);

    setState(() {
      locality = placemarks[0].locality;

      subLocality = placemarks[0].subLocality;
      _is_loading = false;
    });
  }

  void submit_attandance() async {
    await get_position();
    if (hour < 9 && minute < 45) {
      Fluttertoast.showToast(
          msg: "It's too early to give attendance for today");
    } else if (hour < 10 && minute < 20) {
      if (distance > 30) {
        Fluttertoast.showToast(
            msg: 'Please be within 30 Meter from your office');
      } else {
        var attendance_reference = FirebaseFirestore.instance
            .collection('id')
            .doc(emp_id)
            .collection('report')
            .doc('attendance report')
            .collection('$year')
            .doc(month);
        await attendance_reference.get().then((value) => {
              if (value.exists)
                {
                  attendance_reference.update({
                    'present': FieldValue.increment(1),
                  })
                }
              else
                {
                  attendance_reference.set({
                    'present': 1,
                    'late': 0,
                    'absent': 0,
                    'holiday': 0,
                    'tour': 0,
                    'leave': 0,
                    'month': DateFormat.M('en_US').format(_date)
                  }),
                },
              FirebaseFirestore.instance.collection('id').doc(emp_id).update({
                'suspension date': _date,
              }).then(
                (value) async {
                  await FirebaseFirestore.instance
                      .collection('id')
                      .doc(emp_id)
                      .collection('attendance archive')
                      .doc(DateFormat.y('en_US').format(DateTime.now()))
                      .collection(
                          DateFormat.MMMM('en_US').format(DateTime.now()))
                      .doc('$_date')
                      .set({
                    'time': _date,
                    'attendance location': 'Inside Office'
                  });

                  Fluttertoast.showToast(msg: 'Attendance is added for today');
                },
              ).catchError((e) {
                Fluttertoast.showToast(msg: 'Something went wrong');
                setState(() {
                  _is_loading = false;
                });
                Navigator.pushReplacement((this.context),
                    MaterialPageRoute(builder: (context) => my_information()));
              }),
            });
        setState(() {
          _is_loading = false;
        });
        Navigator.pushReplacement((this.context),
            MaterialPageRoute(builder: (context) => my_information()));
      }
    } else if (hour < 11) {
      if (distance > 30) {
        Fluttertoast.showToast(
            msg: 'Please be within 30 Meter from your office');
      } else {
        var attendance_reference = FirebaseFirestore.instance
            .collection('id')
            .doc(emp_id)
            .collection('report')
            .doc('attendance report')
            .collection('$year')
            .doc(month);
        await attendance_reference.get().then((value) => {
              if (value.exists)
                {
                  attendance_reference.update({
                    'late': FieldValue.increment(1),
                  })
                }
              else
                {
                  attendance_reference.set({
                    'late': 1,
                    'present': 0,
                    'absent': 0,
                    'holiday': 0,
                    'tour': 0,
                    'leave': 0,
                    'month': DateFormat.M('en_US').format(_date)
                  }),
                },
              FirebaseFirestore.instance.collection('id').doc(emp_id).update({
                'suspension date': _date,
              }).then((value) async {
                await FirebaseFirestore.instance
                    .collection('id')
                    .doc(emp_id)
                    .collection('attendance archive')
                    .doc(DateFormat.y('en_US').format(DateTime.now()))
                    .collection(DateFormat.MMMM('en_US').format(DateTime.now()))
                    .doc('$_date')
                    .set({
                  'time': _date,
                  'attendance location': 'Inside Office',
                  'attendance status': 'Late'
                });
                Fluttertoast.showToast(msg: 'Attendance is added as late');
              }).catchError((e) {
                Fluttertoast.showToast(msg: 'Something went wrong');
                setState(() {
                  _is_loading = false;
                });
                Navigator.pushReplacement((this.context),
                    MaterialPageRoute(builder: (context) => my_information()));
              }),
            });
        setState(() {
          _is_loading = false;
        });
        Navigator.pushReplacement((this.context),
            MaterialPageRoute(builder: (context) => my_information()));
      }
    } else {
      Fluttertoast.showToast(msg: 'You are too late to give attendance');
    }
    Navigator.pushReplacement(
        (context), MaterialPageRoute(builder: (context) => my_information()));
  }

  void submit_outside_office_approve_request() async {
    FirebaseFirestore.instance
        .collection('id')
        .doc(emp_id)
        .snapshots()
        .listen((event) {
      setState(() {
        _approver_id = event['attendance approver'];
        _my_image = event['image'];
      });
    }).onError((e) {
      Fluttertoast.showToast(msg: 'Something went wrong');
      setState(() {
        _is_loading = false;
      });
      Navigator.pushReplacement((this.context),
          MaterialPageRoute(builder: (context) => my_information()));
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title:
                const Center(child: Text('Request for outside office entry')),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                        minLines: 4,
                        maxLines: 5,
                        autofocus: false,
                        controller: _description_controller,
                        keyboardType: TextInputType.name,
                        onSaved: (value) {
                          _description_controller.text = value!;
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
                        ))
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: const Text("Submit"),
                  onPressed: () async {
                    setState(() {
                      _is_loading = true;
                    });
                    Navigator.of(context).pop();

                    await FirebaseFirestore.instance
                        .collection('id')
                        .doc(_approver_id)
                        .collection('outside office approval')
                        .doc('$_show_date $emp_id')
                        .set({
                          'description': _description_controller.text,
                          'emp id': emp_id,
                          'image': _my_image,
                          'time': _date,
                          'name': name,
                          'post': post,
                        })
                        .then((value) async {
                          await FirebaseFirestore.instance
                              .collection('id')
                              .doc(emp_id)
                              .collection('attendance archive')
                              .doc(DateFormat.y('en_US').format(DateTime.now()))
                              .collection(DateFormat.MMMM('en_US')
                                  .format(DateTime.now()))
                              .doc('$_date')
                              .set({
                            'time': _date,
                            'attendance location': 'Outside Office',
                            'attendance status': 'Pending',
                          });
                          Fluttertoast.showToast(
                              msg: "Request Added Successfully");
                        })
                        .timeout(const Duration(seconds: 10))
                        .catchError((e) {
                          Fluttertoast.showToast(msg: 'Something went wrong');
                          setState(() {
                            _is_loading = false;
                          });
                          Navigator.pushReplacement(
                              (this.context),
                              MaterialPageRoute(
                                  builder: (context) => my_information()));
                        });
                    await FirebaseFirestore.instance
                        .collection('id')
                        .doc(emp_id)
                        .update({
                      'suspension date': _date,
                    });
                    setState(() {
                      _is_loading = false;
                    });
                    Navigator.pushReplacement(
                        (this.context),
                        MaterialPageRoute(
                            builder: (context) => my_information()));

                    _description_controller.clear();
                  })
            ],
          );
        });
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
              title: const Text('Attendance In/Out',
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
                    const SizedBox(
                      height: 20,
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
                        _show_date,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      //height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.black45,
                            //width: 5,
                          )),
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance: $show_distance Meter',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: (distance > 30)
                                    ? Colors.red
                                    : Colors.black45),
                          ),
                          const Divider(
                            height: 10,
                            thickness: 2,
                          ),
                          Text(
                            'Office Latitude\t\t\t\t: ${office_latitude.toStringAsFixed(8)}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black45),
                          ),
                          Text(
                            'Office Longitude\t: ${office_longitude.toStringAsFixed(8)}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black45),
                          ),
                          Text(
                            '$subLocality, $locality ',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField2(
                        decoration: InputDecoration(
                          //Add isDense true and zero Padding.
                          //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        isExpanded: true,
                        hint: const Text(
                          'Select Location',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        iconSize: 30,
                        buttonHeight: 60,
                        buttonPadding:
                            const EdgeInsets.only(left: 20, right: 10),
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        items: dropdown_list
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          _location_value = value.toString();
                        },
                        onSaved: (value) {
                          _location_value = value.toString();
                        }),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('information')
                            .doc('holiday')
                            .collection(DateFormat.yMMMM('en_US').format(_date))
                            .doc(DateFormat.MMMMd('en_US').format(_date))
                            .get()
                            .then((value) {
                          if (value.exists) {
                            Fluttertoast.showToast(msg: 'Today is a holiday');
                          } else {
                            if ((_suspension_date == null) ||
                                (_current_day > _suspension_day_of_month) ||
                                (_current_month > _suspension_month) ||
                                (_current_year > _suspension_year)) {
                              if (_location_value == 'Inside Office') {
                                submit_attandance();
                              } else if (_location_value == 'Outside Office') {
                                submit_outside_office_approve_request();
                              } else {
                                Fluttertoast.showToast(
                                    msg: 'Please select your location');
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      'You are not allowed to request till\n${DateFormat.yMMMMd('en_US').format(_suspension_date!)}');
                            }
                          }
                        });
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
            ));
  }
}
