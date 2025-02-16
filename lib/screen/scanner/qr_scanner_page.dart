import 'dart:convert';

import 'package:checkme/provider/api_service.dart';
import 'package:checkme/screen/scanner/user_info.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? qrCodeResult;
  String token = "";
  int employeeId = 0;

  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> handleAttendce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "No Token Found";
    employeeId = prefs.getInt('employee_id') ?? 0;
    final url = ApiService.buildUrl('tele-att');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'employee_id': employeeId, 'api_key': qrCodeResult}),
      );

      if (response.statusCode == 200) {
        showAlert(context, "Welcome to work.");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserInformationPage()),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Set background to gray
      appBar: AppBar(title: const Text("Easy Check")),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 50), // Push scanner 50px from the top
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MobileScanner(
                      fit: BoxFit.cover,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          setState(() {
                            qrCodeResult = barcodes.first.rawValue ?? "No Data";
                            if (qrCodeResult != null) handleAttendce();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                qrCodeResult ?? "Scan a QR  Code",
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ],
          ),
          // Positioned "Scan Again" button 50px from the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ElevatedButton(
                onPressed: () => setState(() {
                  qrCodeResult = null;
                }),
                child: const Text("Scan Again"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
