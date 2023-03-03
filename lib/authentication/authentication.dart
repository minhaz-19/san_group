// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:device_imei/device_imei.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:san_group/drawer.dart';
// import 'package:san_group/pages/attendance_entry.dart';

// Position? hiposition;

// class imei extends StatefulWidget {
//   const imei({super.key});

//   @override
//   State<imei> createState() => _imeiState();
// }

// class _imeiState extends State<imei> {
//   String? _deviceImei = 'Unknown';

//   @override
//   void initState() {
//     super.initState();
//     getImei();
//   }

//   Future<void> getImei() async {
//     String? imei;
//     try {
//       imei = await DeviceImei.getImei();
//     } catch (e) {
//       print(e);
//     }

//     if (!mounted) return;
//     setState(() {
//       _deviceImei = imei;
//     });
//     current_position = await determinePosition();
//     FirebaseFirestore.instance.collection('office').doc('test').set({
//       'latitude': hiposition!.latitude,
//     });
//     Fluttertoast.showToast(msg: 'done');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         drawer: home_drawer(),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('IMEI: $_deviceImei\n'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
