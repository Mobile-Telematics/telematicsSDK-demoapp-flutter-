import 'package:telematics_sdk/src/data/models/ios_permission_wizard_configuration.dart';

/// Partial configuration for the iOS missing-permissions alert.
///
/// Every omitted value retains the default supplied by Telematics iOS SDK 7.2.
class IosMissingPermissionsAlertConfiguration {
  /// Creates a partial missing-permissions alert configuration.
  const IosMissingPermissionsAlertConfiguration({
    this.title,
    this.body,
    this.locationTitle,
    this.motionTitle,
    this.locationEnabledText,
    this.locationAlwaysRequiredText,
    this.locationPreciseRequiredText,
    this.locationActionNeededText,
    this.motionEnabledText,
    this.motionActionNeededText,
    this.fixInSettingsButtonTitle,
    this.isBlocking,
    this.skipButtonTitle,
    this.lightTheme,
    this.darkTheme,
  });

  /// Alert heading.
  final String? title;

  /// Alert explanatory text.
  final String? body;

  /// Heading for the location permission status.
  final String? locationTitle;

  /// Heading for the Motion & Fitness permission status.
  final String? motionTitle;

  /// Text shown when location access is correctly configured.
  final String? locationEnabledText;

  /// Text explaining that "Always" location access is required.
  final String? locationAlwaysRequiredText;

  /// Text explaining that Precise Location is required.
  final String? locationPreciseRequiredText;

  /// Text shown when the user must take action for location access.
  final String? locationActionNeededText;

  /// Text shown when Motion & Fitness access is correctly configured.
  final String? motionEnabledText;

  /// Text shown when the user must take action for Motion & Fitness access.
  final String? motionActionNeededText;

  /// Title of the button that opens the system Settings app.
  final String? fixInSettingsButtonTitle;

  /// Whether the user must resolve missing permissions before dismissing the alert.
  final bool? isBlocking;

  /// Title of the button that dismisses or skips the alert.
  final String? skipButtonTitle;

  /// Appearance used when the device is in light mode.
  final IosPermissionWizardTheme? lightTheme;

  /// Appearance used when the device is in dark mode.
  final IosPermissionWizardTheme? darkTheme;

  Map<String, dynamic> toMap() => {
    if (title != null) 'title': title,
    if (body != null) 'body': body,
    if (locationTitle != null) 'locationTitle': locationTitle,
    if (motionTitle != null) 'motionTitle': motionTitle,
    if (locationEnabledText != null) 'locationEnabledText': locationEnabledText,
    if (locationAlwaysRequiredText != null)
      'locationAlwaysRequiredText': locationAlwaysRequiredText,
    if (locationPreciseRequiredText != null)
      'locationPreciseRequiredText': locationPreciseRequiredText,
    if (locationActionNeededText != null)
      'locationActionNeededText': locationActionNeededText,
    if (motionEnabledText != null) 'motionEnabledText': motionEnabledText,
    if (motionActionNeededText != null)
      'motionActionNeededText': motionActionNeededText,
    if (fixInSettingsButtonTitle != null)
      'fixInSettingsButtonTitle': fixInSettingsButtonTitle,
    if (isBlocking != null) 'isBlocking': isBlocking,
    if (skipButtonTitle != null) 'skipButtonTitle': skipButtonTitle,
    if (lightTheme != null) 'lightTheme': lightTheme!.toMap(),
    if (darkTheme != null) 'darkTheme': darkTheme!.toMap(),
  };
}
