import 'package:flutter/material.dart';
import 'package:phb2/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'uni_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";
  String userID = "";
  String userDesignation = "";
  String userPhoto = "";
  List<dynamic> departments = [];
  List<dynamic> allUnits = [];
  List<dynamic> allStaff = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchDepartments();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("userName") ?? "Unknown";
      userID = prefs.getString("userID") ?? "N/A";
      userDesignation = prefs.getString("userDesignation") ?? "N/A";
      userPhoto = prefs.getString("userPhoto") ?? "";
    });
  }

  Future<void> fetchDepartments() async {
    final response = await http.get(Uri.parse("https://phonebook.microfineye.com/api/all_staff_phnbook"));
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("all_project", response.body);
      prefs.setString("all_zone", response.body);
      prefs.setString("all_area", response.body);
      prefs.setString("all_branch", response.body);
      prefs.setString("all_depart_ment", response.body);
      prefs.setString("all_unit", response.body);
      prefs.setString("all_staff", response.body); // Save all_staff data as well

      setState(() {
        var data = json.decode(response.body);
        departments = data["all_depart_ment"];
        allUnits = data["all_unit"];
        allStaff = data["all_staff"];
        departments.insert(0, {"department_id": 999, "department_name": "EMT"});
      });
    }
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
        backgroundColor: Colors.blue,
        title: Text("Dashboard"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: userPhoto.isNotEmpty
                        ? NetworkImage("https://home.cdipbd.org/$userPhoto")
                        : null,
                    child: userPhoto.isEmpty ? Icon(Icons.person, size: 40) : null,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: $userName", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("ID: $userID", style: TextStyle(fontSize: 16)),
                        Text("Designation: $userDesignation", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: logout,
                    icon: Icon(Icons.logout, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: departments.isNotEmpty
                ? GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: departments.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (departments[index]["department_id"] != 999) {
                      // Filter the units by department_code
                      var filteredUnits = allUnits.where((unit) {
                        return unit["department_code"] == departments[index]["department_id"];
                      }).toList();

                      // Navigate to the UnitListScreen, passing filtered units
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UnitListScreen(
                            units: filteredUnits,
                            departmentName: departments[index]["department_name"],
                            allStaff: allStaff,
                            departmentID: departments[index]["department_id"],
                               // Pass the filtered units to the UnitListScreen
                          ),
                        ),
                      );
                    }
                  },
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.apartment, size: 40, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(
                            departments[index]["department_name"],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )


                : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchDepartments,
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
