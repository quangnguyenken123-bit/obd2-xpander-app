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
  bool isConnected = false;
  bool isLoading = true;
  String connectionStatus = 'Đang kiểm tra kết nối...';

  @override
  void initState() {
    super.initState();
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    await _checkConnection();
    if (isConnected) {
      _startDataPolling();
    }
  }

  Future<void> _checkConnection() async {
    setState(() {
      isLoading = true;
      connectionStatus = 'Đang kiểm tra kết nối...';
    });

    final connectionResult = await obdService.checkDetailedConnection();

    setState(() {
      isConnected = connectionResult['connected'] ?? false;
      connectionStatus = connectionResult['message'] ?? 'Lỗi không xác định';
      isLoading = false;
    });
  }

  void _startDataPolling() {
    Future.delayed(Duration.zero, () async {
      while (isConnected) {
        try {
          final data = await obdService.fetchVehicleData();
          if (mounted) {
            setState(() {
              vehicleData = data;
            });
          }
          await Future.delayed(Duration(milliseconds: 500));
        } catch (e) {
          print('Error fetching data: $e');
          if (mounted) {
            setState(() {
              isConnected = false;
              connectionStatus = 'Mất kết nối tới OBD2 Device';
            });
          }
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HTTP Live Data'),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 2.0,
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkConnection,
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        child: Icon(Icons.refresh, color: Colors.black),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              connectionStatus,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (!isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.red),
            SizedBox(height: 20),
            Text(
              connectionStatus,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Vui lòng kết nối WiFi:\nSSID: OBD-Xpander-AP\nPassword: 12345678',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 145, 220, 255),
                foregroundColor: Colors.black,
              ),
              child: Text('Thử kết nối lại'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildConnectionStatusCard(),
        SizedBox(height: 16),
        _buildDataCard(
          'Thông số động cơ',
          [
            _buildDataRow('RPM', '${vehicleData['engine']?['rpm']?.toStringAsFixed(0) ?? '0'} RPM'),
            _buildDataRow('Tốc độ', '${vehicleData['engine']?['speed']?.toStringAsFixed(0) ?? '0'} km/h'),
            _buildDataRow('Nhiệt độ động cơ', '${vehicleData['engine']?['coolant_temp']?.toStringAsFixed(1) ?? '0'}°C'),
            _buildDataRow('Nhiệt độ khí nạp', '${vehicleData['engine']?['intake_temp']?.toStringAsFixed(1) ?? '0'}°C'),
            _buildDataRow('Bướm ga', '${vehicleData['engine']?['throttle_position']?.toStringAsFixed(1) ?? '0'}%'),
            _buildDataRow('Tải động cơ', '${vehicleData['engine']?['load']?.toStringAsFixed(1) ?? '0'}%'),
            _buildDataRow('Góc đánh lửa', '${vehicleData['engine']?['timing_advance']?.toStringAsFixed(1) ?? '0'}°'),
          ],
        ),
        SizedBox(height: 16),
        _buildDataCard(
          'Áp suất',
          [
            _buildDataRow('Trước bướm ga', '${vehicleData['pressure']?['pre_throttle']?.toStringAsFixed(1) ?? '0'} kPa'),
            _buildDataRow('Sau bướm ga', '${vehicleData['pressure']?['post_throttle']?.toStringAsFixed(1) ?? '0'} kPa'),
            _buildDataRow('Áp suất tuyệt đối', '${vehicleData['pressure']?['absolute']?.toStringAsFixed(1) ?? '0'} kPa'),
            _buildDataRow('Áp suất boost', '${vehicleData['pressure']?['boost']?.toStringAsFixed(1) ?? '0'} kPa'),
          ],
        ),
        SizedBox(height: 16),
        _buildDataCard(
          'Nhiên liệu & Khí thải',
          [
            _buildDataRow('Lưu lượng khí nạp (MAF)', '${vehicleData['air_fuel']?['maf']?.toStringAsFixed(1) ?? '0'} g/s'),
            _buildDataRow('Tỷ lệ Lambda', '${vehicleData['air_fuel']?['lambda']?.toStringAsFixed(2) ?? '0'}'),
            _buildDataRow('Hiệu chỉnh nhiên liệu ngắn hạn', '${vehicleData['air_fuel']?['short_term_fuel']?.toStringAsFixed(1) ?? '0'}%'),
            _buildDataRow('Hiệu chỉnh nhiên liệu dài hạn', '${vehicleData['air_fuel']?['long_term_fuel']?.toStringAsFixed(1) ?? '0'}%'),
          ],
        ),
        SizedBox(height: 16),
        _buildDataCard(
          'Cảm biến Oxy',
          [
            _buildDataRow('Cảm biến O2 1', '${vehicleData['sensors']?['o2_1']?.toStringAsFixed(2) ?? '0'} V'),
            _buildDataRow('Cảm biến O2 2', '${vehicleData['sensors']?['o2_2']?.toStringAsFixed(2) ?? '0'} V'),
          ],
        ),
      ],
    );
  }

  Widget _buildConnectionStatusCard() {
    return Card(
      color: isConnected ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: isConnected ? Colors.green : Colors.red,
              size: 30,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? 'Đã kết nối' : 'Mất kết nối',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isConnected ? Colors.green : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    connectionStatus,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}