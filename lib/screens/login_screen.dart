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

  Future<void> login() async {
    String url = "https://home.cdipbd.org/api/v1/login-check";
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, String> body = {
      "employee_id": _employeeIdController.text,
      "pass": _passwordController.text
    };

    print("Login URL: $url");
    print("Request Headers: $headers");
    print("Request Body: ${jsonEncode(body)}");

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(body));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print("Decoded Response: $data");

        if (data["status"] == "200") {
          await saveUserData(data);
          print("User data saved successfully.");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          showError("Invalid credentials");
        }
      } else {
        showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Network error: $e");
      showError("Network error: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userCode", userData["userCode"]);
    await prefs.setString("userPhoto", userData["userPhoto"]);
    await prefs.setString("userName", userData["userName"]);
    await prefs.setString("userPhone", userData["userPhone"]);
    await prefs.setString("userEmail", userData["userEmail"]);
    print("Saved User Data: ${jsonEncode(userData)}");
  }

  void showError(String message) {
    print("Error: $message");
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _employeeIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Employee ID"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: login,
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
