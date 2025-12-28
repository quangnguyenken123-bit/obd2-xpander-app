import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_chan_doan/services/obd_service.dart';

class Mode4HttpLiveData extends StatefulWidget {
  const Mode4HttpLiveData({super.key});

  @override
  _Mode4HttpLiveDataState createState() => _Mode4HttpLiveDataState();
}

class _Mode4HttpLiveDataState extends State<Mode4HttpLiveData> {
  final OBDService obdService = OBDService();
  Map<String, dynamic> vehicleData = {};

  // Trạng thái kết nối
  bool isConnected = false;
  bool isLoading = true;
  String connectionStatus = 'Đang kết nối tới xe...';

  @override
  void initState() {
    super.initState();
    _startDataPolling();
  }

  // Hàm chạy liên tục để lấy JSON từ ESP32
  void _startDataPolling() async {
    await Future.delayed(Duration.zero); // Đợi UI dựng xong

    while (mounted) {
      try {
        final data = await obdService.fetchVehicleData();
        if (mounted) {
          setState(() {
            vehicleData = data;
            isConnected = true;
            isLoading = false;
            connectionStatus = "Đã kết nối";
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            // Giữ lại dữ liệu cũ để không nháy màn hình, chỉ báo trạng thái
            isConnected = false;
            connectionStatus = "Đang chờ dữ liệu...";
          });
        }
      }
      // Tần suất lấy mẫu: 200ms
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  // Hàm refresh thủ công
  void _manualRefresh() {
    setState(() {
      connectionStatus = "Đang làm mới...";
    });
  }

  // === Hàm Helper: Lấy dữ liệu an toàn từ JSON ===
  String _getVal(String group, String key, {String suffix = "", int fixed = 1}) {
    if (vehicleData.isEmpty || vehicleData[group] == null) return "---";
    var val = vehicleData[group][key];
    if (val == null) return "---";

    // --- XỬ LÝ RUN TIME (MỚI) ---
    // Đổi giây sang giờ:phút
    if (key == 'run_time') {
      double seconds = (val is num) ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
      double minutes = seconds / 60.0;
      int hrs = minutes ~/ 60;
      int mins = minutes.toInt() % 60;
      return "${hrs}h ${mins}m"; // Ví dụ: 0h 12m
    }

    if (val is num) {
      if (fixed == 0) return val.toInt().toString() + suffix;
      return val.toStringAsFixed(fixed) + suffix;
    }
    return val.toString() + suffix;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Xpander Live Parameters'),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        leading: BackButton(
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(isConnected ? Icons.wifi : Icons.wifi_off,
                color: isConnected ? Colors.green[800] : Colors.red),
            onPressed: _manualRefresh,
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 2.0),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading && vehicleData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(connectionStatus),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        _buildConnectionStatusCard(),
        const SizedBox(height: 10),

        // === 1. ĐỘNG CƠ & VẬN HÀNH (10 Thông số) ===
        _buildDataCard('Động cơ & Vận hành', Icons.speed, Colors.redAccent, [
          _buildDataRow('Vòng tua (RPM)', _getVal('engine', 'rpm', fixed: 0, suffix: ' rpm'), highlight: true),
          _buildDataRow('Tốc độ xe', _getVal('engine', 'speed', fixed: 0, suffix: ' km/h')),
          _buildDataRow('Nhiệt độ nước (ECT)', _getVal('engine', 'coolant_temp', fixed: 0, suffix: ' °C')),
          _buildDataRow('Nhiệt độ khí nạp (IAT)', _getVal('engine', 'intake_temp', fixed: 0, suffix: ' °C')),
          _buildDataRow('Góc đánh lửa', _getVal('engine', 'timing_advance', fixed: 1, suffix: ' °')),
          _buildDataRow('Tải động cơ', _getVal('engine', 'load', fixed: 1, suffix: ' %')),
          _buildDataRow('Tải tính toán', _getVal('others', 'calc_load', fixed: 1, suffix: ' %')),
          // MỚI: RUN TIME
          _buildDataRow('Thời gian nổ máy', _getVal('engine', 'run_time'), highlight: true),
          _buildDataRow('Loại nhiên liệu', _getVal('engine', 'fuel_type')),
        ]),

        const SizedBox(height: 12),

        // === 2. NHIÊN LIỆU & KHÍ NẠP (8 Thông số) ===
        _buildDataCard('Nhiên liệu & Khí nạp', Icons.local_gas_station, Colors.blueAccent, [
          // FIX CỨNG
          _buildDataRow('Thời gian phun', _getVal('engine', 'inject_ms', fixed: 2, suffix: ' ms'), highlight: true),
          _buildDataRow('Lambda', _getVal('air_fuel', 'lambda', fixed: 3)),
          // MỚI: STF
          _buildDataRow('Short Term Fuel', _getVal('air_fuel', 'stf', fixed: 1, suffix: ' %')),
          _buildDataRow('Long Term Fuel', _getVal('air_fuel', 'ltf', fixed: 1, suffix: ' %')),
          _buildDataRow('Áp suất MAP', _getVal('pressure', 'map', fixed: 0, suffix: ' kPa')),
          _buildDataRow('Áp suất khí quyển', _getVal('pressure', 'baro', fixed: 0, suffix: ' kPa')),
          // MỚI: FUEL SYS STATUS
          _buildDataRow('Trạng thái Fuel Sys', _getVal('mitsubishi', 'fuel_sys_status')),
        ]),

        const SizedBox(height: 12),

        // === 3. CƠ CẤU CHẤP HÀNH & PEDAL (5 Thông số) ===
        _buildDataCard('Cơ cấu chấp hành', Icons.settings_input_component, Colors.orange, [
          _buildDataRow('Bướm ga (TPS)', _getVal('engine', 'throttle_position', fixed: 1, suffix: ' %')),
          // FIX CỨNG
          _buildDataRow('Mô tơ bướm ga', _getVal('actuator', 'throt_motor_pct', fixed: 1, suffix: ' %'), highlight: true),
          // FIX CỨNG
          _buildDataRow('Áp suất Bầu phanh', _getVal('pressure', 'brake_booster_v', fixed: 2, suffix: ' V'), highlight: true),
          const Divider(),
          _buildDataRow('Chân ga D', _getVal('others', 'pedal_d', fixed: 1, suffix: ' %')),
          _buildDataRow('Chân ga E', _getVal('others', 'pedal_e', fixed: 1, suffix: ' %')),
        ]),

        const SizedBox(height: 12),

        // === 4. ĐIỆN & CẢM BIẾN O2 (3 Thông số) ===
        _buildDataCard('Điện & O2 Sensors', Icons.electrical_services, Colors.purple, [
          _buildDataRow('Điện áp ECU', _getVal('others', 'control_volt', fixed: 2, suffix: ' V')),
          _buildDataRow('O2 Sensor 1 (Trước)', _getVal('sensors', 'o2_front_v', fixed: 2, suffix: ' V')),
          _buildDataRow('O2 Sensor 2 (Sau)', _getVal('sensors', 'o2_rear_v', fixed: 2, suffix: ' V')),
        ]),

        const SizedBox(height: 12),

        // === 5. TRẠNG THÁI MITSUBISHI (6 Thông số) ===
        _buildDataCard('Trạng thái (Mitsubishi)', Icons.toggle_on, Colors.teal, [
          _buildDataRow('Yêu cầu A/C', _getVal('mitsubishi', 'ac_switch'), isStatus: true),
          _buildDataRow('Relay Lốc lạnh', _getVal('mitsubishi', 'ac_relay'), isStatus: true),
          _buildDataRow('Relay Bơm xăng', _getVal('mitsubishi', 'fuel_pump'), isStatus: true),
          _buildDataRow('Relay Đề (Starter)', _getVal('mitsubishi', 'starter_rly'), isStatus: true),
          _buildDataRow('Tín hiệu Đề', _getVal('mitsubishi', 'cranking'), isStatus: true),
          _buildDataRow('Công tắc Côn', _getVal('mitsubishi', 'clutch_sw'), isStatus: true),
          _buildDataRow('Khóa điện (Ignition)', _getVal('mitsubishi', 'ignition_sw'), isStatus: true),
          _buildDataRow('Nhiệt độ ngoài trời', _getVal('mitsubishi', 'amb_temp', suffix: ' °C')),
        ]),

        const SizedBox(height: 20),
      ],
    );
  }

  // --- WIDGETS CON ---

  Widget _buildConnectionStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(isConnected ? Icons.check_circle : Icons.wifi_off,
              color: isConnected ? Colors.green[800] : Colors.red[800], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isConnected ? 'Kết nối ổn định' : connectionStatus,
              style: TextStyle(
                color: isConnected ? Colors.green[900] : Colors.red[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isConnected)
            const Text("Live", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green))
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isStatus = false, bool highlight = false}) {
    Color valColor = Colors.black87;
    FontWeight valWeight = FontWeight.w600;

    if (isStatus) {
      if (value.contains("ON")) valColor = Colors.green[700]!;
      else if (value.contains("OFF")) { valColor = Colors.grey; valWeight = FontWeight.normal; }
    }

    if (highlight) {
      valColor = Colors.blue[800]!;
      valWeight = FontWeight.bold;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: valWeight,
              fontSize: 15,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }
}