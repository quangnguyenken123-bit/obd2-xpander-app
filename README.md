# 🚗 Mitsubishi Xpander OBD2 Diagnostic App

Flutter app for real-time OBD2 monitoring of Mitsubishi Xpander with ESP32 HTTP API.

## 📱 Features
- **Real-time OBD2 data** via HTTP REST API
- **Mitsubishi-specific parameters** (Pressure sensors)
- **Multi-mode interface** (Live Data, Diagnostic, GPS, Module Info)
- **Firebase-free authentication**
- **ESP32 + MCP2515 CAN integration**

## 🛠️ Setup

### Flutter App
```bash
# Clone repository
git clone https://github.com/quangnguyenken123-bit/obd2-xpander-app.git
cd obd2-xpander-app

# Install dependencies
flutter pub get

# Run app
flutter run
```

### ESP32 Hardware
- Upload ESP32 code from `/esp32_code` folder
- Connect to WiFi: `OBD-Xpander-AP` (password: `12345678`)
- Access API: `http://192.168.4.1`

## 📡 API Endpoints
- `http://192.168.4.1/api/vehicle` - All vehicle data
- `http://192.168.4.1/api/engine` - Engine parameters  
- `http://192.168.4.1/api/pressure` - Pressure data
- `http://192.168.4.1/api/status` - System status

## 🎯 App Modes
- **Mode 1**: OBD Test & Diagnostic
- **Mode 4**: Live Data Stream (HTTP API)
- **Mode 6**: GPS Tracking
- **Mode 9**: Module Information

## 👥 Team Members
- **Quang Nguyen** - Project Lead & Development

## 🔧 Technical Stack
- **Frontend**: Flutter (Dart)
- **Backend**: ESP32 (C++) + HTTP REST API
- **Protocol**: CAN Bus, OBD2, UDS
- **Hardware**: MCP2515, Mitsubishi Xpander

## 📄 License
MIT License - See LICENSE file for details
