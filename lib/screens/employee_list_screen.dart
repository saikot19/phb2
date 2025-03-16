import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeListScreen extends StatefulWidget {
  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<dynamic> employees = [];
  List<dynamic> emtEmployees = [];
  Map<String, String> employeePhotos = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final staffResponse = await http.get(
          Uri.parse("https://phonebook.microfineye.com/api/all_staff_phnbook"));
      final photoResponse = await http
          .get(Uri.parse("https://home.cdipbd.org/api/v1/staff-photo"));

      if (staffResponse.statusCode == 200 && photoResponse.statusCode == 200) {
        final staffData = json.decode(staffResponse.body);
        final photoData = json.decode(photoResponse.body);

        // Create a map of email to image URL for quick lookup
        Map<String, String> photoMap = {
          for (var photo in photoData)
            if (photo["user_email"] != null)
              photo["user_email"]: photo["image_url"] ?? ""
        };

        // Assign images dynamically
        List<dynamic> allEmployees = staffData.map((employee) {
          String email = employee["staff_email"] ?? "";
          employee["image_url"] = photoMap[email] ?? ""; // Assign image URL
          return employee;
        }).toList();

        setState(() {
          employees = allEmployees.where((e) => e["is_emt"] != 1).toList();
          emtEmployees = allEmployees.where((e) => e["is_emt"] == 1).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error loading data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employee List")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : employees.isEmpty && emtEmployees.isEmpty
              ? Center(child: Text("No employee data available"))
              : ListView(
                  children: [
                    if (emtEmployees.isNotEmpty)
                      buildSectionTitle("EMT Employees"),
                    ...emtEmployees.map(buildEmployeeCard).toList(),
                    if (employees.isNotEmpty)
                      buildSectionTitle("All Employees"),
                    ...employees.map(buildEmployeeCard).toList(),
                  ],
                ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildEmployeeCard(dynamic employee) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: employee["image_url"].isNotEmpty
            ? CachedNetworkImage(
                imageUrl: employee["image_url"],
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    Icon(Icons.account_circle, size: 50),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : Icon(Icons.account_circle, size: 50),
        title: Text(employee["emp_name_eng"] ?? "Unknown"),
        subtitle: Text(employee["designation_name"] ?? "Unknown"),
        trailing: IconButton(
          icon: Icon(Icons.call, color: Colors.green),
          onPressed: () async {
            final phone = employee["staff_phone"];
            if (phone != null && await canLaunchUrl(Uri.parse("tel:$phone"))) {
              await launchUrl(Uri.parse("tel:$phone"));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Cannot launch dialer")));
            }
          },
        ),
      ),
    );
  }
}
