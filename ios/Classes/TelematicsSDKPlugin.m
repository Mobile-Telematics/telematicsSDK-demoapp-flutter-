#import "TelematicsSDKPlugin.h"
#import <telematics_sdk/telematics_sdk-Swift.h>

@implementation TelematicsSDKPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTelematicsSDKPlugin registerWithRegistrar:registrar];
}
@end
