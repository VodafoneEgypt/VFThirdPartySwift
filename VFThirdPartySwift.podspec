Pod::Spec.new do |s|
  s.name             = 'VFThirdPartySwift'
  s.version          = '0.1.3'
  s.summary          = 'ThirdParty swift pod'
  s.description      = 'Pod file contains thirdparty swift files'
  s.homepage         = 'https://github.com/VodafoneEgypt/VFThirdPartySwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'VodafoneEgypt' => 'egypt.apps@vodafone.com' }
  s.source           = { :git => 'https://github.com/VodafoneEgypt/VFThirdPartySwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.0'
  s.source_files = 'VFThirdPartySwift/Classes/**/*.{swift}'
  
  s.dependency 'CommonCryptoModule'
  s.dependency 'Languagehandlerpod'
end
