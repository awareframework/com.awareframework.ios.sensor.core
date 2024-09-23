#
# Be sure to run `pod lib lint com.awareframework.ios.sensor.core.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'com.awareframework.ios.sensor.core'
  s.version          = '0.7.3'
  s.summary          = 'The Core Library of AWARE Framework iOS.'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
com.awareframework.ios.sensor.core provides basic classes for developing your own sensor module on AWARE Framework.
                       DESC

  s.homepage         = 'https://github.com/awareframework/com.awareframework.ios.sensor.core'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache2', :file => 'LICENSE' }
  s.author           = { 'Yuuki Nishiyama' => 'nishiyama@csis.u-tokyo.ac.jp' }
  s.source           = { :git => 'https://github.com/awareframework/com.awareframework.ios.sensor.core.git', :tag => s.version.to_s }

  s.platform = :ios, '12.0'
  s.ios.deployment_target     = '12.0'
  
  s.swift_version = '5'

  s.source_files = 'com.awareframework.ios.sensor.core/Classes/**/*'
  
  s.dependency 'RealmSwift', '~>20.0.0'
  s.dependency 'SwiftyJSON', '~>5.0.2'
  
  # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
#  s.pod_target_xcconfig = {
#    'APPLICATION_EXTENSION_API_ONLY' => 'YES',
#
#    'IPHONEOS_DEPLOYMENT_TARGET_1500' => '13.0',
#    'IPHONEOS_DEPLOYMENT_TARGET_1600' => '13.0',
#    'IPHONEOS_DEPLOYMENT_TARGET' => '$(IPHONEOS_DEPLOYMENT_TARGET_$(XCODE_VERSION_MAJOR))',
#    'MACOSX_DEPLOYMENT_TARGET_1500' => '10.13',
#    'MACOSX_DEPLOYMENT_TARGET_1600' => '10.13',
#    'MACOSX_DEPLOYMENT_TARGET' => '$(MACOSX_DEPLOYMENT_TARGET_$(XCODE_VERSION_MAJOR))',
#    'WATCHOS_DEPLOYMENT_TARGET_1500' => '4.0',
#    'WATCHOS_DEPLOYMENT_TARGET_1600' => '4.0',
#    'WATCHOS_DEPLOYMENT_TARGET' => '$(WATCHOS_DEPLOYMENT_TARGET_$(XCODE_VERSION_MAJOR))',
#    'TVOS_DEPLOYMENT_TARGET_1500' => '12.0',
#    'TVOS_DEPLOYMENT_TARGET_1600' => '12.0',
#    'TVOS_DEPLOYMENT_TARGET' => '$(TVOS_DEPLOYMENT_TARGET_$(XCODE_VERSION_MAJOR))',
#  }
  
end
