import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/pages/employee_list.dart';
import 'package:san_group/pages/my_information.dart';

List<String> post_list = ['HR', 'GM', 'Zonal Head', 'Executive'];

class edit_employee_info extends StatefulWidget {
  const edit_employee_info({Key? key}) : super(key: key);

  @override
  State<edit_employee_info> createState() => _edit_employee_infoState();
}

class _edit_employee_infoState extends State<edit_employee_info> {
  String _employee_id = 'SG-XXXXX';
  int total_employee = 0;
  bool _isloading = false;

  List<String> _office_list = [];
  List<String> _employee_list = [];

  String? _office_value;
  String? _attendance_approver_value;
  String? _post_value;
  final _password = 123456;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    edit_office_name();
    edit_attendance_approver_name();
  }

  String button_text = 'Pick an image';

  final _auth = FirebaseAuth.instance;

  var _image;
  var file_name;
  final image_picker = ImagePicker();
  String? download_url;

  Future pick_image() async {
    var pick = await image_picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pick != null) {
        _image = File(pick!.path);
        setState(() {
          button_text = 'Image selected';
        });
      } else {
        pick = null;
        _image = null;
        Fluttertoast.showToast(msg: 'Please select an image');
        setState(() {
          button_text = 'Select an image';
        });
      }
    });
  }

  Future upload_image() async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('employee/$editing_employee_id ${nameEditingController.text}');
    await ref.putFile(_image!);
    download_url = await ref.getDownloadURL();
  }

  Future<void> edit_office_name() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('office').get();

    // Get data from docs and convert map to List
    setState(() {
      _office_list = querySnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> edit_attendance_approver_name() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('id').get();

    // Get data from docs and convert map to List
    setState(() {
      _employee_list = querySnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // string for displaying the error Message
  String? errorMessage;

  // our form key
  final _formKey = GlobalKey<FormState>();
  // editing Controller
  final nameEditingController = TextEditingController();
  final mobileEditingController = TextEditingController();
  final android_id_EditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //first name field
    final firstNameField = TextFormField(
        autofocus: false,
        controller: nameEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Name cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid name(Min. 3 Character)");
          }
          return null;
        },
        onSaved: (value) {
          nameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
        cursorColor: Colors.black45,
        decoration: InputDecoration(
          focusColor: Colors.black45,
          iconColor: Colors.black45,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.black)),
          prefixIcon: const Icon(
            Icons.account_circle,
            color: Colors.black45,
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          hintText: "Name",
          hintStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black45),
            borderRadius: BorderRadius.circular(15),
          ),
        ));

    // edit android id field
    final _android_id_field = TextFormField(
        autofocus: false,
        controller: android_id_EditingController,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Device id cannot be Empty");
          }

          return null;
        },
        onSaved: (value) {
          android_id_EditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
        cursorColor: Colors.black45,
        decoration: InputDecoration(
          focusColor: Colors.black45,
          iconColor: Colors.black45,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.black)),
          prefixIcon: const Icon(
            Icons.perm_device_info,
            color: Colors.black45,
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          hintText: "Device id",
          hintStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black45),
            borderRadius: BorderRadius.circular(15),
          ),
        ));

    // pick office
    var select_office = DropdownButtonFormField2(
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
          'Select Office',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
        ),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 30,
        buttonHeight: 60,
        buttonPadding: const EdgeInsets.only(left: 20, right: 10),
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        items: _office_list
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
        validator: (value) {
          if (value == null) {
            return 'Please select an office';
          }
        },
        onChanged: (value) {
          _office_value = value.toString();
        },
        onSaved: (value) {
          _office_value = value.toString();
        });

    // select attendance approver
    var attendance_approver = DropdownButtonFormField2(
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
          'Select Attendance Approver',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
        ),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 30,
        buttonHeight: 60,
        buttonPadding: const EdgeInsets.only(left: 20, right: 10),
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        items: _employee_list
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
        validator: (value) {
          if (value == null) {
            return 'Please select an attendance approver';
          }
        },
        onChanged: (value) {
          _attendance_approver_value = value.toString();
        },
        onSaved: (value) {
          _attendance_approver_value = value.toString();
        });

    // select a post
    var select_post = DropdownButtonFormField2(
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
          'Select Post',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
        ),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 30,
        buttonHeight: 60,
        buttonPadding: const EdgeInsets.only(left: 20, right: 10),
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        items: post_list
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
        validator: (value) {
          if (value == null) {
            return 'Please select a post';
          }
        },
        onChanged: (value) {
          _post_value = value.toString();
        },
        onSaved: (value) {
          _post_value = value.toString();
        });

