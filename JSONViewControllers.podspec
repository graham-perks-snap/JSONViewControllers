#
# Be sure to run `pod lib lint JSONViewControllers.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JSONViewControllers"
  s.version          = "0.1.0"
  s.summary          = "UICollectionViewController and UITableViewControllers driven by JSON."

  s.description      = <<-DESC
        Easily make a collection or table view from JSON content.
        Simplifies table/collection definition & eases cell reuse between view controllers.
        Move cells' logic to their own controller classes.
                       DESC

  s.homepage         = "https://github.com/graham-perks-snap/JSONViewControllers"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Snap Kitchen" => "graham_perks@snapkitchen.com" }
  s.source           = { :git => "https://github.com/graham-perks-snap/JSONViewControllers.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'JSONViewControllers' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'SwiftyJSON'
end
