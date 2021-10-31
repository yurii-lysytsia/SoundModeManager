# To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.name         = "SoundModeManager"
  spec.version      = "1.0.1"
  spec.summary      = "Detect silent / ring mode on the iOS device"
  spec.description  = "This is framework to detect silent / ring mode on the iOS device written on Swift"
  spec.homepage     = "https://github.com/yurii-lysytsia/SoundModeManager"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.author             = { "Yurii Lysytsia" => "developer.yurii.lysytsia@gmail.com" }
  spec.social_media_url   = "https://www.yurii-lysytsia.site"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.ios.deployment_target = "9.0"
  spec.swift_versions = '5.0'
  
  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.source       = { :git => "https://github.com/yurii-lysytsia/SoundModeManager.git", :tag => "#{spec.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.source_files  = "SoundModeManager/Source/**/*.swift"
  spec.resources = "SoundModeManager/Resource/Sounds/*"

end
