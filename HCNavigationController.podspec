Pod::Spec.new do |s|
	s.name     = 'HCNavigationController'
	s.version  = '0.0.1'
	s.license  = 'MIT'
	s.summary  = 'UINavigationController Alike On macOS'
	s.homepage = 'https://github.com/hchen/HCNavigationController'
	s.authors  = { 'Chen' => 'hechen.dream@gmail.com'}
	s.source   = { :git => 'https://github.com/hechen/HCNavigationController.git', :tag => '0.0.1' }
	s.source_files = 'Source/**/**/*'
	s.requires_arc = true
	s.osx.deployment_target = '10.10'
end
