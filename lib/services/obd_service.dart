import 'dart:convert';
import 'package:http/http.dart' as http;

class OBDService {
  static const String baseUrl = "http://192.168.4.1";

  // Lấy toàn bộ dữ liệu xe từ ESP32
  Future<Map<String, dynamic>> fetchVehicleData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/vehicle'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load vehicle data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Lấy dữ liệu engine từ ESP32
  Future<Map<String, dynamic>> fetchEngineData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/engine'),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load engine data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Lấy dữ liệu áp suất từ ESP32
  Future<Map<String, dynamic>> fetchPressureData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/pressure'),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load pressure data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Kiểm tra kết nối tới ESP32
  Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/status'),
      ).timeout(Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      print('Connection check failed: $e');
      return false;
    }
  }

  // Kiểm tra kết nối chi tiết (trả về thông báo lỗi)
  Future<Map<String, dynamic>> checkDetailedConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/status'),
      ).timeout(Duration(seconds: 3));

      if (response.statusCode == 200) {
        return {
          'connected': true,
          'message': 'Kết nối thành công tới OBD2 Device',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'connected': false,
          'message': 'Lỗi kết nối: ${response.statusCode}',
          'error': 'HTTP Error',
        };
      }
    } catch (e) {
      return {
        'connected': false,
        'message': 'Không thể kết nối tới OBD2 Device',
        'error': e.toString(),
      };
    }
  }
}