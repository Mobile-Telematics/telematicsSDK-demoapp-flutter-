/// Partial visual and copy configuration for the iOS permissions wizard.
///
/// Every omitted value retains the default supplied by Telematics iOS SDK 7.2.
class IosPermissionWizardConfiguration {
  /// Creates a partial iOS wizard configuration.
  const IosPermissionWizardConfiguration({
    this.locationWhenInUse,
    this.locationAlways,
    this.motion,
    this.status,
    this.lightTheme,
    this.darkTheme,
  });

  /// Copy for the "When In Use" location-permission page.
  final IosPermissionWizardPageConfiguration? locationWhenInUse;

  /// Copy for the "Always" location-permission page.
  final IosPermissionWizardPageConfiguration? locationAlways;

  /// Copy for the Motion & Fitness permission page.
  final IosPermissionWizardPageConfiguration? motion;

  /// Copy for the wizard's final permission-status screen.
  final IosPermissionWizardStatusConfiguration? status;

  /// Appearance used when the device is in light mode.
  final IosPermissionWizardTheme? lightTheme;

  /// Appearance used when the device is in dark mode.
  final IosPermissionWizardTheme? darkTheme;

  Map<String, dynamic> toMap() => {
    if (locationWhenInUse != null)
      'locationWhenInUse': locationWhenInUse!.toMap(),
    if (locationAlways != null) 'locationAlways': locationAlways!.toMap(),
    if (motion != null) 'motion': motion!.toMap(),
    if (status != null) 'status': status!.toMap(),
    if (lightTheme != null) 'lightTheme': lightTheme!.toMap(),
    if (darkTheme != null) 'darkTheme': darkTheme!.toMap(),
  };
}

/// Partial text configuration for an iOS wizard permission page.
class IosPermissionWizardPageConfiguration {
  /// Creates a partial page configuration.
  const IosPermissionWizardPageConfiguration({
    this.title,
    this.body,
    this.primaryButtonTitle,
    this.hintLead,
    this.permissionHint,
  });

  /// Page heading.
  final String? title;

  /// Main explanatory text.
  final String? body;

  /// Title of the button that starts the system permission request.
  final String? primaryButtonTitle;

  /// Leading text displayed before the permission-specific hint.
  final String? hintLead;

  /// Permission-specific hint shown to the user.
  final String? permissionHint;

  Map<String, dynamic> toMap() => {
    if (title != null) 'title': title,
    if (body != null) 'body': body,
    if (primaryButtonTitle != null) 'primaryButtonTitle': primaryButtonTitle,
    if (hintLead != null) 'hintLead': hintLead,
    if (permissionHint != null) 'permissionHint': permissionHint,
  };
}

/// Partial text configuration for the iOS wizard completion screen.
class IosPermissionWizardStatusConfiguration {
  /// Creates a partial status configuration.
  const IosPermissionWizardStatusConfiguration({
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
    this.skipButtonTitle,
  });

  /// Status-screen heading.
  final String? title;

  /// Status-screen explanatory text.
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

  /// Title of the button that skips the status screen.
  final String? skipButtonTitle;

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
    if (skipButtonTitle != null) 'skipButtonTitle': skipButtonTitle,
  };
}

/// Partial iOS wizard theme.
///
/// Colours use `#RRGGBB` or `#AARRGGBB` notation.
class IosPermissionWizardTheme {
  /// Creates a partial theme.
  const IosPermissionWizardTheme({
    this.backgroundColor,
    this.gradientStartColor,
    this.gradientEndColor,
    this.titleTextColor,
    this.bodyTextColor,
    this.primaryElementColor,
    this.secondaryElementColor,
    this.buttonTextColor,
    this.cardBackgroundColor,
    this.successElementColor,
    this.warningElementColor,
    this.secondaryButtonTextColor,
    this.secondaryButtonBackgroundColor,
    this.statusIndicatorTextColor,
    this.modalScrimColor,
  });

  /// Main background colour.
  final String? backgroundColor;

  /// Start colour for the background gradient.
  final String? gradientStartColor;

  /// End colour for the background gradient.
  final String? gradientEndColor;

  /// Colour of page titles.
  final String? titleTextColor;

  /// Colour of explanatory text.
  final String? bodyTextColor;

  /// Colour of primary interactive elements.
  final String? primaryElementColor;

  /// Colour of secondary interactive elements.
  final String? secondaryElementColor;

  /// Colour of text on primary buttons.
  final String? buttonTextColor;

  /// Background colour of cards.
  final String? cardBackgroundColor;

  /// Colour used for successful permission statuses.
  final String? successElementColor;

  /// Colour used for warnings and missing permissions.
  final String? warningElementColor;

  /// Colour of text on secondary buttons.
  final String? secondaryButtonTextColor;

  /// Background colour of secondary buttons.
  final String? secondaryButtonBackgroundColor;

  /// Colour of text in status indicators.
  final String? statusIndicatorTextColor;

  /// Overlay colour behind modal content.
  final String? modalScrimColor;

  Map<String, dynamic> toMap() => {
    ..._hexColorField('backgroundColor', backgroundColor),
    ..._hexColorField('gradientStartColor', gradientStartColor),
    ..._hexColorField('gradientEndColor', gradientEndColor),
    ..._hexColorField('titleTextColor', titleTextColor),
    ..._hexColorField('bodyTextColor', bodyTextColor),
    ..._hexColorField('primaryElementColor', primaryElementColor),
    ..._hexColorField('secondaryElementColor', secondaryElementColor),
    ..._hexColorField('buttonTextColor', buttonTextColor),
    ..._hexColorField('cardBackgroundColor', cardBackgroundColor),
    ..._hexColorField('successElementColor', successElementColor),
    ..._hexColorField('warningElementColor', warningElementColor),
    ..._hexColorField('secondaryButtonTextColor', secondaryButtonTextColor),
    ..._hexColorField(
      'secondaryButtonBackgroundColor',
      secondaryButtonBackgroundColor,
    ),
    ..._hexColorField('statusIndicatorTextColor', statusIndicatorTextColor),
    ..._hexColorField('modalScrimColor', modalScrimColor),
  };
}

Map<String, String> _hexColorField(String key, String? value) {
  if (value == null) {
    return const {};
  }

  if (!RegExp(r'^#(?:[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$').hasMatch(value)) {
    throw ArgumentError.value(value, key, 'Expected #RRGGBB or #AARRGGBB.');
  }

  return {key: value};
}
