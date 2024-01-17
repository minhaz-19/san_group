import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:san_group/component/progressbar.dart';
import 'package:san_group/drawer.dart';
import 'package:san_group/main.dart';
import 'package:san_group/pages/ask_to_update.dart';
import 'package:san_group/pages/check_update.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

var total_pending_request = 0;
var pending_request_in_outside_approval = 0;
var pending_request_in_tour_approval = 0;
var pending_request_in_leave_approval = 0;

Widget drawer_image = CachedNetworkImage(
  imageUrl: '$image',
  imageBuilder: (context, imageProvider) => Container(
    width: 120.0,
    height: 120.0,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
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
);

class my_information extends StatefulWidget {
  const my_information({super.key});

  @override
  State<my_information> createState() => _my_informationState();
}

class _my_informationState extends State<my_information> {
  int _checked_app_version = 1;
  int _ask_to_update = 0;
  int _present = 0;
  int _late = 0;
  int _absent = 0;
  int _holiday = 0;
  int _tour = 0;
  int _leave = 0;
  var _get_present = 0;
  var _get_late = 0;
  var _get_absent = 0;
  var _get_holiday = 0;
  var _get_tour = 0;
  var _get_leave = 0;
  String _month_and_date = DateFormat.yMMMM('en_US').format(DateTime.now());
  String _year = DateFormat.y('en_US').format(DateTime.now());
  String _month = DateFormat.MMMM('en_US').format(DateTime.now());
  bool _is_myinfo_loading = false;
  var _total_days_in_current_month = 0;
  DateTime _current_date = DateTime.now();
  Timestamp _current_timestamp = Timestamp.now();

  @override
  void initState() {
    super.initState();
    setState(() {
      _is_myinfo_loading = true;
    });
    FirebaseFirestore.instance
        .collection('id')
        .doc('$emp_id')
        .snapshots()
        .listen(
      (event) {
        setState(() async {
          image = event['image'];
          name = event['name'];
          post = event['post'];
          brunch = event['office'];
          approver_id = event['attendance approver'];
          FirebaseFirestore.instance
              .collection('id')
              .doc(approver_id)
              .snapshots()
              .listen((manage) {
            setState(() {
              approver_mobile = manage['mobile'];
            });
          });
        });
      },
    );

    change_chart_data()
        .timeout(Duration(seconds: 10))
        .onError((error, stackTrace) {
      setState(() {
        _is_myinfo_loading = false;
      });
    });
  }

  Future change_chart_data() async {
    await FirebaseFirestore.instance
        .collection('id')
        .doc(emp_id)
        .get()
        .then((value) {
      setState(() {
        post = value['post'];
      });
    });
    if ((post == 'HR' || post == 'CEO')) {
      await FirebaseFirestore.instance
          .collection('id')
          .doc(emp_id)
          .update({'check time': FieldValue.serverTimestamp()});
      await FirebaseFirestore.instance
          .collection('id')
          .doc(emp_id)
          .get()
          .then((value) {
        setState(() {
          _current_timestamp = value['check time'];
          _current_date = _current_timestamp.toDate();
          _total_days_in_current_month =
              DateTime(_current_date.year, _current_date.month + 1, 0).day;
        });
      });

      if (_current_date.day == _total_days_in_current_month) {
        FirebaseFirestore.instance.collection('id').get().then((value) {
          value.docs.forEach(
            (element) async {
              var _doc_Ref = FirebaseFirestore.instance
                  .collection('id')
                  .doc(element.id)
                  .collection('report')
                  .doc('attendance report')
                  .collection(DateFormat.y('en_US').format(_current_date))
                  .doc(DateFormat.MMMM('en_US').format(_current_date));

              await _doc_Ref.get().then((value) async {
                if (value.exists) {
                  _doc_Ref.update({
                    'absent': _total_days_in_current_month -
                        (value['holiday'] +
                            value['present'] +
                            value['late'] +
                            value['tour'] +
                            value['leave']),
                  });
                } else {
                  _doc_Ref.set({
                    'present': 0,
                    'late': 0,
                    'absent': _total_days_in_current_month,
                    'holiday': 0,
                    'tour': 0,
                    'leave': 0,
                  });
                }
              });
            },
          );
        });
      }
    }
    await FirebaseFirestore.instance
        .collection('id')
        .doc(emp_id)
        .collection('leave approval')
        .get()
        .then((value) {
      setState(() {
        pending_request_in_leave_approval = value.size;
      });
    });

    await FirebaseFirestore.instance
        .collection('id')
        .doc(emp_id)
        .collection('outside office approval')
        .get()
        .then((value) {
      setState(() {
        pending_request_in_outside_approval = value.size;
      });
    });
    await FirebaseFirestore.instance
        .collection('id')
        .doc(emp_id)
        .collection('tour approval')
        .get()
        .then((value) {
      setState(() {
        pending_request_in_tour_approval = value.size;
      });
    });
    setState(() {
      total_pending_request = pending_request_in_leave_approval +
          pending_request_in_outside_approval +
          pending_request_in_tour_approval;
    });
    await FirebaseFirestore.instance
        .collection('information')
        .doc('app version')
        .get()
        .then((value) {
      setState(() {
        _checked_app_version = value['version'];
      });
      if (_checked_app_version != app_version) {
        setState(() {
          _ask_to_update = 1;
        });
      }
    });
    await FirebaseFirestore.instance
        .collection('id')
        .doc(emp_id)
        .collection('report')
        .doc('attendance report')
        .collection(_year)
        .doc(_month)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          _get_present = value['present'];

          _get_late = value['late'];
          _get_absent = value['absent'];
          _get_holiday = value['holiday'];
          _get_tour = value['tour'];
          _get_leave = value['leave'];
          _present = _get_present.toInt();
          _late = _get_late.toInt();
          _absent = _get_absent.toInt();
          _holiday = _get_holiday.toInt();
          _tour = _get_tour.toInt();
          _leave = _get_leave.toInt();

          chartData = [
            ChartData('Present', _present),
            ChartData('Late', _late),
            ChartData('Absent', _absent),
            ChartData('Holiday', _holiday),
            ChartData('Tour', _tour),
            ChartData('Leave', _leave)
          ];
          setState(() {
            _is_myinfo_loading = false;
          });
        });
      } else {
        setState(() {
          _is_myinfo_loading = false;
        });
      }
    });
  }

  List<ChartData> chartData = [
    ChartData('Present', 0),
    ChartData('Late', 0),
    ChartData('Absent', 0),
    ChartData('Holiday', 0),
    ChartData('Tour', 0),
    ChartData('Leave', 0)
  ];
  Widget build(BuildContext context) {
    return (_ask_to_update == 1)
        ? const ask_to_update()
        : (_is_myinfo_loading)
            ? const Scaffold(
                body: Center(
                  child: ProgressBar(),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  foregroundColor: Colors.white,
                  title: const Text(
                    'SAN GROUP',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.blueGrey,
                ),
                drawer: home_drawer(),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SfCartesianChart(
                            title: ChartTitle(
                                text: 'Current Month Attendance Report',
                                borderColor: Colors.blue,
                                borderWidth: 0,
                                // Aligns the chart title to left
                                alignment: ChartAlignment.center,
                                textStyle: const TextStyle(
                                  color: Colors.red,
                                  fontFamily: 'Roboto',
                                  fontStyle: FontStyle.italic,
                                  fontSize: 20,
                                )),
                            primaryXAxis: CategoryAxis(
                                labelStyle: const TextStyle(
                                    color: Colors.black45,
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500)),
                            series: <ChartSeries<ChartData, String>>[
                              // Renders column chart

                              ColumnSeries(
                                  color: Colors.blueGrey,
                                  isVisibleInLegend: true,
                                  dataSource: chartData,
                                  xValueMapper: (ChartData data, _) => data.x,
                                  yValueMapper: (ChartData data, _) => data.y,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  dataLabelSettings: const DataLabelSettings(
                                      // Renders the data label
                                      isVisible: true)),
                            ]),
                        Text(_month_and_date,
                            style: const TextStyle(
                              color: Colors.red,
                              fontFamily: 'Roboto',
                              fontStyle: FontStyle.italic,
                              fontSize: 20,
                            )),
                        const SizedBox(
                          height: 40,
                        ),
                        const Text('Responsible Person',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Roboto',
                              fontStyle: FontStyle.italic,
                              fontSize: 20,
                            )),
                        Table(
                          children: [
                            TableRow(children: [
                              info_table_cell('Type',
                                  const Color.fromARGB(255, 243, 119, 119)),
                              info_table_cell('ID',
                                  const Color.fromARGB(255, 243, 119, 119)),
                              info_table_cell('Mobile',
                                  const Color.fromARGB(255, 243, 119, 119))
                            ]),
                            TableRow(children: [
                              info_table_cell('Attn Approver',
                                  const Color.fromARGB(255, 119, 131, 239)),
                              info_table_cell(approver_id, Colors.black12),
                              info_table_cell(approver_mobile, Colors.black12)
                            ]),
                            TableRow(children: [
                              info_table_cell('Tour Approver',
                                  const Color.fromARGB(255, 119, 131, 239)),
                              info_table_cell(approver_id, Colors.black12),
                              info_table_cell(approver_mobile, Colors.black12)
                            ]),
                            TableRow(children: [
                              info_table_cell('Leave Recommender',
                                  const Color.fromARGB(255, 119, 131, 239)),
                              info_table_cell(approver_id, Colors.black12),
                              info_table_cell(approver_mobile, Colors.black12)
                            ]),
                            TableRow(children: [
                              info_table_cell('Leave Approver',
                                  const Color.fromARGB(255, 119, 131, 239)),
                              info_table_cell(approver_id, Colors.black12),
                              info_table_cell(approver_mobile, Colors.black12)
                            ])
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ),
              );
  }
}

class ChartData {
  ChartData(
    this.x,
    this.y,
  );
  final String x;
  final int? y;
}

class info_table_cell extends StatelessWidget {
  String show;
  var background_color;
  info_table_cell(this.show, this.background_color);

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: background_color),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
              child: Column(
                children: [
                  AutoSizeText(
                    show,
                    maxLines: 1,
                    minFontSize: 5,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
