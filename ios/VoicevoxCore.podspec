Pod::Spec.new do |s|
  s.name             = 'VoicevoxCore'
  s.version          = '0.16.4'
  s.summary          = 'VOICEVOX Core and ONNX Runtime xcframeworks'
  s.homepage         = 'https://github.com/VOICEVOX/voicevox_core'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Hiroshiba' => 'noreply@example.com' }
  s.source           = { :path => '.' }
  s.vendored_frameworks = [
    'Frameworks/voicevox_core.xcframework',
    'Frameworks/voicevox_onnxruntime.xcframework'
  ]
  s.platform         = :ios, '16.2'
  s.ios.deployment_target = '16.2'
end
