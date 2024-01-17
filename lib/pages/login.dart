import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:san_group/component/progressbar.dart';
import 'package:san_group/main.dart';
import 'package:san_group/pages/my_information.dart';
import 'package:san_group/pages/recoverpassword.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // our form key
  final _formKey = GlobalKey<FormState>();
  // editing Controller
  final _idEditingController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    initialize();
    super.initState();
  }

  void initialize() async {
    setState(() {
      _is_loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var mail = await prefs.getString('email');
    var pass = await prefs.getString('password');
    emp_id = await prefs.getString('emp_id');
    if (mail != null) {
      try {
        deviceId = await PlatformDeviceId.getDeviceId;
        await FirebaseFirestore.instance
            .collection('id')
            .doc(emp_id)
            .get()
            .then((value) {
          setState(() {
            name = value['name'];
            post = value['post'];
            email = value['email'];
            android_id = value['android id'];
          });
        });
        if (android_id != deviceId) {
          setState(() {
            _is_loading = false;
          });
        } else {
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: '$mail', password: '$pass')
              .then((uid) async => {
                    await FirebaseFirestore.instance
                        .collection('id')
                        .doc(emp_id)
                        .get()
                        .then((value) {
                      setState(() {
                        name = value['name'];
                        post = value['post'];
                      });
                    }),
                    await SharedPreferences.getInstance().then((prefs) {
                      prefs.setString('email', email!);
                      prefs.setString('emp_id', emp_id!);
                      prefs.setString('post', post!);
                      prefs.setString('password', password!);
                    }),
                    setState(() {
                      _is_loading = false;
                    }),
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => my_information()),
                        (Route<dynamic> route) => false),
                  });
        }
      } on FirebaseAuthException catch (error) {
        Fluttertoast.showToast(msg: errorMessage!);
        setState(() {
          _is_loading = false;
        });
      } catch (e) {
        setState(() {
          _is_loading = false;
        });
      }
    } else {
      setState(() {
        _is_loading = false;
      });
    }
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
            ? ProgressBar()
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
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RecoverPassword()));
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 8, 8),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
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

        await FirebaseFirestore.instance
            .collection('id')
            .doc(emp_id)
            .get()
            .then((value) {
          setState(() {
            email = value['email'];
            android_id = value['android id'];
          });
        });
        if (android_id != deviceId) {
          Fluttertoast.showToast(
              msg: "You are not authorized to login from this device");
          setState(() {
            _is_loading = false;
          });
        } else {
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: '$email', password: '$password')
              .then((uid) async => {
                    await FirebaseFirestore.instance
                        .collection('id')
                        .doc(emp_id)
                        .get()
                        .then((value) {
                      setState(() {
                        name = value['name'];
                        post = value['post'];
                      });
                    }),
                    await SharedPreferences.getInstance().then((prefs) {
                      prefs.setString('email', email!);
                      prefs.setString('emp_id', emp_id!);
                      prefs.setString('post', post!);
                      prefs.setString('password', password!);
                    }),
                    Fluttertoast.showToast(msg: "Login Successful"),
                    setState(() {
                      _is_loading = false;
                    }),
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => my_information()),
                        (Route<dynamic> route) => false),
                  });
        }
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
