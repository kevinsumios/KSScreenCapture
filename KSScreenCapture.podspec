Pod::Spec.new do |s|
  s.name             = 'KSScreenCapture'
  s.version          = '0.1.0'
  s.summary          = 'A tool that can capture your screen\'s action including audio recorder.'
  s.description      = <<-DESC
It is base on Blazeice's work which can be find originally in https://github.com/Blazeice/ScreenAndAudioRecordDemoScreenAndAudioRecordDemo. Thanks to Blazeice and wayne li.
                       DESC
  s.homepage         = 'https://github.com/kevinsumios/KSScreenCapture'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kevin Sum' => 'kevin-sum@hotmail.com' }
  s.source           = { :git => 'https://github.com/kevinsumios/KSScreenCapture.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = '*.{h,m}', 'CoreGraphics/**/*.{h,m}', 'THC/**/*.{h,m}'
  s.dependency 'CocoaLumberjack', '~> 2.3.0'
end
