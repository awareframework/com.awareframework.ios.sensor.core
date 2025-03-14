#
# Be sure to run `pod lib lint com.awareframework.ios.sensor.core.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'com.awareframework.ios.sensor.core'
  s.version          = '0.7.7'
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

  s.platform = :ios, '13.0'
  s.ios.deployment_target     = '13.0'
  
  s.swift_version = '5'

  s.source_files = 'com.awareframework.ios.sensor.core/Classes/**/*'
  
  s.dependency 'RealmSwift', '~>20.0.0'
  s.dependency 'SwiftyJSON', '~>5.0.2'
  
end
