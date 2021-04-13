enum PermissionWizardResult {
  /// User finished wizard with all required permissions granted
  allGranted,

  /// User canceled wizard
  canceled,

  /// User finished wizard with not all required permissions granted
  notAllGranted,
}
