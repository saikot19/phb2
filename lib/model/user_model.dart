import 'package:flutter/foundation.dart';
import '../helper/api.dart'; // Import the ApiService

class UserModel with ChangeNotifier {
  final ApiService apiService = ApiService();

  // User information
  String? userCode;
  String? userPhoto;
  String? userName;
  String? userPhone;
  String? userEmail;
  String userID = "";
  String userDesignation = "";

  // State management
  bool isLoading = false;

  // Employee photos
  List<EmployeePhoto> employeePhotos = [];
  List<dynamic> departments = [];
  List<dynamic> allUnits = [];
  List<dynamic> allStaff = [];

  get loadUser => null;

  // Login method
  Future<void> login(String employeeId, String password) async {
    _setLoading(true);

    try {
      final data = await apiService.login(employeeId, password);
      await apiService.saveUserData(data);

      userCode = data["userCode"] ?? "";
      userPhoto = data["userPhoto"] ?? "";
      userName = data["userName"] ?? "";
      userPhone = data["userPhone"] ?? "";
      userEmail = data["userEmail"] ?? "";

      notifyListeners();
    } catch (e) {
      print("Login error: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Fetch departments with image assignment & EMT sorting
  Future<void> fetchDepartments() async {
    _setLoading(true);

    try {
      final staffData = await apiService.fetchDepartments();
      final photosData = await apiService.fetchStaffPhotos();

      allStaff = staffData["all_staff"];
      List<dynamic> photos = photosData;

      // Convert photo list into a Map for quick lookup (user_code -> user_photo)
      Map<String, String> photoMap = {};
      for (var photo in photos) {
        if (photo["user_photo"] != null &&
            photo["user_photo"].toString().isNotEmpty) {
          String formattedUrl =
              "https://home.cdipbd.org/${photo["user_photo"].toString().replaceAll("public/", "")}";
          photoMap[photo["user_code"].toString()] = formattedUrl;
        }
      }

      // Assign images if found
      for (var staff in allStaff) {
        String empId = staff["emp_id"].toString();
        if (photoMap.containsKey(empId)) {
          staff["staff_image"] = photoMap[empId];
        }
      }

      // Separate EMT staff
      List<dynamic> emtStaff =
          allStaff.where((staff) => staff["is_emt"] == 1).toList();
      allStaff.removeWhere((staff) => staff["is_emt"] == 1);

      departments = [
        {"department_name": "EMT", "staff": emtStaff},
        ...staffData["all_depart_ment"]
      ];

      notifyListeners();
    } catch (e) {
      print("Error fetching departments: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Fetch staff photos
  Future<void> fetchStaffPhotos() async {
    _setLoading(true);

    try {
      final photos = await apiService.fetchStaffPhotos();
      employeePhotos = photos.map<EmployeePhoto>((staff) {
        String imageUrl = staff["user_photo"]?.toString() ?? "";
        if (imageUrl.isNotEmpty) {
          imageUrl =
              "https://home.cdipbd.org/${imageUrl.replaceAll("public/", "")}";
        }
        return EmployeePhoto(
          userId: staff["user_id"]?.toString().trim() ?? "",
          imageUrl: imageUrl,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print("Fetch staff photos error: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Logout method
  Future<void> logout() async {
    userCode = null;
    userPhoto = null;
    userName = null;
    userPhone = null;
    userEmail = null;
    userID = "";
    userDesignation = "";

    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}

class EmployeePhoto {
  final String userId;
  final String imageUrl;

  EmployeePhoto({required this.userId, required this.imageUrl});
}
