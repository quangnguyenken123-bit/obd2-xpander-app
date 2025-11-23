
import 'package:app_chan_doan/diagnostic/diagnostic_page.dart';
import 'package:app_chan_doan/diagnostic/show_dtc.dart';
import 'package:app_chan_doan/menu_page.dart';
import 'package:app_chan_doan/mode_1/mode_1_first_page.dart';
import 'package:app_chan_doan/mode_4/mode_4_first_page.dart';
import 'package:app_chan_doan/mode_6/mode_6_page.dart';
import 'package:app_chan_doan/mode_9/module_information_page.dart';
import 'package:app_chan_doan/mode_obj_info.dart';
import 'package:app_chan_doan/mqtt.dart';
import 'package:app_chan_doan/training_code/steering_wheel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:app_chan_doan/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  mqtt.connect();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
