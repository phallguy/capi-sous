Capistrano::Configuration.instance.load do

set_default(:resque_user) { user }
set_default(:resque_pid) { "#{current_path}/tmp/pids/resque.pid" }
set_default(:resque_log) { "#{shared_path}/log/resque.log" }
set_default(:resque_workers, 2)
set_default(:resque_queue, "*")

set(:resque_env){ unicorn_env }

set(:resque_name) do 
  queue = resque_queue.gsub /[^a-z0-9]/i, '_'
  "#{safe_application_path}_resque_#{queue}"
end

namespace :resque do
  desc "Setup resque initializer and app configuration"
  task :setup, roles: :resque do
  end
  after "deploy:setup", "resque:setup"
  after "monit:services", "monit:resque"

  %w[start stop restart].each do |command|
    desc "#{command} resque"
    task command, roles: :resque do
      run "#{sudo} monit #{command} -g #{resque_name}_workers"
    end
    after "deploy:#{command}", "resque:#{command}"
  end
end

end