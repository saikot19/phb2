import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _employeeIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  /// Check if the user is already logged in
  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userCode = prefs.getString("userCode");

    if (userCode != null) {
      // User already logged in, navigate to HomeScreen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  /// Handles login API request
  Future<void> login() async {
    String url = "https://home.cdipbd.org/api/v1/login-check";
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, String> body = {
      "employee_id": _employeeIdController.text,
      "pass": _passwordController.text
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data["status"] == "200") {
          await saveUserData(data);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          showError("Invalid credentials");
        }
      } else {
        showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      showError("Network error: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Saves user data into SharedPreferences
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userCode", userData["userCode"]);
    await prefs.setString("userPhoto", userData["userPhoto"]);
    await prefs.setString("userName", userData["userName"]);
    await prefs.setString("userPhone", userData["userPhone"]);
    await prefs.setString("userEmail", userData["userEmail"]);
  }

  /// Shows an error message as a SnackBar
  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  // Employee ID Field
                  TextField(
                    controller: _employeeIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Employee ID",
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Square Login Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Colors.blue.shade700,
                        shadowColor: Colors.blue.shade300,
                        elevation: 5,
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      print("Forgot Password Clicked");
                    },
                    child: Text("Forgot Password?",
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
          ),

          // Full-screen loading indicator
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
