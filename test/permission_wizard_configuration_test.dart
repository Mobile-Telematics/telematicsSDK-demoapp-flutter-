import 'package:flutter_test/flutter_test.dart';
import 'package:telematics_sdk/telematics_sdk.dart';

void main() {
  group('permission wizard configuration', () {
    test('serializes Android launch options', () {
      const options = AndroidPermissionWizardOptions(
        themeMode: AndroidPermissionWizardThemeMode.dark,
        blockEarlyExit: true,
        skipWizardPages: true,
      );

      expect(options.toMap(), {
        'themeMode': 'dark',
        'blockEarlyExit': true,
        'skipWizardPages': true,
      });
    });

    test('serializes only supplied iOS wizard fields', () {
      const configuration = IosPermissionWizardConfiguration(
        locationAlways: IosPermissionWizardPageConfiguration(
          title: 'Location access',
        ),
        lightTheme: IosPermissionWizardTheme(backgroundColor: '#112233'),
      );

      expect(configuration.toMap(), {
        'locationAlways': {'title': 'Location access'},
        'lightTheme': {'backgroundColor': '#112233'},
      });
    });

    test('serializes only supplied iOS missing-permissions alert fields', () {
      const configuration = IosMissingPermissionsAlertConfiguration(
        isBlocking: true,
        skipButtonTitle: 'Not now',
      );

      expect(configuration.toMap(), {
        'isBlocking': true,
        'skipButtonTitle': 'Not now',
      });
    });

    test('rejects malformed iOS theme colours', () {
      const theme = IosPermissionWizardTheme(backgroundColor: '112233');

      expect(theme.toMap, throwsArgumentError);
    });
  });
}
