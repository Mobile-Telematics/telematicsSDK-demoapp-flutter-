import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telematics_sdk/telematics_sdk.dart';
import 'package:telematics_sdk/src/native_call_handler.dart';
import 'package:telematics_sdk/src/data/permission_wizard_result.dart';

void main() {
  group('NativeCallHandler', () {
    late NativeCallHandler handler;

    setUp(() {
      handler = NativeCallHandler();
    });

    group('onPermissionWizardClose', () {
      late List<PermissionWizardResult> events;

      setUp(() {
        events = <PermissionWizardResult>[];
      });

      test('emits allGranted', () async {
        handler.onPermissionWizardClose.listen(
          expectAsync1<void, PermissionWizardResult>(events.add),
        );

        await handler.handle(
          const MethodCall(
            'onPermissionWizardResult',
            'WIZARD_RESULT_ALL_GRANTED',
          ),
        );

        expect(events, equals([PermissionWizardResult.allGranted]));
      });

      test('emits notAllGranted', () async {
        handler.onPermissionWizardClose.listen(
          expectAsync1<void, PermissionWizardResult>(events.add),
        );

        await handler.handle(
          const MethodCall(
            'onPermissionWizardResult',
            'WIZARD_RESULT_NOT_ALL_GRANTED',
          ),
        );

        expect(events, equals([PermissionWizardResult.notAllGranted]));
      });

      test('emits all values', () async {
        const wizardResults = [
          'WIZARD_RESULT_ALL_GRANTED',
          'WIZARD_RESULT_NOT_ALL_GRANTED',
          'WIZARD_RESULT_CANCELED',
        ];

        handler.onPermissionWizardClose.listen(
          expectAsync1<void, PermissionWizardResult>(
            events.add,
            count: wizardResults.length,
          ),
        );

        for (final actual in wizardResults) {
          await handler.handle(
            MethodCall(
              'onPermissionWizardResult',
              actual,
            ),
          );
        }

        expect(
            events,
            equals([
              PermissionWizardResult.allGranted,
              PermissionWizardResult.notAllGranted,
              PermissionWizardResult.canceled,
            ]));
      });
    });

    group('lowerPowerMode', () {
      late List<bool> events;

      setUp(() {
        events = <bool>[];
      });

      test('emits true when handles corresponding value', () async {
        handler.lowerPowerMode.listen(
          expectAsync1<void, bool>(events.add),
        );

        await handler.handle(
          const MethodCall('onLowPowerMode', true),
        );

        expect(events, equals([true]));
      });

      test('emits all values', () async {
        const testValues = <bool>[true, false];

        handler.lowerPowerMode.listen(
          expectAsync1<void, bool>(
            events.add,
            count: testValues.length,
          ),
        );

        for (final value in testValues) {
          await handler.handle(
            MethodCall('onLowPowerMode', value),
          );
        }

        expect(events, equals([true, false]));
      });
    });

    group("doesn't break down with empty callbacks:", () {
      test('empty onTagAdd', () async {
        final argument = {
          'status': 'SUCCESS',
          'tag': jsonEncode({'source': 'source', 'tag': 'tag'}),
          'activationTime': 1,
        };

        await handler.handle(MethodCall('onTagAdd', argument));
      });

      test('empty onTagRemove', () async {
        final argument = {
          'status': 'SUCCESS',
          'tag': jsonEncode({'source': 'source', 'tag': 'tag'}),
          'deactivationTime': 1,
        };

        await handler.handle(MethodCall('onTagRemove', argument));
      });

      test('empty onAllTagsRemove', () async {
        final argument = {
          'status': 'SUCCESS',
          'deactivatedTagsCount': 1,
          'time': 2,
        };

        await handler.handle(MethodCall('onAllTagsRemove', argument));
      });

      test('empty onGetTags', () async {
        final argument = {
          'status': 'SUCCESS',
          'tags': List.generate(
            3,
            (index) =>
                jsonEncode({'source': 'source$index', 'tag': 'tag$index'}),
          ),
          'time': 2,
        };

        await handler.handle(MethodCall('onGetTags', argument));
      });
    });

    group('onTagAdd', () {
      late Map<String, Object> result;

      setUp(() {
        handler.onTagAdd = (status, tag, activationTime) {
          result = {
            'status': status,
            'tag': tag,
            'activationTime': activationTime,
          };
        };
      });

      test('emits result with success status', () async {
        final argument = {
          'status': 'SUCCESS',
          'tag': jsonEncode({'source': 'source', 'tag': 'tag'}),
          'activationTime': 1,
        };

        await handler.handle(MethodCall('onTagAdd', argument));

        expect(result['status'], equals(Status.success));
        expect(result['tag'], isA<Tag>());
        expect(result['activationTime'], equals(1));
      });

      test('emits result with someError status', () async {
        final argument = {
          'status': '42',
          'tag': jsonEncode({'source': 'source', 'tag': 'tag'}),
          'activationTime': 1,
        };

        await handler.handle(MethodCall('onTagAdd', argument));

        expect(result['status'], equals(Status.someError));
        expect(result['tag'], isA<Tag>());
        expect(result['activationTime'], equals(1));
      });
    });

    group('onTagRemove', () {
      late Map<String, Object> result;

      setUp(() {
        handler.onTagRemove = (status, tag, deactivationTime) {
          result = {
            'status': status,
            'tag': tag,
            'deactivationTime': deactivationTime,
          };
        };
      });

      test('emits result with success status', () async {
        final argument = {
          'status': 'SUCCESS',
          'tag': jsonEncode({'source': 'source', 'tag': 'tag'}),
          'deactivationTime': 1,
        };

        await handler.handle(MethodCall('onTagRemove', argument));

        expect(result['status'], equals(Status.success));
        expect(result['tag'], isA<Tag>());
        expect(result['deactivationTime'], equals(1));
      });

      test('emits result with someError status', () async {
        final argument = {
          'status': '42',
          'tag': jsonEncode({'source': 'source', 'tag': 'tag'}),
          'deactivationTime': 1,
        };

        await handler.handle(MethodCall('onTagRemove', argument));

        expect(result['status'], equals(Status.someError));
        expect(result['tag'], isA<Tag>());
        expect(result['deactivationTime'], equals(1));
      });
    });

    group('onAllTagsRemove', () {
      late Map<String, Object> result;

      setUp(() {
        handler.onAllTagsRemove = (status, deactivatedTagsCount, time) {
          result = {
            'status': status,
            'deactivatedTagsCount': deactivatedTagsCount,
            'time': time,
          };
        };
      });

      test('emits result with success status', () async {
        final argument = {
          'status': 'SUCCESS',
          'deactivatedTagsCount': 1,
          'time': 2,
        };

        await handler.handle(MethodCall('onAllTagsRemove', argument));

        expect(result['status'], equals(Status.success));
        expect(result['deactivatedTagsCount'], equals(1));
        expect(result['time'], equals(2));
      });

      test('emits result with someError status', () async {
        final argument = {
          'status': '42',
          'deactivatedTagsCount': 1,
          'time': 2,
        };

        await handler.handle(MethodCall('onAllTagsRemove', argument));

        expect(result['status'], equals(Status.someError));
        expect(result['deactivatedTagsCount'], equals(1));
        expect(result['time'], equals(2));
      });
    });

    group('onGetTags', () {
      late Map<String, Object?> result;

      setUp(() {
        handler.onGetTags = (status, tags, time) {
          result = {
            'status': status,
            'tags': tags,
            'time': time,
          };
        };
      });

      test('emits result with success status', () async {
        final argument = {
          'status': 'SUCCESS',
          'tags': List.generate(
            3,
            (index) =>
                jsonEncode({'source': 'source$index', 'tag': 'tag$index'}),
          ),
          'time': 2,
        };

        await handler.handle(MethodCall('onGetTags', argument));

        expect(result['status'], equals(Status.success));
        expect(result['tags'], isA<List<Tag>>());
        expect((result['tags'] as List<Tag>).length, 3);
        expect(result['time'], equals(2));
      });

      test('emits result with someError status', () async {
        final argument = {
          'status': '42',
          'tags': List.generate(
            3,
            (index) =>
                jsonEncode({'source': 'source$index', 'tag': 'tag$index'}),
          ),
          'time': 2,
        };

        await handler.handle(MethodCall('onGetTags', argument));

        expect(result['status'], equals(Status.someError));
        expect(result['tags'], isA<List<Tag>>());
        expect((result['tags'] as List).length, 3);
        expect(result['time'], equals(2));
      });
    });
  });
}
