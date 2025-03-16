import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/user_model.dart';
import 'login_screen.dart';
import 'uni_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserModel>(context, listen: false).fetchDepartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<UserModel>(context, listen: false).fetchDepartments();
            },
          ),
        ],
      ),
      body: Consumer<UserModel>(
        builder: (context, userModel, child) {
          return Column(
            children: [
              _buildProfileCard(userModel),
              Expanded(
                child: userModel.departments.isNotEmpty
                    ? _buildDepartmentGrid(userModel)
                    : Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(UserModel userModel) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  userModel.userPhoto != null && userModel.userPhoto!.isNotEmpty
                      ? NetworkImage(
                          "https://home.cdipbd.org/${userModel.userPhoto}")
                      : null,
              child: userModel.userPhoto == null || userModel.userPhoto!.isEmpty
                  ? Icon(Icons.person, size: 40)
                  : null,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${userModel.userName ?? "Unknown"}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("ID: ${userModel.userID ?? "N/A"}",
                      style: TextStyle(fontSize: 16)),
                  Text("Designation: ${userModel.userDesignation ?? "N/A"}",
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                userModel.logout();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              icon: Icon(Icons.logout, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentGrid(UserModel userModel) {
    List<dynamic> allDepartments = List.from(userModel.departments);
    List<dynamic> emtStaff =
        userModel.allStaff.where((staff) => staff["is_emt"] == 1).toList();

    if (emtStaff.isNotEmpty) {
      allDepartments.insert(0,
          {"department_id": 999, "department_name": "EMT", "staff": emtStaff});
    }

    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: allDepartments.length,
      itemBuilder: (context, index) {
        var department = allDepartments[index];
        int departmentID =
            int.tryParse(department["department_id"].toString()) ?? 0;

        return GestureDetector(
          onTap: () {
            var filteredUnits = userModel.allUnits
                .where((unit) => unit["department_code"] == departmentID)
                .toList();

            if (departmentID == 999) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UnitListScreen(
                    units: [],
                    departmentName: "EMT",
                    allStaff: department["staff"],
                    departmentID: departmentID,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UnitListScreen(
                    units: filteredUnits,
                    departmentName: department["department_name"],
                    allStaff: userModel.allStaff,
                    departmentID: departmentID,
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
                    department["department_name"] ?? "Unknown",
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
    );
  }
}
