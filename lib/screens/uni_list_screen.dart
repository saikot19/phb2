import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phb2/model/user_model.dart'; // Import your UserModel
import 'employee_list_screen.dart';

class UnitListScreen extends StatelessWidget {
  final List<dynamic> units;
  final String departmentName;
  final List<dynamic> allStaff;
  final int departmentID;

  UnitListScreen({
    required this.units,
    required this.departmentName,
    required this.allStaff,
    required this.departmentID,
  });

  @override
  Widget build(BuildContext context) {
    // Access the UserModel using Provider
    final userModel = Provider.of<UserModel>(context);

    // Filter units based on departmentID
    List<dynamic> filteredUnits =
        units.where((unit) => unit["department_code"] == departmentID).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Units in $departmentName"),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: filteredUnits.isEmpty
            ? Center(
                child: Text(
                  "No units found for this department",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: filteredUnits.length,
                itemBuilder: (context, index) {
                  var unit = filteredUnits[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      title: Text(
                        unit["unit_name"],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Colors.blueAccent),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/employeeList',
                          arguments: {
                            'unitId': unit["id"],
                            'allStaff': allStaff,
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
