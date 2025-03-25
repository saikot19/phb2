import 'package:flutter/foundation.dart';
import '../helper/api.dart';

class EmployeeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  List<dynamic> _employees = [];
  List<dynamic> _staffPhotos = [];

  bool get isLoading => _isLoading;
  List<dynamic> get employees => _employees;
  List<dynamic> get staffPhotos => _staffPhotos;

  // Fetch employees by unit ID
  Future<void> fetchEmployees(int unitId) async {
    _setLoading(true);

    try {
      List<dynamic> fetchedEmployees =
          await _apiService.fetchEmployeesByUnit(unitId);
      _employees = fetchedEmployees;
    } catch (e) {
      print("Error fetching employees: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Fetch staff photos
  Future<void> fetchStaffPhotos() async {
    _setLoading(true);

    try {
      List<dynamic> fetchedPhotos = await _apiService.fetchStaffPhotos();

      // Ensure no updates happen after widget disposal
      if (fetchedPhotos.isNotEmpty) {
        _staffPhotos = fetchedPhotos
            .where((staff) =>
                staff["user_id"] != null &&
                staff["user_photo"] != null &&
                staff["user_photo"].toString().isNotEmpty)
            .map((staff) => {
                  "user_id": staff["user_id"].toString().trim(),
                  "imageUrl": "https://home.cdipbd.org/${staff["user_photo"]}",
                })
            .toList();
      }
    } catch (e) {
      print("Error fetching staff photos: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to set loading state
  void _setLoading(bool value) {
    if (_isLoading == value) return; // Prevent unnecessary state updates
    _isLoading = value;
    notifyListeners();
  }
}
