#
# Be sure to run `pod lib lint JSONViewControllers.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JSONViewControllers"
  s.version          = "0.1.11"
  s.summary          = "UICollectionViewController and UITableViewControllers, one driven by JSON, one by model rows."
  s.homepage         = "https://github.com/graham-perks-snap/JSONViewControllers"
  s.license          = 'MIT'
  s.author           = { "Snap Kitchen" => "graham_perks@snapkitchen.com" }
  s.source           = { :git => "https://github.com/graham-perks-snap/JSONViewControllers.git", :tag => s.version.to_s }
  s.ios.deployment_target  = '9.0'
  s.tvos.deployment_target = '10.0'
  s.source_files     = 'Pod/Classes/*.swift'
  s.frameworks       = 'UIKit'
  s.description      = <<-DESC
        Easily make a collection or table view from JSON content.
        Simplifies table/collection definition & eases cell reuse between view controllers.
        Move cells' logic to their own controller classes.
                       DESC
  s.dependency 'SwiftyJSON'
end
