#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_boost'
  s.version          = '0.0.1'
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
    'Classes/Boost/FlutterBoost.h',
    'Classes/Boost/FlutterBoostPlugin.h',
    'Classes/Boost/FLBPlatform.h',
    'Classes/Boost/FLBFlutterAppDelegate.h',
    'Classes/Container/FLBFlutterViewContainer.h',
    'Classes/Container/FLBViewControllerResultHandler.h'

  s.dependency 'Flutter'
  s.dependency 'xservice_kit'

  s.libraries = 'c++'

  s.ios.deployment_target = '8.0'
end

