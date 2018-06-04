Pod::Spec.new do |s|

  s.name         = "StoriesImagePicker"
  s.version      = "1.0.0"
  s.summary      = "A ViewController that allows the user to select images from their Photo Library, Instagram or Facebook."
  s.description  = <<-DESC
  A ViewController that allows the user to select images from their Photo Library, Instagram or Facebook. It closely matches the design of the built-in Photos app and it includes a feature that groups photos into Stories in a similar manner that Photos.app creates Memories.
                   DESC

  s.license      = "MIT"
  s.platform     = :ios, "10.0"
  s.authors      = { 'Konstantinos Karagiannis' => 'kkarayannis@gmail.com', 'Jaime Landazuri' => '', 'Julian Gruber' => '' }
  s.homepage     = 'https://www.kite.ly'
  s.source       = { :git => "https://github.com/OceanLabs/StoriesImagePicker-iOS.git", :tag => "#{s.version}" }
  s.source_files  = ["StoriesImagePicker/**/*.swift"]
  s.swift_version = "4.1"
  s.resource_bundles  = { 'StoriesImagePickerResources' => ['StoriesImagePicker/StoriesImagePicker.storyboard', 'StoriesImagePicker/StoriesImagePicker.xcassets'] }
  s.module_name         = 'StoriesImagePicker'
  s.dependency "OAuthSwift", "~> 1.2.0"
  s.dependency "KeychainSwift", "~> 11.0.0"
  s.dependency "SDWebImage", "~> 4.4.0"
  s.dependency "FBSDKCoreKit", "~> 4.33.0"
  s.dependency "FBSDKLoginKit", "~> 4.33.0"

end
