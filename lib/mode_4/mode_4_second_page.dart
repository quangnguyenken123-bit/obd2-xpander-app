import 'dart:async';
import 'dart:convert';
import 'package:app_chan_doan/mode_1/mode_1_chart.dart';
import 'package:app_chan_doan/mode_4/mode_4_livedata.dart';
import 'package:app_chan_doan/mode_obj_info.dart';
import 'package:flutter/material.dart';
import 'package:app_chan_doan/mqtt.dart';
import '../services/obd_service.dart';

// Hằng số cho HTTP Polling
const Duration POLLING_INTERVAL = Duration(milliseconds: 500);

class Mode4SecondPage extends StatefulWidget {
  const Mode4SecondPage(
      {super.key, required this.Mode4ActInfo, required this.streamDataMonitor});

  final mode_obj_info Mode4ActInfo;
  final List<mode_obj_info> streamDataMonitor;

  @override
  State<StatefulWidget> createState() {
    return _Mode4SecondPageState();
  }
}

class _Mode4SecondPageState extends State<Mode4SecondPage> {
  final OBDService _obdService = OBDService();
  late Timer _timer;
  Map<String, dynamic> _vehicleData = {};
  String _lastError = '';
  bool _isLoading = true;

  Future<void> _fetchVehicleData() async {
    try {
      final data = await _obdService.fetchVehicleData();
      if (mounted) {
        setState(() {
          _vehicleData = data;
          _isLoading = false;
          _lastError = '';
        });
      }
    } catch (e) {
      if (mounted) print("Error fetching data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Gửi lệnh MQTT (nếu cần)
    mqtt.publish('{"mode":${widget.Mode4ActInfo.mode},"action":"start_stream"}');

    _fetchVehicleData();
    _timer = Timer.periodic(POLLING_INTERVAL, (timer) {
      _fetchVehicleData();
    });
  }

  @override
  void dispose() {
    mqtt.publish('{"mode":0}');
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  // === HÀM ÁNH XẠ DỮ LIỆU CẬP NHẬT MỚI ===
  String _getValueFromAPI(String parameterName) {
    if (_vehicleData.isEmpty) return '--';
    String key = parameterName.toLowerCase();

    // Helper rút gọn
    String get(String group, String field, {int fix = 0, String suffix = ''}) {
      if (_vehicleData[group] == null || _vehicleData[group][field] == null) return '--';
      var val = _vehicleData[group][field];
      if (val is num) return val.toStringAsFixed(fix) + suffix;
      return val.toString() + suffix;
    }

    // --- XỬ LÝ RUN TIME ---
    if (key.contains('run time')) {
      var sec = _vehicleData['engine']?['run_time'];
      if (sec != null && sec is num) {
        double min = sec.toDouble() / 60.0;
        return "${min.toStringAsFixed(1)} min";
      }
      return "--";
    }

    // --- FIX CỨNG ---
    if (key.contains('injector') || key.contains('pulse')) return get('engine', 'inject_ms', fix: 2, suffix: ' ms');
    if (key.contains('throttle motor')) return get('actuator', 'throt_motor_pct', fix: 1, suffix: ' %');
    if (key.contains('brake booster')) return get('pressure', 'brake_booster_v', fix: 2, suffix: ' V');

    // --- ĐỘNG CƠ ---
    if (key.contains('rpm')) return get('engine', 'rpm');
    if (key.contains('vehicle speed')) return get('engine', 'speed', suffix: ' km/h');
    if (key.contains('coolant')) return get('engine', 'coolant_temp', suffix: ' °C');
    if (key.contains('intake air')) return get('engine', 'intake_temp', suffix: ' °C');
    if (key.contains('throttle pos')) return get('engine', 'throttle_position', fix: 1, suffix: ' %');
    if (key.contains('engine load')) return get('engine', 'load', fix: 1, suffix: ' %');
    if (key.contains('timing')) return get('engine', 'timing_advance', fix: 1, suffix: ' °');

    // --- NHIÊN LIỆU ---
    if (key.contains('lambda')) return get('air_fuel', 'lambda', fix: 3);
    if (key.contains('short term')) return get('air_fuel', 'stf', fix: 1, suffix: ' %');
    if (key.contains('long term')) return get('air_fuel', 'ltf', fix: 1, suffix: ' %');

    // --- ÁP SUẤT ---
    if (key.contains('map') || key.contains('manifold')) return get('pressure', 'map', suffix: ' kPa');
    if (key.contains('barometric')) return get('pressure', 'baro', suffix: ' kPa');

    // --- ĐIỆN & CẢM BIẾN ---
    if (key.contains('o2') && key.contains('1')) return get('sensors', 'o2_front_v', fix: 2, suffix: ' V');
    if (key.contains('o2') && key.contains('2')) return get('sensors', 'o2_rear_v', fix: 2, suffix: ' V');
    if (key.contains('control module')) return get('others', 'control_volt', fix: 2, suffix: ' V');

    // --- MITSUBISHI STATUS ---
    if (key.contains('ac switch')) return get('mitsubishi', 'ac_switch');
    if (key.contains('compressor') || key.contains('ac relay')) return get('mitsubishi', 'ac_relay');
    if (key.contains('fuel pump')) return get('mitsubishi', 'fuel_pump');

    return '--';
  }

  @override
  Widget build(BuildContext context) {
    List<mode_obj_info> temp = List.from(widget.streamDataMonitor.where((element) => element.status));
    bool isConnected = _vehicleData.isNotEmpty && _vehicleData['engine'] != null;

    if (_isLoading && _vehicleData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.Mode4ActInfo.name), backgroundColor: const Color.fromARGB(255, 145, 220, 255)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.Mode4ActInfo.name),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        leading: BackButton(onPressed: () {
          mqtt.publish('{"mode":0}');
          for (var item in widget.streamDataMonitor) { item.status = false; }
          Navigator.of(context).pop();
        }, color: Colors.black),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: Colors.grey, height: 2.0)),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(child: Text('Testing: ${widget.Mode4ActInfo.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: isConnected ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(12)),
                  child: Text(isConnected ? 'Live' : 'No Data', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List Data
          Expanded(
            child: temp.isEmpty
                ? const Center(child: Text("No PIDs selected. Tap 'Monitor' to add."))
                : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: temp.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 5, child: Text(temp[index].name, style: const TextStyle(fontSize: 16))),
                      Expanded(flex: 3, child: Text(
                        _getValueFromAPI(temp[index].name),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent, fontFamily: 'monospace'),
                        textAlign: TextAlign.right,
                      )),
                      const SizedBox(width: 10),
                      IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChartWidget(chartValue: temp[index]))),
                          icon: const Icon(Icons.show_chart, color: Colors.purple))
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))]),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('Select Monitor PIDs'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Mode4Livedata(mode4Info: widget.Mode4ActInfo, checkboxValue: widget.streamDataMonitor))),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: ElevatedButton(
                      onPressed: () => mqtt.publish('{"mode":${widget.Mode4ActInfo.mode},"value":${widget.Mode4ActInfo.pri_stat_1},"key":1}'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: const Text('ACTIVATE (ON)', style: TextStyle(fontWeight: FontWeight.bold)),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(
                      onPressed: () => mqtt.publish('{"mode":${widget.Mode4ActInfo.mode},"value":${widget.Mode4ActInfo.pri_stat_1},"key":0}'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: const Text('DEACTIVATE (OFF)', style: TextStyle(fontWeight: FontWeight.bold)),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}