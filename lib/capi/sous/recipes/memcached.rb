Capistrano::Configuration.instance.load do

set :memcached_available, true

namespace :memcached do

  set_default :memcached_memory_limit, 64

  desc "Install memcached"
  task :install, roles: :memcached do
    run "#{sudo} apt-get -y install memcached"
  end
  after "deploy:install", "memcached:install"

  desc "Setup memcached configuration for ALL applications"
  task :setup, roles: :memcached do
    template "memcached.erb", "/tmp/memcached_conf"
    run "#{sudo} mkdir -p /var/log/memcached && #{sudo} mv /tmp/memcached_conf /etc/memcached.conf"
    restart
  end
  after "deploy:setup", "memcached:setup"
  after "monit:services", "monit:memcached"

  %w[start stop restart status].each do |command|
    desc "#{command} memcached"
    task command, roles: :memcached do
      run "#{sudo} monit #{command} memcached || true"
    end
  end

  after "deploy:start", "memcached:start"
  after "deploy:restart", "memcached:start"
end

end