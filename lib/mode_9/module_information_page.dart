import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Thêm thư viện lưu trữ

class ModuleInformationPage extends StatefulWidget {
  const ModuleInformationPage({super.key});

  @override
  State<ModuleInformationPage> createState() => _ModuleInformationPageState();
}

class _ModuleInformationPageState extends State<ModuleInformationPage> {
  // Biến lưu số VIN
  String _vinNumber = "Đang tải dữ liệu...";
  bool _isLoading = true;

  // URL của ESP32
  final String _esp32Url = 'http://192.168.4.1/api/vin';

  @override
  void initState() {
    super.initState();
    // 2. Quy trình khởi động:
    // B1: Tải VIN cũ đã lưu (nếu có) để hiện ngay cho người dùng đỡ chờ
    _loadSavedData();

    // B2: Thầm lặng kết nối tới ESP32 để kiểm tra xem có số VIN mới không
    _fetchVinFromEsp32();
  }

  // --- HÀM TẢI DỮ LIỆU CŨ (OFFLINE) ---
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedVin = prefs.getString('saved_vin'); // Lấy dữ liệu từ bộ nhớ

    if (savedVin != null && savedVin.isNotEmpty) {
      setState(() {
        _vinNumber = savedVin;
        _isLoading = false; // Đã có dữ liệu để xem rồi thì tắt loading đi
      });
    } else {
      setState(() {
        _vinNumber = "Chưa có dữ liệu VIN (Cần kết nối xe)";
      });
    }
  }

  // --- HÀM ĐỌC TỪ XE VÀ LƯU LẠI (ONLINE) ---
  Future<void> _fetchVinFromEsp32() async {
    if (_vinNumber.contains("Chưa có") || _vinNumber.contains("Đang tải")) {
      setState(() => _isLoading = true);
    }

    try {
      final response = await http.get(Uri.parse(_esp32Url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String rawVin = data['vin'] ?? "";

        // 1. VỆ SINH CHUỖI: Cắt bỏ khoảng trắng đầu đuôi và ký tự xuống dòng
        String newVin = rawVin.trim();

        print("ESP32 gửi về: '$newVin' (Độ dài: ${newVin.length})"); // In ra Log để kiểm tra

        // 2. ĐIỀU KIỆN LƯU CHẶT CHẼ HƠN
        // VIN chuẩn là 17 ký tự. Nếu > 10 và không chứa từ khóa báo lỗi của ESP32 thì mới lưu
        bool isValidVin = newVin.length > 10 &&
            !newVin.toLowerCase().contains("thiếu") &&
            !newVin.toLowerCase().contains("không");

        if (isValidVin) {
          final prefs = await SharedPreferences.getInstance();

          // Lưu trước, hiển thị sau (để chắc chắn đã lệnh lưu được tung ra)
          bool saveResult = await prefs.setString('saved_vin', newVin);
          print("Trạng thái lưu vào bộ nhớ: $saveResult"); // Phải in ra true mới là lưu được

          setState(() {
            _vinNumber = newVin;
            _isLoading = false;
          });

          if (saveResult && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã lưu VIN: $newVin'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Nếu VIN ngắn quá hoặc báo lỗi -> Chỉ hiện, KHÔNG LƯU
          print("Dữ liệu không đủ tiêu chuẩn để lưu: '$newVin'");
          setState(() {
            _vinNumber = newVin; // Vẫn hiện cho người dùng biết
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      setState(() => _isLoading = false);
      if (_vinNumber.contains("Đang tải") || _vinNumber.contains("Chưa có")) {
        setState(() {
          _vinNumber = "Không kết nối được xe.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Module Information'),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 2.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchVinFromEsp32(); // Bấm nút để ép đọc lại từ xe
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle Identification Number (VIN):',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    _isLoading
                        ? const Center(child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(),
                    ))
                        : SelectableText( // Dùng SelectableText để copy được
                      _vinNumber,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                          letterSpacing: 1.2 // Giãn chữ ra chút cho giống số VIN thật
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dòng thông báo trạng thái
            const Text(
              "* Số VIN sẽ được tự động lưu lại vào bộ nhớ máy.",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}