#
# Be sure to run `pod lib lint SwiftToolbox.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftToolbox'
  s.version          = '0.1.0'
  s.summary          = 'SwiftToolbox is a compile of helpers, classes and extensions, to improve code reuse and enhance productivity.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC

  SwiftToolbox

  GenericTable -> Helps to build quick table without effort.

  CompletionManager -> Helps you handle multi dependent async tasks, alternative to Group.

  MIT license, use as you wish.
                       DESC

  s.homepage         = 'https://github.com/lucasca73/LASwiftToolbox'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lucas Costa Araujo' => 'lucascostaa73@gmail.com' }
  s.source           = { :git => 'https://github.com/lucasca73/LASwiftToolbox.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'SwiftToolbox/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SwiftToolbox' => ['SwiftToolbox/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
