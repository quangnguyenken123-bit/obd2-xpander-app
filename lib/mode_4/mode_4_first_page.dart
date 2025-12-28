import 'package:app_chan_doan/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:app_chan_doan/mode_obj_info.dart';
import 'package:app_chan_doan/mode_4/mode_4_second_page.dart';

class Mode4FirstPage extends StatelessWidget {
  const Mode4FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Màu nền nhẹ
      appBar: AppBar(
        title: const Text('Actuators Test List'), // Đổi tên cho rõ nghĩa
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            // Gửi lệnh reset mode về 0 khi thoát
            mqtt.publish('{"mode":0}');
            Navigator.of(context).pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 2.0,
          ),
        ),
      ),
      // Dùng ListView.builder hiệu năng tốt hơn
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: listMode4info.length,
        itemBuilder: (BuildContext context, int index) {
          final item = listMode4info[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_input_component, color: Colors.blueAccent),
              ),
              title: Text(
                item.name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              subtitle: Text(
                "ID: ${item.pri_stat_1.toRadixString(16).toUpperCase()}", // Hiển thị ID Hex để dễ debug
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                // Chuyển sang trang điều khiển chi tiết
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Mode4SecondPage(
                      Mode4ActInfo: item,
                      // Truyền danh sách thông số giám sát (listMode1info)
                      // Lưu ý: listMode1info cần chứa các PID mới mà ta đã thêm
                      streamDataMonitor: listMode1info,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}