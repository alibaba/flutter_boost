#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_boost'
  s.version          = '0.0.2'
  s.summary          = 'A new Flutter plugin make flutter better to use!'
  s.description      = <<-DESC
A new Flutter plugin make flutter better to use!
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE.md' }
  s.author           = { 'Alibaba Xianyu' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m,mm}'
  
  s.public_header_files = 
    'Classes/Boost/FlutterBoostPlugin.h',
    'Classes/Boost/FLBPlatform.h',
    'Classes/Boost/FLBFlutterContainer.h',
    'Classes/Boost/FLBFlutterAppDelegate.h',
    'Classes/Boost/FLBTypes.h',
    'Classes/Boost/FlutterBoost.h',
    'Classes/Boost/BoostChannel.h',
    'Classes/container/FLBFlutterViewContainer.h'
    
  s.dependency 'Flutter'
  s.libraries = 'c++'
  s.xcconfig = {
      'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
      'CLANG_CXX_LIBRARY' => 'libc++'
  }
  
  s.ios.deployment_target = '8.0'
end