// pick image button
    final add_image_button = MaterialButton(
        height: 60,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.black45)),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          pick_image();
        },
        child: Text(
          button_text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20,
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold),
        ));

    // show auto generated id of new employee
    final _auto_id = Container(
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
        editing_employee_id,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
      ),
    );
    //signup button
    final _submit = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blueGrey,
      child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            update_employee(_employee_id.toLowerCase());
          },
          child: Text(
            "Edit Info of $editing_employee_id",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    // mobile field
    final mobile = TextFormField(
        autofocus: false,
        controller: mobileEditingController,
        keyboardType: TextInputType.number,
        validator: (value) {
          RegExp regex = RegExp('^01[0-9]{9}');
          if (value!.isEmpty) {
            return ("Mobile cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid mobile number");
          }
          return null;
        },
        onSaved: (value) {
          mobileEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
        cursorColor: Colors.black45,
        decoration: InputDecoration(
          focusColor: Colors.black45,
          iconColor: Colors.black45,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.black)),
          prefixIcon: const Icon(
            Icons.phone,
            color: Colors.black45,
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          hintText: "Mobile",
          hintStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black45),
            borderRadius: BorderRadius.circular(15),
          ),
        ));

    return (_isloading == true)
        ? const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text("Edit Info of $editing_employee_id"),
              centerTitle: true,
              backgroundColor: Colors.blueGrey,
            ),
            drawer: home_drawer(),
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 100,
                              child: ClipOval(
                                child: SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: _image != null
                                      ? Image.file(
                                          _image,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset('images/san_group.jpg'),
                                ),
                              )),
                          SizedBox(height: 45),
                          firstNameField,
                          SizedBox(height: 20),
                          _auto_id,
                          SizedBox(height: 20),
                          select_office,
                          SizedBox(height: 20),
                          select_post,
                          SizedBox(height: 20),
                          attendance_approver,
                          SizedBox(height: 20),
                          mobile,
                          SizedBox(height: 20),
                          _android_id_field,
                          SizedBox(height: 20),
                          add_image_button,
                          SizedBox(height: 20),
                          _submit,
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  void update_employee(String id) async {
    if (_formKey.currentState!.validate()) {
      if (_image != null) {
        setState(() {
          _isloading = true;
        });

        await FirebaseStorage.instance
            .ref()
            .child('employee/$editing_employee_id $editing_employee_name')
            .delete();
        await upload_image();
        await FirebaseFirestore.instance
            .collection('id')
            .doc(editing_employee_id)
            .update({
          'attendance approver': _attendance_approver_value,
          'image': download_url,
          'name': nameEditingController.text,
          'office': _office_value,
          'post': _post_value,
          'android id': android_id_EditingController.text,
          'mobile': mobileEditingController.text,
        }).catchError((e) {
          Fluttertoast.showToast(msg: e!.message);
        });

        setState(() {
          _image = null;
          _isloading = false;
        });
        Fluttertoast.showToast(msg: 'Employee info updated successfully');
        Navigator.pushAndRemoveUntil(
            (this.context),
            MaterialPageRoute(builder: (context) => my_information()),
            (route) => false);
      } else {
        Fluttertoast.showToast(msg: 'Please select an image');
      }
    }
  }
}
