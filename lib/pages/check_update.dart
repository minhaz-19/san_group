import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:san_group/component/progressbar.dart';
import 'package:san_group/drawer.dart';

int app_version = 1;

class check_update extends StatefulWidget {
  const check_update({super.key});

  @override
  State<check_update> createState() => _check_updateState();
}

class _check_updateState extends State<check_update> {
  bool _is_loading = false;
  int _checked_app_version = 1;
  bool _is_update_checked = false;
  String _show_text = '';

  void _check_update() async {
    setState(() {
      _is_loading = true;
    });
    await FirebaseFirestore.instance
        .collection('information')
        .doc('app version')
        .get()
        .then((value) {
      setState(() {
        _checked_app_version = value['version'];
        _is_update_checked = true;
        if (_checked_app_version == app_version) {
          setState(() {
            _show_text = "Update is not available";
          });
        } else {
          setState(() {
            _show_text = "Update is available";
          });
        }

        _is_loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_is_loading == true)
        ? const Scaffold(
            body: Center(
              child: ProgressBar(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueGrey,
              title: const Text('Check Update',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            drawer: home_drawer(),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_is_update_checked)
                      Text(
                        _show_text,
                        style: TextStyle(fontSize: 20),
                      ),
                    TextButton(
                        onPressed: () {
                          _check_update();
                        },
                        child: Text('Check for update'))
                  ],
                ),
              ),
            ));
  }
}
