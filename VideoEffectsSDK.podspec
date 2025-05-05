Pod::Spec.new do |spec|

  spec.name         = "VideoEffectsSDK"
  spec.version      = "2.4.0"
  spec.summary      = "Video Effects SDK framework for iOS"
  spec.authors      = "Effects SDK"
  
  spec.homepage     = "https://effectssdk.ai"
  spec.ios.deployment_target = '13.0'
  
  spec.source       = { :http => "https://github.com/EffectsSDK/swift-video-effects-sdk/releases/download/2.4.0/TSVB.xcframework-2.4.0.112360.zip" }
  spec.vendored_frameworks = "TSVB.xcframework"
    
  end