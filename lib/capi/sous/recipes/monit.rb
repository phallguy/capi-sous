Capistrano::Configuration.instance.load do

set_default( :monit_alert_email ){ "ops@#{domain_name}" }
set_default( :monit_service_email ){ "services@#{domain_name}" }
set_default( :monit_email_server ){ "smtp.gmail.com" }

namespace :monit do
  desc "Install Monit"
  task :install do
    run "#{sudo} apt-get -y install monit"
  end
  after "deploy:install", "monit:install"

  desc "Setup all Monit configuration"
  task :setup do
    grant
    monitrc  
    services
    syntax
    reload
  end
  after "deploy:setup", "monit:setup"
  
  task(:monitrc){ 
    set :monit_service_email_password, Capistrano::CLI.ui.ask( "Monit Services Email Password: " )
    monit_config "monitrc", "/etc/monit/monitrc" 
  }
  task(:nginx, roles: :web) { monit_config "nginx" }
  task(:postgresql, roles: :db) { monit_config "postgresql" }
  task(:unicorn, roles: :unicorn) { monit_config "unicorn", "#{safe_application_path}.conf" }
  task(:memcached, roles: :memcached) { monit_config "memcached" }
  task(:resque, roles: :resque) { monit_config "resque" }
  task(:resque_scheduler, roles: :resque_scheduler) { monit_config "resque_scheduler" }
  task(:redis, roles: :redis) { monit_config "redis" }
  task(:elasticsearch, roles: :elasticsearch) { monit_config "elasticsearch" }

  task :services do
  end

  task :grant do
    tmp = "/tmp/monit_sudoer"    
    sudo_file = "/etc/sudoers.d/monit_#{user}"

    template "monit/monit_sudoer.erb", tmp
    run "#{sudo} chmod 0440 #{tmp} && #{sudo} chown root:root #{tmp} && #{sudo} mv #{tmp} #{sudo_file}"
  end


  %w[start stop restart syntax reload].each do |command|
    desc "Run Monit #{command} script"
    task command do
      run "#{sudo} service monit #{command}"
    end
  end

end

def monit_config(name, destination = nil)
  destination = File.expand_path( destination || "#{name}.conf", "/etc/monit/conf.d/" )
  template "monit/#{name}.erb", "/tmp/monit_#{name}"
  run "#{sudo} mv /tmp/monit_#{name} #{destination}"
  run "#{sudo} chown root #{destination}"
  run "#{sudo} chmod 600 #{destination}"
end


end