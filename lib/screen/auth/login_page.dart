import 'package:checkme/provider/api_service.dart';
import 'package:checkme/screen/scanner/qr_scanner_page.dart';
import 'package:checkme/screen/scanner/user_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final url = ApiService.buildUrl('login');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final token = data['token'];
          final authId = data['auth']['auth_id'];
          final email = data['auth']['email'];
          final role = data['auth']['role'];
          final status = data['data']['status'];
          final employeeId = data['data']['employee_id'];
          final employeeName = data['data']['employee']['employee_name'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setInt('auth_id', authId);
          await prefs.setString('email', email);
          await prefs.setString('role', role);
          await prefs.setString('status', status);
          await prefs.setInt('employee_id', employeeId);
          await prefs.setString('employee_name', employeeName);

          print('User Data Stored');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Successful!')),
          );

          // Navigate to UserInformationPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const UserInformationPage()),
          );
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${errorData['message']}')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Easy Check',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(
                                  r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                              .hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18.0, // Adjust the font size
                                  fontWeight:
                                      FontWeight.bold, // Make the text bold
                                  color: Colors.white, // Set the text color
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .blue, // Set the button's background color
                                foregroundColor: Colors
                                    .white, // Set the text color when the button is pressed
                                disabledForegroundColor: Colors
                                    .grey, // Set the color when the button is disabled
                                shadowColor:
                                    Colors.black, // Set the shadow color
                                elevation: 8.0, // Set the elevation
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40.0,
                                    vertical: 12.0), // Set padding
                              ),
                            ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QRScannerPage()),
                          );
                        },
                        child: Text(
                          'Go to Scan',
                          style: TextStyle(
                            fontSize: 18.0, // Adjust the font size
                            fontWeight: FontWeight.bold, // Make the text bold
                            color: Colors.white, // Set the text color
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue, // Set the button's background color
                          foregroundColor: Colors
                              .white, // Set the text color when the button is pressed
                          disabledForegroundColor: Colors
                              .grey, // Set the color when the button is disabled
                          shadowColor: Colors.black, // Set the shadow color
                          elevation: 8.0, // Set the elevation
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 12.0), // Set padding
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
