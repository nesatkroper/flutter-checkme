import 'package:checkme/screen/scanner/qr_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  String token = "";
  String employeeName = "";
  int employeeId = 0;
  int authId = 0;
  String role = "";
  String status = "";
  String email = "";

  Future<void> getInformation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("token") ?? "No Token Found";
      employeeName = prefs.getString('employee_name') ?? "No Name Found";
      employeeId = prefs.getInt('employee_id') ?? 0;
      authId = prefs.getInt('auth_id') ?? 0;
      role = prefs.getString('role') ?? "";
      status = prefs.getString('status') ?? "";
      email = prefs.getString('email') ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    getInformation(); // Fetch token when screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("Easy Check"),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  "Name: $employeeName",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "EMP ID: $employeeId",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Email: $email",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: ElevatedButton(
                onPressed: () {
                  getInformation(); // Call your function
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRScannerPage(),
                    ),
                  );
                },
                child: const Text("Scan Attendace"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
