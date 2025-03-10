import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmployeeListScreen extends StatefulWidget {
  final int unitId;
  final List<dynamic> allStaff;

  EmployeeListScreen({required this.unitId, required this.allStaff});

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  Map<String, String> staffPhotos = {};
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

        if (decodedData is Map<String, dynamic> && decodedData.containsKey('photo')) {
          List<dynamic> staffList = decodedData['photo'];

          setState(() {
            staffPhotos = {
              for (var staff in staffList)
                if (staff["user_id"] != null && staff["user_photo"] != null && staff["user_photo"].toString().isNotEmpty)
                  staff["user_id"].toString(): "https://home.cdipbd.org/${staff["user_photo"]}"
            };
          });

          // Debug log to verify ID mapping
          staffPhotos.forEach((key, value) {
            print("Mapped Employee ID: $key -> Image URL: $value");
          });
        }
      } else {
        print('Failed to fetch staff photos: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching staff photos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredEmployees = widget.allStaff.where((staff) {
      return staff["unit_id"] == widget.unitId;
    }).toList();

    print("Filtered Employee List for Unit ${widget.unitId}: $filteredEmployees");

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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: filteredEmployees.length,
          itemBuilder: (context, index) {
            var employee = filteredEmployees[index];
            String empId = employee["emp_id"].toString().trim();  // Ensure trimming spaces
            String? imageUrl = staffPhotos[empId];

            // Debugging ID Mapping
            print("Checking ID Mapping - Staff ID: '$empId', Available Photo IDs: ${staffPhotos.keys}");

            if (!staffPhotos.containsKey(empId)) {
              print("No match found for Employee ID: $empId");
            }

            // Debugging individual employee details
            print("Rendering Employee - ID: $empId, Name: ${employee["emp_name_eng"]}, Image URL: $imageUrl");

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
                  backgroundColor: Colors.grey[300], // Default background color
                  backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                      ? NetworkImage(imageUrl)
                      : null, // Only set if URL is valid
                  child: (imageUrl == null || imageUrl.isEmpty)
                      ? Icon(Icons.person, size: 30, color: Colors.grey[700])
                      : null, // Show icon if no image
                ),
                title: Text(
                  employee["emp_name_eng"] ?? "Unknown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee["designation_name"] ?? "N/A",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Phone: ${employee["staff_phone"] ?? "N/A"}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      "Email: ${employee["staff_email"] ?? "N/A"}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
