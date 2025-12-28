// lib/mode_obj_info.dart

class mode_obj_info {
  // Biến này có thể null, dùng late hoặc ? tùy phiên bản Dart,
  // nhưng giữ nguyên như code gốc của bạn để an toàn.
  late var value;

  late String name;
  late String firebase_name; // Giữ nguyên trường này để không lỗi page khác
  late int mode;
  late int pri_stat_1; // PID hoặc ID chính
  late int pri_stat_2; // ID phụ hoặc Bitmask

  bool status = false;

  mode_obj_info({
    required this.name,
    required this.mode,
    required this.firebase_name,
    required this.pri_stat_1,
    required this.pri_stat_2
  });
}

// ============================================================
// DANH SÁCH LIVE DATA (MODE 01 & MODE 21)
// ============================================================
List<mode_obj_info> listMode1info = [
  // --- A. STANDARD PIDs (Giữ nguyên cũ) ---
  mode_obj_info(
    name: "Calculated Engine Load",
    mode: 0x01,
    firebase_name: "2000/41/CEL",
    pri_stat_1: 0x04, // Sửa lại đúng PID chuẩn (04) thay vì 0
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Engine Coolant Temperature",
    mode: 0x01,
    firebase_name: "2000/41/ET",
    pri_stat_1: 0x05, // PID 05
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Short Term Fuel Trim - Bank 1",
    mode: 0x01,
    firebase_name: "2000/41/STFT1",
    pri_stat_1: 0x06, // PID 06
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Long Term Fuel Trim - Bank 1",
    mode: 0x01,
    firebase_name: "2000/41/LTFT1",
    pri_stat_1: 0x07, // PID 07
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Intake Manifold Absolute Pressure",
    mode: 0x01,
    firebase_name: "2000/41/IMAP",
    pri_stat_1: 0x0B, // PID 0B
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Engine Speed",
    mode: 0x01,
    firebase_name: "2000/41/ES",
    pri_stat_1: 0x0C, // PID 0C
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Vehicle Speed",
    mode: 0x01,
    firebase_name: "2000/41/VS",
    pri_stat_1: 0x0D, // PID 0D
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Timing Advance",
    mode: 0x01,
    firebase_name: "2000/41/TA",
    pri_stat_1: 0x0E, // PID 0E
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Intake Air Temperature",
    mode: 0x01,
    firebase_name: "2000/41/IAT",
    pri_stat_1: 0x0F, // PID 0F
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Throttle Position",
    mode: 0x01,
    firebase_name: "2000/41/TP",
    pri_stat_1: 0x11, // PID 11
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Run Time Since Start",
    mode: 0x01,
    firebase_name: "RUNTM",
    pri_stat_1: 0x1F, // PID chuẩn 1F
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Absolute Barometric Pressure",
    mode: 0x01,
    firebase_name: "2000/41/ABP",
    pri_stat_1: 0x33, // PID 33
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Control Module Voltage",
    mode: 0x01,
    firebase_name: "2000/41/CMV",
    pri_stat_1: 0x42, // PID 42
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Absolute Load Value",
    mode: 0x01,
    firebase_name: "2000/41/ALV",
    pri_stat_1: 0x43, // PID 43
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Fuel Type",
    mode: 0x01,
    firebase_name: "2000/41/FT",
    pri_stat_1: 0x51, // PID 51
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Ambient Air Temperature",
    mode: 0x01,
    firebase_name: "2000/41/AAT",
    pri_stat_1: 0x46, // PID 46
    pri_stat_2: 0,
  ),

  // --- B. MITSUBISHI EXTENDED PIDs (MODE 21) ---
  // (Thêm mới để khớp với code ESP32)

  mode_obj_info(
    name: "Injector Pulse Width (ms)",
    mode: 0x01,
    firebase_name: "INJ",
    pri_stat_1: 0, // 0 = Lấy từ JSON fix cứng
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Throttle Motor Actuator (%)",
    mode: 0x01,
    firebase_name: "THROT",
    pri_stat_1: 0,
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Brake Booster Voltage (V)",
    mode: 0x01,
    firebase_name: "BRAKE",
    pri_stat_1: 0,
    pri_stat_2: 0,
  ),

  // Nhóm A/C (Điều hòa)
  mode_obj_info(
    name: "A/C Pressure (MPa)",
    mode: 0x21,
    firebase_name: "2000/21/ACPRESS",
    pri_stat_1: 0x15, // PID 15 (Mapping ESP32)
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "A/C Sensor (mV)",
    mode: 0x21,
    firebase_name: "2000/21/ACSENS",
    pri_stat_1: 0x06, // PID 06 (Mapping ESP32)
    pri_stat_2: 0,
  ),
  // Nhóm Công tắc (Switches)
  mode_obj_info(
    name: "A/C Switch Status",
    mode: 0x21,
    firebase_name: "2000/21/SW/AC",
    pri_stat_1: 0x1D, // PID 1D
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Clutch Switch",
    mode: 0x21,
    firebase_name: "2000/21/SW/CLUTCH",
    pri_stat_1: 0x1D,
    pri_stat_2: 1,
  ),
  mode_obj_info(
    name: "Fuel Pump Relay Status",
    mode: 0x21,
    firebase_name: "2000/21/RLY/FUEL",
    pri_stat_1: 0x1E, // PID 1E
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "A/C Compressor Relay",
    mode: 0x21,
    firebase_name: "2000/21/RLY/AC",
    pri_stat_1: 0x1E,
    pri_stat_2: 1,
  ),
];

