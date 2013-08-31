Capistrano::Configuration.instance.load do

set_default(:mongoid_db_name) { application_namespace.gsub /-\w{2,3}+$/, "" }
set_default(:mongoid_server) { "localhost:27017" }

namespace :mongoid do
  desc "Setup Mongoid app configuration"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "mongoid.yml.erb", "#{shared_path}/config/mongoid.yml"
  end
  after "deploy:setup", "mongoid:setup"  

  desc "Create indexes"
  task :create_indexes, roles: :app do
  	run "cd #{current_path}; bundle exec rake RAILS_ENV=production db:mongoid:create_indexes "
  end
  desc "Remove indexes"
  task :remove_indexes, roles: :app do
  	run "cd #{current_path}; bundle exec rake RAILS_ENV=production db:mongoid:remove_indexes "
  end


end

end