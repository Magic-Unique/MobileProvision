#
# Be sure to run `pod lib lint MobileProvision.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MobileProvision'
  s.version          = '0.1.0'
  s.summary          = 'Reading *.mobileprovision file on macOS and iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
MobileProvision is a tool to read *.mobileprovision file on macOS and iOS.
It contains mobileprovision decoding and x509 decoding(ANS1).
                       DESC

  s.homepage         = 'https://github.com/Magic-Unique/MobileProvision'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '冷秋' => '516563564@qq.com' }
  s.source           = { :git => 'https://github.com/Magic-Unique/MobileProvision.git', :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'MobileProvision/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MobileProvision' => ['MobileProvision/Assets/*.png']
  # }

  s.public_header_files = 'MobileProvision/Classes/Public/*.h'
   
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
