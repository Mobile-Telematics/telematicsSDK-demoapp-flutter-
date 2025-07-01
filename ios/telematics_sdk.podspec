#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint telematics_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'telematics_sdk'
  s.version          = '0.3.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://damoov.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Damoov Telematics' => 'admin@damoov.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Dependency
  s.dependency 'TelematicsSDK', '~> 7.0.1'
end
