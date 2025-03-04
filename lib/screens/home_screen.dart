import 'package:flutter/material.dart';
import 'package:phb2/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";
  String userEmail = "";
  String userPhone = "";
  String userPhoto = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("userName") ?? "Unknown";
      userEmail = prefs.getString("userEmail") ?? "No email";
      userPhone = prefs.getString("userPhone") ?? "No phone";
      userPhoto = prefs.getString("userPhoto") ?? "";
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $userName"),
        actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            userPhoto.isNotEmpty
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage("https://home.cdipbd.org/$userPhoto"),
                  )
                : Icon(Icons.person, size: 100),
            SizedBox(height: 20),
            Text("Name: $userName", style: TextStyle(fontSize: 18)),
            Text("Email: $userEmail", style: TextStyle(fontSize: 16)),
            Text("Phone: $userPhone", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
