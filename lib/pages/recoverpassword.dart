import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:san_group/component/progressbar.dart';
import 'package:san_group/component/widebutton.dart';

class RecoverPassword extends StatefulWidget {
  const RecoverPassword({super.key});

  @override
  State<RecoverPassword> createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  var email;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? const ProgressBar()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      height: 60,
                      child: Image.asset(
                        'images/san_group.jpg',
                        height: MediaQuery.of(context).size.height * 0.4,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 15, 8, 8),
                        child: Text(
                          'Employee ID',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                      cursorColor: Colors.black54,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        hintText: 'Enter your employee id',
                        hintStyle: const TextStyle(
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: Colors.green[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(191, 153, 245, 1),
                            width: 2.0,
                          ),
                        ),
                      ),
                      onSaved: (newValue) {
                        setState(() {
                          // Handle the value if needed
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    WideButton(
                      'Change Password',
                      textColor: Colors.white,
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        if (_emailController.text.isEmpty) {
                          Fluttertoast.showToast(
                            msg: "Please enter your employee id",
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        } else {
                          try {
                            await FirebaseFirestore.instance
                                .collection('id')
                                .doc(_emailController.text.toUpperCase())
                                .get()
                                .then((value) {
                              setState(() {
                                email = value['email'];
                              });
                            });

                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email)
                                .then((value) {
                              Fluttertoast.showToast(
                                  msg:
                                      'A password recover email has been sent to $email');
                            });
                            setState(() {
                              _emailController.clear();
                              _isLoading = false;
                            });
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              Fluttertoast.showToast(msg: 'Email not found');
                            } else if (e.code == 'wrong-password') {
                              Fluttertoast.showToast(
                                  msg: 'ভুল ইমেল বা পাসওয়ার্ড');
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          } on FirebaseException catch (e) {
                            Fluttertoast.showToast(msg: '$e');
                            setState(() {
                              _isLoading = false;
                            });
                          } catch (e) {
                            Fluttertoast.showToast(msg: '$e');
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      backgroundcolor: Theme.of(context).primaryColor,
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
