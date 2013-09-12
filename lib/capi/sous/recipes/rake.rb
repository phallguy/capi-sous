Capistrano::Configuration.instance.load do

set_default( :rake_cmd ){ "#{bundle_cmd} exec rake"}
set_default( :rake_task ){ ENV['task'] }

namespace :rake do
  desc "Runs a rake task on all rake servers."
  task :default, roles: :rake, except: { no_release: true } do
    run "cd '#{current_path}' && #{rake_cmd} #{rake_task} RAILS_ENV=#{rails_env}"
  end

  desc "Runs a rake task on one server."
  task :one, roles: :rake, except: { no_release: true } do
    host = find_servers_for_task(current_task).first

    run "cd '#{current_path}' && #{rake_cmd} RAILS_ENV=#{rails_env}", hosts: host
  end
end

end