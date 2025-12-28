import 'package:app_chan_doan/diagnostic/diagnostic_page.dart';
import 'package:app_chan_doan/mode_1/mode_1_first_page.dart';
import 'package:app_chan_doan/mode_4/mode_4_first_page.dart';
import 'package:app_chan_doan/mode_6/mode_6_page.dart';
import 'package:app_chan_doan/mode_9/module_information_page.dart';
import 'package:app_chan_doan/training_code/steering_wheel.dart';
import 'package:flutter/material.dart';
import 'package:app_chan_doan/mode_4/mode_4_http_livedata.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        title: const Text('Functions'),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        padding: const EdgeInsets.all(4.0),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: <Widget>[
          _buildButton(context, "Module Information",
              'assets/images/Module_Information.png', ModuleInformationPage()),
          _buildButton(context, "Read Data Stream",
              'assets/images/Read_Stream_Data.png', Mode1FirstPage()),
          _buildButton(context, "Diagnostic",
              'assets/images/Diagnostic.png', DiagnosticPage()),
          _buildButton(context, "HTTP Live Data",
              'assets/images/Read_Stream_Data.png', Mode4HttpLiveData()),
          _buildButton(context, "Actuators Test",
              'assets/images/Actuators_Test.png', Mode4FirstPage()),
          _buildButton(context, "OBD Test", 
              'assets/images/OBD_Test.png', Mode6Page()),
          // _buildButton(context, "GPS Tracker",
          //     'assets/images/GPS_Tracker.png'),
          _buildButton(context, "Training Code",
              'assets/images/logoBK.png', SteeringWheel()),
        ],
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, String iconPath, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
              color: Color.fromARGB(255, 0, 0, 0),
              width: 3), // White border around the button
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        backgroundColor: Colors.white, // Background color black
        foregroundColor: Colors.black, // Text color white
        elevation: 0, // Optional: adds shadow to the button
        shadowColor: Colors.black.withOpacity(1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 183, 183, 183).withOpacity(0),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            child: Image.asset(iconPath,
                width: 60,
                height: 60), // Image adjusted to not use ColorFiltered
          ),
          SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
