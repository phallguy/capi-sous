Capistrano::Configuration.instance.load do

set_default(:unicorn_user) { user }
set_default(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
set_default(:unicorn_config) { "#{shared_path}/config/unicorn.rb" }
set_default(:unicorn_log) { "#{shared_path}/log/unicorn.log" }
set_default(:unicorn_workers, 2)
set_default(:unicorn_autostart){ true }

set :unicorn_env, {
    "RUBY_HEAP_MIN_SLOTS"           => 1250000,
    "RUBY_GC_HEAP_INIT_SLOTS"       => 1250000,
    "RUBY_HEAP_SLOTS_INCREMENT"     => 300000,
    "RUBY_HEAP_SLOTS_GROWTH_FACTOR" => 1,
    "RUBY_GC_MALLOC_LIMIT"          => 80000000,
    "RUBY_HEAP_FREE_MIN"            => 100000
}

namespace :unicorn do
  desc "Setup Unicorn initializer and app configuration"
  task :setup, roles: :unicorn, except: { no_release: true } do
    run "#{sudo} mkdir -p #{shared_path}/config && #{sudo} chown -R #{user}:#{user} #{shared_path}/.."

    template "unicorn.rb.erb", unicorn_config
    template "unicorn_init.erb", "/tmp/unicorn_init"
    run "chmod +x /tmp/unicorn_init"
    run "#{sudo} mv /tmp/unicorn_init /etc/init.d/unicorn_#{safe_application_path}"
    run "#{sudo} update-rc.d -f unicorn_#{safe_application_path} defaults" if unicorn_autostart
  end
  after "deploy:setup", "unicorn:setup"
  after "monit:services", "monit:unicorn"
  
  %w[start restart stop upgrade].each do |command|
    desc "#{command} unicorn"
    task command, roles: :unicorn do
      run "service unicorn_#{safe_application_path} #{command}"
    end
    after "deploy:#{command}", "unicorn:#{command}"
  end

  %W{unmonitor monitor}.each do |command|
    task( command, roles: :unicorn ) do
      run "#{sudo} monit #{command} #{safe_application_path}_unicorn"
      unicorn_workers.times.each do |worker|
        run "#{sudo} monit #{command} #{safe_application_path}_unicorn_worker_#{worker}"
      end
    end
  end
  before "deploy:update_code", "unicorn:unmonitor"
  after "deploy:finalize_update", "unicorn:monitor"

  before "unicorn:restart", "unicorn:unmonitor"
  after "unicorn:restart", "unicorn:monitor"


end

end