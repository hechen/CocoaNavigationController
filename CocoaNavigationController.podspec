Pod::Spec.new do |s|
	s.name     = 'CocoaNavigationController'
	s.version  = '0.1.1'
	s.license  = 'MIT'
	s.summary  = 'UINavigationController Alike On macOS'
	s.homepage = 'https://github.com/hechen/CocoaNavigationController'
	s.authors  = { 'Chen' => 'hechen.dream@gmail.com'}
	s.source   = { :git => 'https://github.com/hechen/CocoaNavigationController.git', :tag => s.version.to_s }
	s.source_files = 'Source/**/**/*'
	s.platform     = :osx, '10.13'
	s.requires_arc = true
  s.swift_version = '5.0'
	s.license      = {
    :type => 'MIT',
    :file => 'LICENSE',
    :text => 'Permission is hereby granted ...'
  }
end
