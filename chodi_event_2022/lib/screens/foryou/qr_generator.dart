import 'dart:developer';
// import 'dart:html';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chodi_app/models/event.dart';
import 'package:flutter_chodi_app/widget/share_modal.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
//import 'package:share_plus/share_plus.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/firebase_authentication_service.dart';


import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGeneratorPage extends StatelessWidget {
  final String url;
  final String name;
  final String description;
  final Timestamp startDate;
  final Timestamp endDate;
  final String address;
  final String locationDescription;
  final String state;
  final int zip;
  final String country;



  const QrGeneratorPage({Key? key, required this.url, required this.name, required this.description, required this.startDate, required this.endDate, required this.address, required this.locationDescription, required this.state, required this.zip, required this.country}) : super(key: key);

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Event',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name, // display the name of the event
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: QrImage(
                    data: url, // generate a QR code with the provided URL
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
              ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                description, // display the description of the event
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Start Date: ${DateFormat('MM/dd/yyyy').format(startDate.toDate())}', // format the start date using DateFormat
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'End Date: ${DateFormat('MM/dd/yyyy').format(endDate.toDate())}', // format the end date using DateFormat
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              '$address, $locationDescription, $state $zip, $country', // display the complete address
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

}


