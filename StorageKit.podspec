Pod::Spec.new do |s|
  s.name             = 'StorageKit'
  s.version          = '1.2.0'
  s.summary          = 'CoreData heplfull extenions'

  s.description      = <<-DESC
Helpful extensions and base classes of CoreData for best practice.
                       DESC

  s.homepage         = 'https://github.com/viveron/StorageKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Victor Shabanov' => 'shabanov.dev.git@gmail.com' }
  s.source           = { :git => 'https://github.com/viveron/StorageKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  
  s.swift_version = '5.0'
  s.source_files = 'StorageKit/Classes/**/*'
  s.frameworks = 'CoreData'
end
