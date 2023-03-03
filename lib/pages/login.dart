import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/main.dart';
import 'package:san_group/pages/my_information.dart';
import 'package:san_group/pages/otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mac_address/mac_address.dart';

String android_id = '0';
String? deviceId;
bool _pressed = false;

class login extends StatefulWidget {
  const login({super.key});
  static String firebase_generated_code = '';
  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  bool _is_loading = false;
  var errorMessage;
  bool obsecure_text = true;
  String _platformVersion = 'Unknown';
  // our form key
  final _formKey = GlobalKey<FormState>();
  // editing Controller
  final _idEditingController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GetMac.macAddress;
    } on PlatformException {
      platformVersion = 'Failed to get Device MAC Address.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
//employee id field
    final _employee_id = TextFormField(
        autofocus: false,
        controller: _idEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = RegExp('^SG-[0-9]{5}');
          if (value!.isEmpty) {
            return ("Please Enter Employee Id");
          }
          if (!regex.hasMatch(value)) {
            return ("Employee Id format is incorrect");
          }
          return null;
        },
        onSaved: (value) {
          _idEditingController.text = value!;
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
          hintText: "Employee Id",
          hintStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black45),
            borderRadius: BorderRadius.circular(15),
          ),
        ));

    // password field
    final _password = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: obsecure_text,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Password is required for login");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid Password(Min. 6 Character)");
        }
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
      cursorColor: Colors.black45,
      decoration: InputDecoration(
        suffixIcon: IconButton(
            color: Colors.grey,
            onPressed: () {
              setState(() {
                obsecure_text = !obsecure_text;
                _pressed = !_pressed;
              });
            },
            icon: (_pressed == false)
                ? const Icon(
                    Icons.remove_red_eye,
                  )
                : const Icon(
                    Icons.visibility_off,
                  )),
        focusColor: Colors.black45,
        iconColor: Colors.black45,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black)),
        prefixIcon: const Icon(
          Icons.vpn_key,
          color: Colors.black45,
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        hintText: "Password",
        hintStyle: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black45),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );

    // Log in button
    final _loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blueGrey,
      child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            setState(() {
              email = _idEditingController.text.toLowerCase();
              email = '$email' + '@sangroup.com';
              password = passwordController.text;
              emp_id = _idEditingController.text;
            });

            signin();
          },
          child: const Text(
            "Log In",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      body: Center(
        child: _is_loading == true
            ? Visibility(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Container(
                  // color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onLongPress: () async {
                              try {
                                deviceId = await PlatformDeviceId.getDeviceId;
                              } on PlatformException {
                                deviceId = 'Failed to get deviceId';
                              }
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text("Device Id"),
                                  content: Text("$deviceId"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: Text("Ok"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 100,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: Image.asset('images/san_group.jpg'),
                                  ),
                                )),
                          ),
                          SizedBox(height: 45),
                          _employee_id,
                          SizedBox(height: 20),
                          _password,
                          SizedBox(height: 20),
                          _loginButton,
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

  void signin() async {
    if (_formKey.currentState!.validate()) {
      try {
        deviceId = await PlatformDeviceId.getDeviceId;
      } on PlatformException {
        deviceId = 'Failed to get deviceId.';
        Fluttertoast.showToast(msg: "Failed to get deviceId");
      }
      try {
        setState(() {
          _is_loading = true;
        });
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: '$email', password: '$password')
            .then((uid) async => {
                  await FirebaseFirestore.instance
                      .collection('id')
                      .doc(emp_id)
                      .get()
                      .then((value) {
                    setState(() {
                      name = value['name'];
                      post = value['post'];
                      android_id = value['android id'];
                    });
                  }),
                  if (deviceId == android_id)
                    {
                      Authcontrol.AutoLogin(emp_id,
                          "done"), // used to keep users logged in after re-openning the app
                      Fluttertoast.showToast(msg: "Login Successful"),
                      // Navigator.of(context).pop(),

                      setState(() {
                        _is_loading = false;
                      }),

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => my_information()),
                          (Route<dynamic> route) => false),
                    }
                  else
                    {
                      setState(() {
                        _is_loading = false;
                      }),
                      Fluttertoast.showToast(
                          msg:
                              "User $emp_id is not allowed to log in using this mobile"),
                      FirebaseAuth.instance.signOut(),
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const login())),
                    }
                });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your id appears to be malformed.";

            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this id doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this id has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        setState(() {
          _is_loading = false;
        });
      }
    }
  }
}

class Authcontrol {
  // this is used to keep users signed in when app reopens after it closes
  static AutoLogin(emp_id, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('emp_id', emp_id);
    prefs.setString('complete', value);
  }
}
