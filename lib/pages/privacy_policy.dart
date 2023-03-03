import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:san_group/drawer.dart';

class privacy_policy extends StatefulWidget {
  const privacy_policy({super.key});

  @override
  State<privacy_policy> createState() => _privacy_policyState();
}

class _privacy_policyState extends State<privacy_policy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: const Text('Privacy Policy',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        drawer: home_drawer(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Privacy Policy\n",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      "SAN GROUP built the SAN GROUP HR app as a Commercial app. This SERVICE is provided by SAN GROUP and is intended for use as SAN GROUP HR",
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  Text(
                      "This page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service.",
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  Text(
                      "If you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy.",
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  Text(
                      "The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which are accessible at SAN GROUP HR unless otherwise defined in this Privacy Policy.",
                      style: TextStyle(
                        fontSize: 18,
                      )),
                ],
              ),
            ),
          ),
        ));
  }
}
