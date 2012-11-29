#http://railscasts.com/episodes/380-memcached-dalli
Capistrano::Configuration.instance.load do
  set_default :memcached_memory_limit, 64

  namespace :memcached do
    desc "Install Memcached"
    task :install, roles: [:memcached], on_no_matching_servers: :continue do
      run "#{sudo} apt-get install memcached"
    end
    after "deploy:install", "memcached:install"

    desc "Setup Memcached"
    task :setup, roles: [:memcached], on_no_matching_servers: :continue do
      template "memcached.erb", "/tmp/memcached.conf"
      run "#{sudo} mv /tmp/memcached.conf /etc/memcached.conf"
      restart
    end
    after "deploy:setup", "memcached:setup"

    %w[start stop restart].each do |command|
      desc "#{command} Memcached"
      task command, roles: [:memcached], on_no_matching_servers: :continue do
        run "#{sudo} service memcached #{command}"
      end
    end
  end
end