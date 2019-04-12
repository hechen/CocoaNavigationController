Pod::Spec.new do |s|
	s.name     = 'CocoaNavigationController'
	s.version  = '0.0.4'
	s.license  = 'MIT'
	s.summary  = 'UINavigationController Alike On macOS'
	s.homepage = 'https://github.com/hchen/CocoaNavigationController'
	s.authors  = { 'Chen' => 'hechen.dream@gmail.com'}
	s.source   = { :git => 'https://github.com/hechen/CocoaNavigationController.git', :tag => '0.0.4' }
	s.source_files = 'Source/**/**/*'
	s.platform     = :osx, '10.10'
	s.requires_arc = true
  s.swift_version = '4.2'
	s.license      = {
    :type => 'MIT',
    :file => 'LICENSE',
    :text => 'Permission is hereby granted ...'
  }
end
