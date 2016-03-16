Pod::Spec.new do |s|

  s.name = "ZoomTransition"
  s.version = "0.3"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.summary = "Interactive zoom transition for presenting view controllers written in Swift"
  s.homepage = "https://github.com/tristanhimmelman/ZoomTransition"
  s.author = { "Tristan Himmelman" => "tristanhimmelman@gmail.com" }
  s.source = { :git => 'https://github.com/tristanhimmelman/ZoomTransition.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.requires_arc = 'true'
  s.source_files = 'ZoomTransition/**/*.swift'

end