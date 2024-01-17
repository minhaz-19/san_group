import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:san_group/component/progressbar.dart';
import 'package:san_group/pages/my_information.dart';

class add_new_office extends StatefulWidget {
  const add_new_office({super.key});

  @override
  State<add_new_office> createState() => _add_new_officeState();
}

class _add_new_officeState extends State<add_new_office> {
  bool _is_loading = false;
  bool _has_got_location = false;
  String _show_latitude = '', _show_longitude = '';
  var _current_latitude;
  var _current_longitude;
  Position? _current_position;
  final _office_name_controller = TextEditingController();
  String? _locality;
  String? _subLocality;
  List<Placemark> placemarks = [];

  Future<Position> _determinePosition() async {
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

  void _get_location() async {
    setState(() {
      _is_loading = true;
    });
    _current_position = await _determinePosition();
    setState(() {
      _current_latitude = _current_position!.latitude;
      _current_longitude = _current_position!.longitude;

      _show_latitude = _current_latitude.toStringAsFixed(5);
      _show_longitude = _current_longitude.toStringAsFixed(5);
    });
    placemarks =
        await placemarkFromCoordinates(_current_latitude, _current_longitude);

    setState(() {
      _locality = placemarks[0].locality;

      _subLocality = placemarks[0].subLocality;
      _has_got_location = true;
      _is_loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_is_loading == true)
        ? const Scaffold(
            body: ProgressBar(),
          )
        : Scaffold(
            appBar: AppBar(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueGrey,
              title: const Text('Add New Office',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                        autofocus: false,
                        controller: _office_name_controller,
                        keyboardType: TextInputType.name,
                        onSaved: (value) {
                          _office_name_controller.text = value!;
                        },
                        textInputAction: TextInputAction.next,
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
                          prefixIcon: const Icon(
                            Icons.near_me,
                            color: Colors.black45,
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          hintText: "Enter office name",
                          hintStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black45),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        )),
                    if (_has_got_location)
                      const SizedBox(
                        height: 20,
                      ),
                    if (_has_got_location)
                      Container(
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
                              "Office Latitude: $_show_latitude",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45),
                            ),
                            Text(
                              "Office Longitude: $_show_longitude",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45),
                            ),
                            Text(
                              '$_subLocality',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45),
                            ),
                            Text(
                              "$_locality",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45),
                            )
                          ],
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.blueGrey,
                      child: MaterialButton(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          minWidth: MediaQuery.of(context).size.width,
                          onPressed: () {
                            _get_location();
                          },
                          child: const Text(
                            "Get office location",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextButton(
                        onPressed: () async {
                          if (_office_name_controller.text == '' ||
                              _office_name_controller.text == ' ') {
                            Fluttertoast.showToast(
                                msg: 'Please enter the office name');
                          } else {
                            if (_has_got_location == false) {
                              Fluttertoast.showToast(
                                  msg: 'Please get office location');
                            } else {
                              setState(() {
                                _is_loading = true;
                              });
                              await FirebaseFirestore.instance
                                  .collection('office')
                                  .doc(_office_name_controller.text)
                                  .set({
                                'latitude': _current_latitude.toString(),
                                'longitude': _current_longitude.toString(),
                                'office name': _office_name_controller.text,
                              });
                              Fluttertoast.showToast(
                                  msg:
                                      '${_office_name_controller.text} Office added successfully');
                              setState(() {
                                _is_loading = false;
                              });
                              Navigator.pushAndRemoveUntil(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) => my_information()),
                                  (route) => false);
                            }
                          }
                        },
                        child: Text(
                          'Add new office',
                          style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey),
                        ))
                  ],
                ),
              ),
            ));
  }
}
