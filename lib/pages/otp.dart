// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:san_group/pages/login.dart';

// var entered_otp;

// class otp_verify extends StatefulWidget {
//   const otp_verify({Key? key}) : super(key: key);

//   @override
//   State<otp_verify> createState() => _otp_verifyState();
// }

// class _otp_verifyState extends State<otp_verify> {
//   @override
//   Widget build(BuildContext context) {
//     final defaultPinTheme = PinTheme(
//       width: 56,
//       height: 56,
//       textStyle: TextStyle(
//           fontSize: 20,
//           color: Color.fromRGBO(30, 60, 87, 1),
//           fontWeight: FontWeight.w600),
//       decoration: BoxDecoration(
//         border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
//         borderRadius: BorderRadius.circular(20),
//       ),
//     );

//     final focusedPinTheme = defaultPinTheme.copyDecorationWith(
//       border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
//       borderRadius: BorderRadius.circular(8),
//     );

//     final submittedPinTheme = defaultPinTheme.copyWith(
//       decoration: defaultPinTheme.decoration?.copyWith(
//         color: Color.fromRGBO(234, 239, 243, 1),
//       ),
//     );

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: Icon(
//             Icons.arrow_back_ios_rounded,
//             color: Colors.black,
//           ),
//         ),
//         elevation: 0,
//       ),
//       body: Container(
//         margin: EdgeInsets.only(left: 25, right: 25),
//         alignment: Alignment.center,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'images/san_group.jpg',
//                 width: 150,
//                 height: 150,
//               ),
//               SizedBox(
//                 height: 25,
//               ),
//               Text(
//                 "Phone Verification",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 "A verification code is sent to your registered mobile number",
//                 style: TextStyle(
//                   fontSize: 16,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               Pinput(
//                 onChanged: (value) {
//                   entered_otp = value;
//                 },

//                 length: 6, //keyboardType: TextInputType.none,
//                 // defaultPinTheme: defaultPinTheme,
//                 // focusedPinTheme: focusedPinTheme,
//                 // submittedPinTheme: submittedPinTheme,

//                 showCursor: true,
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Material(
//                 elevation: 5,
//                 borderRadius: BorderRadius.circular(30),
//                 color: Colors.blueGrey,
//                 child: MaterialButton(
//                     padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
//                     minWidth: MediaQuery.of(context).size.width,
//                     onPressed: () async {
//                       PhoneAuthCredential credential =
//                           PhoneAuthProvider.credential(
//                               verificationId: login.firebase_generated_code,
//                               smsCode: entered_otp);

//                       await FirebaseAuth.instance
//                           .signInWithCredential(credential);
//                     },
//                     child: const Text(
//                       "Verify phone number",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           fontSize: 20,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold),
//                     )),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
