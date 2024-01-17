
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:san_group/main.dart';
import 'package:san_group/pages/edit_employee_info.dart';
import 'package:san_group/pages/employee_list.dart';
import 'package:intl/intl.dart';
import 'package:san_group/pages/my_information.dart';

class employee_info extends StatefulWidget {
  const employee_info({super.key});

  @override
  State<employee_info> createState() => _employee_infoState();
}

class _employee_infoState extends State<employee_info> {
  bool _is_loading = false;
  bool _is_edit_pressed = false;
  var _present;
  var _absent;
  var _late;
  var _holiday;
  var _leave;
  var _tour;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _is_loading = true;
      load_employee_info();
    });
  }

  void load_employee_info() async {
    FirebaseFirestore.instance
        .collection('id')
        .doc(editing_employee_id)
        .collection('report')
        .doc('attendance report')
        .collection(DateFormat.y('en_US').format(DateTime.now()))
        .doc(DateFormat.MMMM('en_US').format(DateTime.now()))
        .snapshots()
        .listen((event) {
      setState(() {
        _present = event['present'];
        _absent = event['absent'];
        _late = event['late'];
        _holiday = event['holiday'];
        _leave = event['leave'];
        _tour = event['tour'];
      });
    });

    setState(() {
      _is_loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Information of $editing_employee_id',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            CachedNetworkImage(
              imageUrl: editing_employee_image,
              imageBuilder: (context, imageProvider) => Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Container(
                height: 120.0,
                width: 120.0,
                decoration: BoxDecoration(shape: BoxShape.circle),
                // color: Colors.white,
                child: Image.asset('images/san_group.jpg'),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Name  : $editing_employee_name\nEmp Id  : $editing_employee_id\nPost  : $editing_employee_post\nOffice  : $editing_employee_office\nMobile  : $editing_employee_mobile\nReporting To  : $editing_employee_reporting_to',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Current Month Attendance Status',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Present\t :  $_present",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45),
                      ),
                      Text(
                        "Late\t\t\t\t\t\t\t :  $_late",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45),
                      ),
                      Text(
                        "Absent\t\t :  $_absent",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45),
                      ),
                      Text(
                        "Tour\t\t\t\t\t\t\t :  $_tour",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45),
                      ),
                      Text(
                        "Leave\t\t\t\t\t :  $_leave",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45),
                      ),
                      Text(
                        "Holiday\t\t :  $_holiday",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),

                      //color:

                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                scrollable: true,
                                title: Center(
                                    child: Text(
                                        'Delete $editing_employee_id from database?')),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueGrey,
                                          ),
                                          child: const Text("Yes"),
                                          onPressed: () async {
                                            setState(() {
                                              _is_loading = true;
                                            });
                                            Navigator.of(context).pop();
                                            

                                            await FirebaseFirestore.instance
                                                .collection('id')
                                                .doc(editing_employee_id
                                                    .toUpperCase())
                                                .delete();

                                            await FirebaseStorage.instance
                                                .ref()
                                                .child(
                                                    'employee/${editing_employee_id.toUpperCase()} $editing_employee_name')
                                                .delete();

                                            Fluttertoast.showToast(
                                                msg:
                                                    'Records of $editing_employee_id deleted successfully');
                                            setState(() {
                                              _is_loading = false;
                                            });
                                            Navigator.pushAndRemoveUntil(
                                                (this.context),
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        my_information()),
                                                (route) => false);
                                          }),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueGrey,
                                          ),
                                          child: const Text("No"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                    ],
                                  ),
                                ],
                              );
                            });
                      },
                      child: const AutoSizeText(
                        "Delete Employee",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                        minFontSize: 2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () async {
                        Navigator.push(
                            (this.context),
                            MaterialPageRoute(
                                builder: (context) => edit_employee_info()));
                      },
                      child: const AutoSizeText(
                        "Edit Info",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                        minFontSize: 2,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
