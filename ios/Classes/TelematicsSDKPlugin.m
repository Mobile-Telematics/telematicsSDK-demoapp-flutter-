#import "TelematicsSDKPlugin.h"
#if __has_include(<telematics_sdk/telematics_sdk-Swift.h>)
#import <telematics_sdk/telematics_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "telematics_sdk-Swift.h"
#endif

@implementation TelematicsSDKPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTelematicsSDKPlugin registerWithRegistrar:registrar];
}
@end
