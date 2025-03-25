import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_animate/flutter_animate.dart';

import 'package:provider/provider.dart';

import '../model/user_model.dart'; // Import your UserModel

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;

  final TextEditingController employeeIdController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    checkLoginStatus();

    // Initialize animations

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _formAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    employeeIdController.dispose();

    passwordController.dispose();

    super.dispose();
  }

  /// Check if the user is already logged in

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userCode = prefs.getString("userCode");

    if (userCode != null) {
      // User already logged in, navigate to HomeScreen

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  /// Handles login API request

  Future<void> login() async {
    final userModel = Provider.of<UserModel>(context, listen: false);

    try {
      await userModel.login(employeeIdController.text, passwordController.text);

      // Navigate to HomeScreen after successful login

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      showError(e.toString());
    }
  }

  /// Shows an error message as a SnackBar

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 235, 233, 149),
              Colors.blue.shade300
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoAnimation,
                  child: Image.asset('assets/logo.png', height: 100),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Animate(
                    effects: [
                      FadeEffect(duration: 500.ms),
                      SlideEffect(begin: Offset(0, 1), end: Offset(0, 0))
                    ],
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "Login",
                          style: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: employeeIdController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.black54),
                            labelText: "User  Name",
                            labelStyle: GoogleFonts.lexendDeca(),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.black54),
                            labelText: "Password",
                            labelStyle: GoogleFonts.lexendDeca(),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: userModel.isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: userModel.isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text("Login",
                                    style: GoogleFonts.lexendDeca(
                                        color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
