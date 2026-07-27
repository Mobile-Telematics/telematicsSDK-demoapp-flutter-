import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telematics_sdk/telematics_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('telematics_sdk');
  late TrackingApi trackingApi;
  late List<MethodCall> calls;

  setUp(() {
    calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'getProperties' => <String, String>{'policy': 'standard'},
            'getSubUnits' => <String, String>{'vehicle': 'fleet-42'},
            _ => null,
          };
        });
    trackingApi = TrackingApi();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('forwards properties, sub-units, and activity logs', () async {
    await trackingApi.setProperties(properties: {'policy': 'standard'});
    expect(await trackingApi.getProperties(), {'policy': 'standard'});
    await trackingApi.clearProperties();

    await trackingApi.setSubUnits(subUnits: {'vehicle': 'fleet-42'});
    expect(await trackingApi.getSubUnits(), {'vehicle': 'fleet-42'});
    await trackingApi.clearSubUnits();

    await trackingApi.addActivityLog(
      text: 'Trip started manually',
      data: {'tripId': '42'},
    );

    expect(calls.map((call) => call.method), [
      'setProperties',
      'getProperties',
      'clearProperties',
      'setSubUnits',
      'getSubUnits',
      'clearSubUnits',
      'addActivityLog',
    ]);
    expect(calls.first.arguments, {
      'properties': {'policy': 'standard'},
    });
    expect(calls.last.arguments, {
      'text': 'Trip started manually',
      'data': {'tripId': '42'},
    });
  });
}
