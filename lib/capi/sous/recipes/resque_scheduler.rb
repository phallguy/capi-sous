Capistrano::Configuration.instance.load do

set_default(:resque_scheduler_user) { user }
set_default(:resque_scheduler_pid) { "#{current_path}/tmp/pids/resque_scheduler.pid" }
set_default(:resque_scheduler_log) { "#{shared_path}/log/resque_scheduler.log" }

set(:resque_scheduler_env){ unicorn_env }

set(:resque_scheduler_name) do 
  "#{safe_application_path}_resque_scheduler"
end

namespace :resque_scheduler do
  desc "Setup resque scheduler initializer and app configuration"
  task :setup, roles: :resque_scheduler do
  end
  after "deploy:setup", "resque_scheduler:setup"
  after "monit:services", "monit:resque_scheduler"

  %w[start stop restart].each do |command|
    desc "#{command} resque_scheduler"
    task command, roles: :resque_scheduler do
      run "#{sudo} monit #{command} #{resque_scheduler_name}"
    end
    after "deploy:#{command}", "resque_scheduler:#{command}"
  end
end

end