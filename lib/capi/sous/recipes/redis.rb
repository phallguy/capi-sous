Capistrano::Configuration.instance.load do

  namespace :redis do
    desc "Install Memcached"
    task :install, roles: [:redis], on_no_matching_servers: :continue do
      run "#{sudo} apt-get install redis-server"
    end
    after "deploy:install", "redis:install"

    desc "Setup Memcached"
    task :setup, roles: [:redis], on_no_matching_servers: :continue do
      template "redis.erb", "/tmp/redis.conf"
      run "#{sudo} mv /tmp/redis.conf /etc/redis/redis.conf"
      restart
    end
    after "deploy:setup", "redis:setup"

    %w[start stop restart].each do |command|
      desc "#{command} Memcached"
      task command, roles: [:redis], on_no_matching_servers: :continue do
        run "#{sudo} service redis #{command}"
      end
    end
  end
end