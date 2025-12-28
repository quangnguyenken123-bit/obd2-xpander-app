import 'dart:convert';
import 'dart:async'; // Cần để dùng TimeoutException
import 'package:http/http.dart' as http;

class OBDService {
  // Địa chỉ IP của ESP32 (chế độ Access Point)
  static const String baseUrl = "http://192.168.4.1";

  // 1. LẤY TOÀN BỘ DỮ LIỆU (Endpoint chính)
  // Code ESP32 gom tất cả vào /api/vehicle, nên ta chỉ cần hàm này là đủ.
  Future<Map<String, dynamic>> fetchVehicleData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/vehicle'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 4)); // Timeout 4s

      if (response.statusCode == 200) {
        // Giải mã JSON trả về
        return jsonDecode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  // 2. LẤY SỐ VIN
  Future<String> fetchVIN() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/vin'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['vin'] ?? "Unknown";
      }
      return "Error reading VIN";
    } catch (e) {
      return "Connection Error";
    }
  }

  // 3. KIỂM TRA KẾT NỐI (Dùng /api/vehicle thay cho /api/status đã bị xóa)
  // Hàm này trả về Map chi tiết để UI dễ hiển thị lỗi
  Future<Map<String, dynamic>> checkDetailedConnection() async {
    try {
      // Thử gọi API chính với timeout ngắn (3s) để xem ESP32 có sống không
      final response = await http.get(
        Uri.parse('$baseUrl/api/vehicle'),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return {
          'connected': true,
          'message': 'Đã kết nối thành công!',
          // Trả về dữ liệu luôn để đỡ phải gọi lại lần nữa
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'connected': false,
          'message': 'Lỗi HTTP: ${response.statusCode}',
        };
      }
    } on TimeoutException catch (_) {
      return {
        'connected': false,
        'message': 'Quá thời gian chờ (Timeout). Kiểm tra WiFi.',
      };
    } catch (e) {
      return {
        'connected': false,
        'message': 'Không tìm thấy thiết bị (192.168.4.1)',
        'error': e.toString(),
      };
    }
  }

  // 4. XÓA MÃ LỖI (Clear DTC)
  Future<bool> clearDTC() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/dtc/clear'),
      ).timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi xóa mã lỗi: $e");
      return false;
    }
  }
}