import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeListScreen extends StatefulWidget {
  final int unitId;
  final List<dynamic> allStaff;

  EmployeeListScreen({required this.unitId, required this.allStaff});

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<EmployeePhoto> employeePhotos = [];
  final String apiUrl = "https://home.cdipbd.org/api/v1/staff-photo"; // API URL

  @override
  void initState() {
    super.initState();
    fetchStaffPhotos();
  }

  Future<void> fetchStaffPhotos() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData is Map<String, dynamic> &&
            decodedData.containsKey('photo')) {
          List<dynamic> staffList = decodedData['photo'];

          setState(() {
            employeePhotos = staffList
                .where((staff) =>
                    staff["user_id"] != null &&
                    staff["user_photo"] != null &&
                    staff["user_photo"].toString().isNotEmpty)
                .map((staff) => EmployeePhoto(
                      userId: staff["user_id"].toString().trim(),
                      imageUrl:
                          "https://home.cdipbd.org/${staff["user_photo"]}",
                    ))
                .toList();
          });
        }
      } else {
        print('Failed to fetch staff photos: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching staff photos: $e');
    }
  }

  String? _getImageUrlForEmployee(String empId) {
    for (var photo in employeePhotos) {
      if (photo.userId == empId) {
        return photo.imageUrl;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredEmployees = widget.allStaff.where((staff) {
      return staff["unit_id"] == widget.unitId;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Employees in Unit ${widget.unitId}"),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: filteredEmployees.isEmpty
            ? Center(
                child: Text(
                  "No employees found for this unit",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  var employee = filteredEmployees[index];
                  String empId = employee["emp_id"].toString();
                  // Get image URL directly from allStaff data
                  String? imageUrl = employee["user_photo"] != null &&
                          employee["user_photo"].toString().isNotEmpty
                      ? "${employee["user_photo"]}"
                      : null; // Default if no image found

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            Colors.grey[300], // Default background color
                        backgroundImage:
                            (imageUrl != null && imageUrl.isNotEmpty)
                                ? NetworkImage(imageUrl)
                                : null, // Only set if URL is valid
                        child: (imageUrl == null || imageUrl.isEmpty)
                            ? Icon(Icons.person,
                                size: 30, color: Colors.grey[700])
                            : null, // Show icon if no image
                      ),
                      title: Text(
                        employee["emp_name_eng"] ?? "Unknown",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee["designation_name"] ?? "N/A",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Phone: ${employee["staff_phone"] ?? "N/A"}",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          Text(
                            "Email: ${employee["staff_email"] ?? "N/A"}",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      onTap: () {
                        showStaffOptionsDialog(context, employee["staff_phone"],
                            employee["staff_email"]);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  void showStaffOptionsDialog(
      BuildContext context, String? phoneNumber, String? email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose an Action"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.copy),
                title: Text("Copy"),
                onTap: () {
                  if (phoneNumber != null && phoneNumber.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: phoneNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Phone number copied!")),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.call),
                title: Text("Call"),
                onTap: () {
                  if (phoneNumber != null && phoneNumber.isNotEmpty) {
                    launchUrl(Uri.parse("tel:$phoneNumber"));
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text("Email"),
                onTap: () {
                  if (email != null && email.isNotEmpty) {
                    launchUrl(Uri.parse("mailto:$email"));
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class EmployeePhoto {
  final String userId;
  final String imageUrl;

  EmployeePhoto({required this.userId, required this.imageUrl});
}
