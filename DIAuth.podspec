Pod::Spec.new do |s|
  s.name             = "DIAuth"
  s.version          = "0.1.1"
  s.summary          = "Two step authorization" 
  s.description      = <<-DESC
                        iOS library for two step authorization: social network auth + own server auth
                       DESC
  s.homepage         = "https://github.com/DmIvanov/DIAuth"
  s.license          = 'MIT'
  s.author           = { "Dmitry Ivanov" => "topolog@icloud.com" }
  s.source           = { :git => "https://github.com/DmIvanov/DIAuth.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'DIAuth/DIAuth'
  
  s.dependency 'KeychainAccess'
  s.dependency 'VK-ios-sdk'
  s.dependency 'FBSDKCoreKit'
  s.dependency 'FBSDKLoginKit'
  
end
