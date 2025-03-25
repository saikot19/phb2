import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://home.cdipbd.org/api/v1";

  // Login method
  Future<Map<String, dynamic>> login(String employeeId, String password) async {
    String url = "$baseUrl/login-check";
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, String> body = {
      "employee_id": employeeId,
      "pass": password,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Login failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error during login: $e");
    }
  }

  // Fetch departments
  Future<Map<String, dynamic>> fetchDepartments() async {
    String url = "https://phonebook.microfineye.com/api/all_staff_phnbook";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load departments: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching departments: $e");
    }
  }

  // Fetch staff photos
  Future<List<dynamic>> fetchStaffPhotos() async {
    String url = "$baseUrl/staff-photo";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData is Map<String, dynamic> &&
            decodedData.containsKey('photo')) {
          return decodedData['photo'] ?? [];
        } else {
          throw Exception('Invalid API response format.');
        }
      } else {
        throw Exception("Failed to fetch staff photos: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching staff photos: $e");
    }
  }

  // Fetch employees by unit ID
  Future<List<dynamic>> fetchEmployeesByUnit(int unitId) async {
    String url = "$baseUrl/employees-by-unit/$unitId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData is List<dynamic>) {
          return decodedData;
        } else {
          throw Exception('Invalid API response format.');
        }
      } else {
        throw Exception("Failed to fetch employees: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching employees: $e");
    }
  }

  // Save user data to SharedPreferences
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString("userCode", userData["userCode"] ?? "");
      await prefs.setString("userPhoto", userData["userPhoto"] ?? "");
      await prefs.setString("userName", userData["userName"] ?? "");
      await prefs.setString("userPhone", userData["userPhone"] ?? "");
      await prefs.setString("userEmail", userData["userEmail"] ?? "");
    } catch (e) {
      throw Exception("Error saving user data: $e");
    }
  }
}
