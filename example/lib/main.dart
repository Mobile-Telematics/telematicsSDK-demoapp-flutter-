import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/title_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TelematicsSDK Example',
      home: TitleScreen(),
    );
  }
}
