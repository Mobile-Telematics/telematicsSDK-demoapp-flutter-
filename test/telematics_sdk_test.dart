import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telematics_sdk/telematics_sdk.dart';

void main() {
  const channel = MethodChannel('telematics_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
