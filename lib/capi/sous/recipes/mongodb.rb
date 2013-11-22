Capistrano::Configuration.instance.load do

set_default( :mongo_db_path ){ "#{db_path}/mongodb" }

namespace :mongodb do

  desc "Install mongodb"
  task :install, roles: :mongodb do
    run "#{sudo} apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10"
    run "#{sudo} echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | #{sudo} tee /etc/apt/sources.list.d/10gen.list"
    run "#{sudo} apt-get update"
    run "#{sudo} apt-get -y install mongodb-10gen"
  end
  after "deploy:install", "mongodb:install"

  desc "Setup mongodb configuration for this application"
  task :setup, roles: :mongodb do
    template "mongodb.conf.erb", "/tmp/mongodb_conf"
    run "#{sudo} mv /tmp/mongodb_conf /etc/mongodb.conf; #{sudo} mkdir -p #{mongo_db_path}; #{sudo} chown mongodb:mongodb #{mongo_db_path}; #{sudo} mkdir -p #{backups_path}/mongo"
    template "backup_mongo.erb", "/tmp/backup_mongo"
    run "#{sudo} mv /tmp/backup_mongo /etc/cron.daily/backup_mongo; #{sudo} chmod u+x /etc/cron.daily/backup_mongo;"

    restart
  end
  after "deploy:setup", "mongodb:setup"

  %w[start stop restart].each do |command|
    desc "#{command} mongodb"
    task command, roles: :mongodb do
      run "#{sudo} service mongodb #{command}"
    end
  end
end

end