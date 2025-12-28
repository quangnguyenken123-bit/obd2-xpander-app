import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowDTC extends StatefulWidget {
  final String pageTitle;
  final String apiUrl;

  const ShowDTC({
    super.key,
    required this.pageTitle,
    required this.apiUrl
  });

  @override
  State<ShowDTC> createState() => _ShowDTCState();
}

class _ShowDTCState extends State<ShowDTC> {
  String _dtcResult = "Đang kết nối...";
  bool _isLoading = true;
  Color _statusColor = Colors.grey; // Mặc định màu xám

  // URL API Xóa lỗi (cố định)
  final String _clearApiUrl = "http://192.168.4.1/api/dtc/clear";

  @override
  void initState() {
    super.initState();
    _fetchDTC();
  }

  // --- HÀM ĐỌC LỖI (GET) ---
  Future<void> _fetchDTC() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _dtcResult = "Đang quét lỗi..."; });

    try {
      // Timeout 5s là hợp lý với ESP32
      final response = await http.get(Uri.parse(widget.apiUrl)).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String codes = data['codes'] ?? "";

        setState(() {
          _isLoading = false;

          // Logic kiểm tra kết quả từ ESP32
          if (codes == "No Error" || codes == "" || codes == "null") {
            _dtcResult = "Xe hoạt động bình thường.\nKhông phát hiện mã lỗi.";
            _statusColor = Colors.green;
          } else {
            // Nếu có lỗi (Ví dụ: P0267, P0301) -> Thay dấu phẩy bằng xuống dòng cho đẹp
            _dtcResult = codes.replaceAll(", ", "\n");
            _statusColor = Colors.red;
          }
        });
      } else {
        setState(() {
          _dtcResult = "Lỗi phản hồi từ ESP32\nCode: ${response.statusCode}";
          _isLoading = false;
          _statusColor = Colors.orange;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dtcResult = "Không kết nối được xe!\nVui lòng kiểm tra WiFi.";
          _isLoading = false;
          _statusColor = Colors.grey;
        });
      }
    }
  }

  // --- HÀM XÓA LỖI (POST) ---
  Future<void> _clearDTC() async {
    // 1. Hỏi xác nhận
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Xác nhận xóa lỗi?"),
          content: const Text("Lệnh này sẽ xóa toàn bộ mã lỗi (Stored & Pending) trong ECU.\n\n⚠️ YÊU CẦU: Bật chìa khóa ON, nhưng KHÔNG nổ máy."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Xóa Ngay"),
            ),
          ],
        )
    ) ?? false;

    if (!confirm) return;

    if (!mounted) return;
    setState(() { _isLoading = true; _dtcResult = "Đang gửi lệnh xóa..."; });

    try {
      // 2. Gửi lệnh POST tới ESP32
      // ESP32 sẽ thực hiện "Xóa Kép" (Mode 04 + Mode 14) như chúng ta đã code
      final response = await http.post(Uri.parse(_clearApiUrl)).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Đã gửi lệnh xóa thành công!"),
              backgroundColor: Colors.green,
            )
        );

        // 3. Đợi 2 giây cho ECU xử lý rồi tự quét lại
        await Future.delayed(const Duration(seconds: 2));
        _fetchDTC();
      } else {
        setState(() {
          _isLoading = false;
          _dtcResult = "Gửi lệnh thất bại!\nCode: ${response.statusCode}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _dtcResult = "Lỗi kết nối khi xóa!";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle),
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        actions: [
          // Nút Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Quét lại",
            onPressed: _fetchDTC,
          ),
          // Nút Xóa Lỗi (Hiện cho cả Stored và Pending vì lệnh Clear xóa cả 2)
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            tooltip: "Xóa mã lỗi",
            onPressed: _clearDTC,
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isLoading
                  ? Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Đang giao tiếp với ECU...")
                ],
              )
                  : Expanded( // Dùng Expanded để nội dung căn giữa đẹp hơn
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: _statusColor, width: 4)
                      ),
                      child: Icon(
                        _statusColor == Colors.green ? Icons.check : Icons.warning_amber_rounded,
                        color: _statusColor,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _dtcResult,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _statusColor,
                        letterSpacing: 1.5, // Giãn chữ ra cho giống mã lỗi chuẩn
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              if (!_isLoading)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.grey),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Để xóa lỗi triệt để: Hãy bật chìa khóa ON nhưng KHÔNG nổ máy trước khi bấm nút Xóa.",
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}