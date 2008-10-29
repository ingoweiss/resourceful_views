namespace :resourceful_views do
  desc 'List view helper methods introduced by ResourcefulViews'
  task :helpers => :environment do
    ResourcefulViews.helpers.each do |resource, helper_names|
      puts resource
      puts '-' * resource.length
      puts helper_names
      puts
    end
  end
end
