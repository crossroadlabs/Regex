Pod::Spec.new do |s|
  s.name = 'CrossroadRegex'
  s.version = '0.3'
  s.license = 'Apache 2.0'
  s.summary = 'Easy, portable and feature reach Regular Expressions for Swift'
  s.homepage = 'https://github.com/crossroadlabs/Regex'
  s.social_media_url = 'https://github.com/crossroadlabs/Regex'
  s.authors = { 'Daniel Leping' => 'daniel@crossroadlabs.xyz' }
  s.source = { :git => 'https://github.com/crossroadlabs/Regex.git', :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'Regex/*.swift'

  s.requires_arc = true
end
