import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:san_group/add_holiday.dart';
import 'package:san_group/holiday.dart';
import 'package:san_group/authentication/authentication.dart';
import 'package:san_group/main.dart';
import 'package:san_group/outside_office_approval.dart';
import 'package:san_group/pages/add_new_employee.dart';
import 'package:san_group/pages/attendance_archive.dart';
import 'package:san_group/pages/attendance_entry.dart';
import 'package:san_group/pages/check_update.dart';
import 'package:san_group/pages/employee_list.dart';
import 'package:san_group/pages/leave_entry.dart';
import 'package:san_group/pages/leave_report.dart';
import 'package:san_group/pages/login.dart';
import 'package:san_group/pages/my_information.dart';
import 'package:san_group/pages/my_team.dart';
import 'package:san_group/pages/office_list.dart';
import 'package:san_group/pages/privacy_policy.dart';
import 'package:san_group/pages/tour_entry.dart';
import 'package:san_group/pages/tour_report.dart';
import 'package:shared_preferences/shared_preferences.dart';

class home_drawer extends StatefulWidget {
  const home_drawer({super.key});

  @override
  State<home_drawer> createState() => _home_drawerState();
}

class _home_drawerState extends State<home_drawer> {
  bool expanded1 = false,
      expanded2 = false,
      expanded3 = false,
      expanded4 = false,
      expanded5 = false;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            show_description(),
            ExpansionPanelList(
              children: [
                ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return GestureDetector(
                        onTap: (() {
                          setState(() {
                            expanded1 = !expanded1;
                          });
                        }),
                        child: ListTile(
                          leading: badges.Badge(
                            child: Icon(Icons.people),
                            badgeContent: Text('$total_pending_request'),
                            showBadge:
                                (total_pending_request > 0) ? true : false,
                          ),
                          title: Text('My Profile'),
                        ),
                      );
                    },
                    isExpanded: expanded1,
                    body: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.check),
                            title: Text('My Information'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) => my_information()));
                            },
                          ),
                          ListTile(
                            leading: badges.Badge(
                              child: Icon(Icons.check),
                              badgeContent: Text('$total_pending_request'),
                              showBadge:
                                  (total_pending_request > 0) ? true : false,
                            ),
                            title: Text('My Team'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) => my_team()));
                            },
                          ),
                        ],
                      ),
                    ))
              ],
              expansionCallback: (int item, bool status) {
                setState(() {
                  expanded1 = !expanded1;
                });
              },
            ),
            if (post == 'HR' || post == 'CEO')
              ExpansionPanelList(
                children: [
                  ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              expanded2 = !expanded2;
                            });
                          },
                          child: const ListTile(
                            leading: Icon(Icons.manage_accounts),
                            title: Text('Manage'),
                          ),
                        );
                      },
                      isExpanded: expanded2,
                      body: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.check),
                              title: Text('Office List'),
                              onTap: () {
                                Navigator.pushReplacement(
                                    (this.context),
                                    MaterialPageRoute(
                                        builder: (context) => office_list()));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.check),
                              title: Text('Employee List'),
                              onTap: () {
                                Navigator.pushReplacement(
                                    (this.context),
                                    MaterialPageRoute(
                                        builder: (context) => employee_list()));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.check),
                              title: Text('Add New Holiday'),
                              onTap: () {
                                Navigator.pushReplacement(
                                    (this.context),
                                    MaterialPageRoute(
                                        builder: (context) => add_holiday()));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.check),
                              title: Text('Add New Employee'),
                              onTap: () {
                                Navigator.pushReplacement(
                                    (this.context),
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            add_new_employee()));
                              },
                            ),
                          ],
                        ),
                      ))
                ],
                expansionCallback: (int item, bool status) {
                  setState(() {
                    expanded2 = !expanded2;
                  });
                },
              ),
            ExpansionPanelList(
              children: [
                ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            expanded3 = !expanded3;
                          });
                        },
                        child: const ListTile(
                          leading: Icon(Icons.add_box),
                          title: Text('Entry Panel'),
                        ),
                      );
                    },
                    isExpanded: expanded3,
                    body: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.check),
                            title: Text('Attendance Entry'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          attendance_entry()));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.check),
                            title: Text('Tour Entry'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) => tour_entry()));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.check),
                            title: Text('Leave Entry'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) => leave_entry()));
                            },
                          ),
                        ],
                      ),
                    ))
              ],
              expansionCallback: (int item, bool status) {
                setState(() {
                  expanded3 = !expanded3;
                });
              },
            ),
            ExpansionPanelList(
              children: [
                ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            expanded4 = !expanded4;
                          });
                        },
                        child: ListTile(
                          leading: Icon(Icons.calendar_month),
                          title: Text('Report Panel'),
                        ),
                      );
                    },
                    isExpanded: expanded4,
                    body: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.check),
                            title: Text('Attendance Archive'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          attendance_archive()));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.check),
                            title: Text('Tour Report'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) => tour_report()));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.check),
                            title: Text('Leave Report'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) => leave_report()));
                            },
                          ),
                        ],
                      ),
                    ))
              ],
              expansionCallback: (int item, bool status) {
                setState(() {
                  expanded4 = !expanded4;
                });
              },
            ),
            ExpansionPanelList(
              children: [
                ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            expanded5 = !expanded5;
                          });
                        },
                        child: ListTile(
                          leading: Icon(Icons.info),
                          title: Text('More Info'),
                        ),
                      );
                    },
                    isExpanded: expanded5,
                    body: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.tour),
                            title: Text('Holidays'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) => holiday()));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.update),
                            title: Text('Check Update'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) => check_update()));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.privacy_tip),
                            title: Text('Privacy Policy'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  (this.context),
                                  MaterialPageRoute(
                                      builder: (context) => privacy_policy()));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.logout),
                            title: Text('Logout'),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title:
                                          const Center(child: Text('Log Out')),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          children: <Widget>[
                                            const Text(
                                              'Do you want to log out?',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    'No',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context)
                                                        .pushAndRemoveUntil(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        login()),
                                                            (Route<dynamic>
                                                                    route) =>
                                                                false);
                                                    await FirebaseAuth.instance
                                                        .signOut();
                                                    setState(() {
                                                      emp_id = null;

                                                      name = null;
                                                      image = null;
                                                      password = null;
                                                      post = null;
                                                    });
                                                    Fluttertoast.showToast(
                                                        msg: 'Signed Out');
                                                    SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();

                                                    prefs.remove('emp_id');
                                                    prefs.remove('complete');
                                                  },
                                                  child: const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ),
                        ],
                      ),
                    ))
              ],
              expansionCallback: (int item, bool status) {
                setState(() {
                  expanded5 = !expanded5;
                });
              },
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}

class show_description extends StatefulWidget {
  const show_description({super.key});

  @override
  State<show_description> createState() => _show_descriptionState();
}

class _show_descriptionState extends State<show_description> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.blueGrey,
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
          ),
          drawer_image,
          SizedBox(
            height: 10,
          ),
          Text(
            '$name',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            '$post',
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: 14,
            ),
          ),
        ],
      )),
    );
  }
}
