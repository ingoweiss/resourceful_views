require 'rubygems'
spec = Gem::Specification.new do |spec|
  spec.name = 'resourceful_views'
  spec.summary = "Resource-oriented helpers for rendering forms and links in Rails"
  spec.description = "ResourcefulViews aims to take RESTful conventions beyond controllers and into views by extending the 'map.resources' method to install a comprehensive vocabulary of resource-oriented view helpers"
  spec.author = 'Ingo Weiss'
  spec.email = 'ingo@ingoweiss.com'
  spec.homepage = 'http://github.com/ingoweiss/resourceful_views'
  spec.files = Dir['lib/*.rb']
  spec.test_files = Dir['spec/*.rb']
  spec.version = '0.2.0'
end