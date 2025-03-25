import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';
import 'login_screen.dart';
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
  List<Map<String, dynamic>> matchedEmployees = [];

  final String staffPhotoApi = "https://home.cdipbd.org/api/v1/staff-photo";
  final String allStaffApi =
      "https://phonebook.microfineye.com/api/all_staff_phnbook";

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchDepartments();
    fetchAndMatchEmployees();
  }

  /// Load user data from SharedPreferences
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("userName") ?? "Unknown";
      userID = prefs.getString("userID") ?? "N/A";
      userDesignation = prefs.getString("userDesignation") ?? "N/A";
      userPhoto = prefs.getString("userPhoto") ?? "";
    });
  }

  /// Fetch and match employees with photos
  Future<void> fetchAndMatchEmployees() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(staffPhotoApi)),
        http.get(Uri.parse(allStaffApi))
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        var staffPhotoData = jsonDecode(responses[0].body);
        var allStaffData = jsonDecode(responses[1].body);

        List<dynamic> staffPhotos = staffPhotoData["photo"];
        List<dynamic> allStaff = allStaffData["all_staff"];

        List<Map<String, dynamic>?> matchedList = staffPhotos
            .map((staff) {
              var matchedStaff = allStaff.firstWhere(
                (employee) =>
                    employee["emp_id"].toString().trim() ==
                    staff["user_code"].toString().trim(),
                orElse: () => null,
              );

              if (matchedStaff != null) {
                return {
                  "user_id": staff["user_id"],
                  "user_name": staff["user_name"],
                  "user_phone": staff["user_phone"],
                  "user_email": staff["user_email"],
                  "user_photo": staff["user_photo"].toString().isNotEmpty
                      ? "https://home.cdipbd.org/${staff["user_photo"]}"
                      : "",
                  "emp_id": matchedStaff["emp_id"],
                  "emp_name_eng": matchedStaff["emp_name_eng"],
                  "staff_phone": matchedStaff["staff_phone"],
                  "designation": matchedStaff["designation_name"],
                  "unit_id": matchedStaff["unit_id"],
                  "department_name": matchedStaff["department_name"],
                };
              }
              return null;
            })
            .where((item) => item != null)
            .toList();

        setState(() {
          matchedEmployees = matchedList.cast<Map<String, dynamic>>();
        });

        print("Matched Employees: ${matchedEmployees.length}");
      } else {
        throw Exception(
            "API Error: ${responses[0].statusCode}, ${responses[1].statusCode}");
      }
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load employees. Check your network.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  /// Fetch departments and update state
  Future<void> fetchDepartments() async {
    final response = await http.get(Uri.parse(allStaffApi));

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("all_project", response.body);
      prefs.setString("all_zone", response.body);
      prefs.setString("all_area", response.body);
      prefs.setString("all_branch", response.body);
      prefs.setString("all_depart_ment", response.body);
      prefs.setString("all_unit", response.body);
      prefs.setString("all_staff", response.body);

      setState(() {
        var data = json.decode(response.body);
        departments = data["all_depart_ment"];
        allUnits = data["all_unit"];
        allStaff = matchedEmployees;
        departments.insert(0, {"department_id": 999, "department_name": "EMT"});
      });
    }
  }

  /// Logout and clear user data
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
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
          _buildProfileCard(),
          Expanded(
            child: departments.isNotEmpty
                ? _buildDepartmentGrid()
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

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: userPhoto.isNotEmpty
                  ? Image.network("https://home.cdipbd.org/$userPhoto",
                      width: 60, height: 60, fit: BoxFit.cover)
                  : Icon(Icons.person, size: 60, color: Colors.grey),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: $userName",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("ID: $userID", style: TextStyle(fontSize: 16)),
                  Text("Designation: $userDesignation",
                      style: TextStyle(fontSize: 16)),
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
    );
  }

  Widget _buildDepartmentGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: departments.length,
      itemBuilder: (context, index) {
        var department = departments[index];
        int departmentID =
            int.tryParse(department["department_id"].toString()) ?? 0;

        return GestureDetector(
          onTap: () {
            var filteredUnits = departmentID == 999
                ? []
                : allUnits
                    .where((unit) => unit["department_code"] == departmentID)
                    .toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UnitListScreen(
                  units: filteredUnits,
                  departmentName: department["department_name"],
                  allStaff: allStaff,
                  departmentID: departmentID,
                ),
              ),
            );
          },
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apartment, size: 40, color: Colors.blue),
                SizedBox(height: 8),
                Text(
                  department["department_name"] ?? "Unknown",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
