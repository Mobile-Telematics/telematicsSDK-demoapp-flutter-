import 'package:flutter_test/flutter_test.dart';
import 'package:telematics_sdk/telematics_sdk.dart';

void main() {
  group('DeviceIdRegistrationState', () {
    test('parses Android-compatible string contract', () {
      final state = DeviceIdRegistrationState.fromJson({
        'status': 'REGISTERED',
        'checkedAtMillis': 1716800000123,
      });

      expect(state.status, DeviceIdRegistrationStatus.registered);
      expect(state.checkedAtMillis, 1716800000123);
    });

    test('keeps unchecked timestamp as zero', () {
      final state = DeviceIdRegistrationState.fromJson({
        'status': 'NOT_SET',
        'checkedAtMillis': 0,
      });

      expect(state.status, DeviceIdRegistrationStatus.notSet);
      expect(state.checkedAtMillis, 0);
    });

    test('parses iOS raw numeric status fallback', () {
      final state = DeviceIdRegistrationState.fromJson({
        'status': 3,
        'checkedAtMillis': 1716800000123.0,
      });

      expect(state.status, DeviceIdRegistrationStatus.notRegistered);
      expect(state.checkedAtMillis, 1716800000123);
    });
  });

  group('TrackingState', () {
    test('parses Android-compatible string contract', () {
      final state = TrackingState.fromJson({
        'automaticTrackingStatus': 'DISABLED_BY_SCHEDULE',
        'manualTrackingStatus': 'ENABLED',
      });

      expect(state.automaticTrackingStatus, TrackingStatus.disabledBySchedule);
      expect(state.manualTrackingStatus, TrackingStatus.enabled);
    });

    test('parses iOS raw numeric status fallback', () {
      final state = TrackingState.fromJson({
        'automaticTrackingStatus': 1,
        'manualTrackingStatus': 4,
      });

      expect(state.automaticTrackingStatus, TrackingStatus.deviceIdNotSet);
      expect(state.manualTrackingStatus, TrackingStatus.disabledByServer);
    });

    test('keeps unknown status distinct from enabled', () {
      final state = TrackingState.fromJson({
        'automaticTrackingStatus': 'NEW_STATUS',
        'manualTrackingStatus': 42,
      });

      expect(state.automaticTrackingStatus, TrackingStatus.unknown);
      expect(state.manualTrackingStatus, TrackingStatus.unknown);
    });
  });
}
