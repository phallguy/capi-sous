Capistrano::Configuration.instance.load do

set_default :redis_server do
  "redis.#{vpc_domain_name}:6379/#{deploy_env}"
end

namespace :redis do

  desc "Install redis"
  task :install, roles: :redis do
    build.default
  end
  after "deploy:install", "redis:install"

  desc "Setup redis configuration for this application"
  task :setup, roles: :redis do

    template "redis.erb", "/tmp/redis_conf"
    template "redis_init.erb", "/tmp/redis_init"

    run "#{sudo} useradd -d /var/lib/redis -M -s /bin/false redis || true"
    run "#{sudo} mkdir -p /var/lib/redis; #{sudo} chown redis:redis /var/lib/redis"

    run "#{sudo} mv /tmp/redis_conf /etc/redis/redis.conf"
    run "chmod +x /tmp/redis_init; #{sudo} mv /tmp/redis_init /etc/init.d/redis-server; #{sudo} update-rc.d -f redis-server defaults"




    restart
  end
  after "deploy:setup", "redis:setup"

  %w[start stop restart].each do |command|
    desc "#{command} redis"
    task command, roles: :redis do
      run "#{sudo} monit #{command} redis-server"
    end
  end

  namespace :build do
    desc "Downloads and builds redis"
    task :default, roles: :redis do
      download
      make
      install
      cleanup
    end

    task :download, roles: :redis do
      cleanup
      run "wget wget http://download.redis.io/redis-stable.tar.gz; tar xzvf redis-stable.tar.gz;"
    end

    task :make, roles: :redis do
      run "cd redis-stable; make"
    end

    task :install, roles: :redis do
      run "cd redis-stable; #{sudo} make install"
    end

    task :cleanup, roles: :redis do
      run "rm -rf redis-stable; rm -f redis-stable.tar.gz"
    end
  end
end

end