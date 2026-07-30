/// Configuration for the Android 4.1+ permissions wizard.
///
/// The options are passed when the wizard is launched and have no effect on
/// iOS. All values default to the native SDK defaults.
class AndroidPermissionWizardOptions {
  /// Creates Android permissions-wizard launch options.
  const AndroidPermissionWizardOptions({
    this.themeMode = AndroidPermissionWizardThemeMode.system,
    this.blockEarlyExit = false,
    this.skipWizardPages = false,
  });

  /// Chooses the wizard colour scheme.
  final AndroidPermissionWizardThemeMode themeMode;

  /// When `true`, prevents the user from closing the wizard before it ends.
  final bool blockEarlyExit;

  /// When `true`, skips informational wizard pages where supported by Android.
  final bool skipWizardPages;

  Map<String, dynamic> toMap() => {
    'themeMode': themeMode.name,
    'blockEarlyExit': blockEarlyExit,
    'skipWizardPages': skipWizardPages,
  };
}

/// Display mode for the Android permissions wizard.
enum AndroidPermissionWizardThemeMode { light, dark, system }