// ============================================================
// DANH SÁCH ACTUATORS (MODE 4 - ACTIVE TEST)
// ============================================================
// Cập nhật Mode thành 0x21 (cho Mitsubishi) để ESP32 hiểu
List<mode_obj_info> listMode4info = [
  mode_obj_info(
    name: "Injector Cut (All)",
    mode: 0x21, // Dùng Service 21
    firebase_name: "2000/70/INJ/ALL",
    pri_stat_1: 0x05, // ID Gốc
    pri_stat_2: 0,
  ),
  mode_obj_info(
    name: "Fuel Pump Test",
    mode: 0x21,
    firebase_name: "2000/70/ACT/FUEL",
    pri_stat_1: 0x1E, // ID Gốc Relay
    pri_stat_2: 0x04, // Bitmask (Ví dụ)
  ),
  mode_obj_info(
    name: "A/C Compressor Relay",
    mode: 0x21,
    firebase_name: "2000/70/ACT/AC",
    pri_stat_1: 0x1E,
    pri_stat_2: 0x01,
  ),
  mode_obj_info(
    name: "Cooling Fan High",
    mode: 0x21,
    firebase_name: "2000/70/ACT/FANH",
    pri_stat_1: 0x1E, // Giả sử cùng nhóm Relay
    pri_stat_2: 0x02,
  ),
];

// ============================================================
// CÁC LIST KHÁC (GIỮ NGUYÊN)
// ============================================================

List<mode_obj_info> listMode6info = [
  mode_obj_info(
    name: "O2 Sensor Bank 1 Sensor 1",
    mode: 0x06,
    firebase_name: "2000/46/OSBS",
    pri_stat_1: 0,
    pri_stat_2: 0,
  ),
  // ... (Bạn có thể giữ nguyên danh sách dài nếu muốn)
];

List<mode_obj_info> listMode3info = [
  mode_obj_info(
    name: "Stored DTC",
    mode: 0x03,
    firebase_name: "2000/43/DTC",
    pri_stat_1: 0,
    pri_stat_2: 0,
  ),
];

List<mode_obj_info> listMode7info = [
  mode_obj_info(
    name: "Pending DTC",
    mode: 0x07,
    firebase_name: "2000/47/DTC",
    pri_stat_1: 0,
    pri_stat_2: 0,
  ),
];

List<mode_obj_info> listMode9info = [
  mode_obj_info(
    name: "VIN",
    mode: 0x09,
    firebase_name: "2000/49/VIN",
    pri_stat_1: 0,
    pri_stat_2: 0,
  ),
];