spec = Gem::Specification.new do |s|
  s.name = 'resourceful_views'
  s.version = '0.2.0'
  s.authors = ['Ingo Weiss']
  s.email = ['ingo@ingoweiss.com']
  s.date = '2009-01-15'
  s.summary = %q{Resource-oriented helpers for rendering forms and links in Rails}
  s.description = %q{ResourcefulViews aims to take RESTful conventions beyond controllers and into views by extending the 'map.resources' method to install a comprehensive vocabulary of resource-oriented view helpers}
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README"]
  s.homepage = 'http://github.com/ingoweiss/resourceful_views'
  s.files = ['README', 'lib/resourceful_views.rb', 'tasks/resourceful_views_tasks.rake']
  s.require_paths = ['lib']
end



