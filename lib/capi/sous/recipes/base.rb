Capistrano::Configuration.instance.load do

set_default :required_pkgs, %W{ git git-core htop unattended-upgrades tcl imagemagick s3cmd htop }
set_default( :deploy_root ){ "/srv" }
set_default( :db_path ){ "#{deploy_root}/db" }
set_default( :backups_path ){ "#{deploy_root}/backups" }
set_default( :s3_bucket_prefix ){ safe_application.gsub(/_/, '-') }
set_default( :s3_backups_bucket ){ "#{s3_bucket_prefix}-backups" }
set_default :maintenance_template_path, File.expand_path("../templates/maintenance.html.erb", __FILE__)

set_default( :safe_application ) { application.gsub(/[^a-z0-9]/, '_') }
set_default( :application_path ){ "#{application}_#{deploy_env}" }
set_default( :safe_application_path ){ application_path.gsub(/[^a-z0-9]/, '_') }
set( :deploy_to ){ "#{deploy_root}/apps/#{safe_application_path}" }


namespace :deploy do

  namespace :install do
    desc "Install everything onto the server"
    task :default do
      disable_rvm_shell do
        update_system
        required_packages
        unattended_upgrades
      end
    end

    task :update_system do
      run "#{sudo} apt-get -y update"
    end

    task :required_packages do
      run "#{sudo} apt-get -y install #{required_pkgs.join ' '}" if required_pkgs.any?      
    end

    task :unattended_upgrades do
      disable_rvm_shell do
        template "60unattended-upgrades-security.erb", "/tmp/60unattended-upgrades-security"  
        run "#{sudo} mv /tmp/60unattended-upgrades-security /etc/apt/apt.conf.d/60unattended-upgrades-security"
      end
    end
  end

  task :setup_apps_dir, except: { no_release: true } do
    apps_path = File.dirname( deploy_to )
    run "#{sudo} mkdir -p #{apps_path} && #{sudo} chown #{user}:#{user} #{apps_path};"
  end
  before "deploy:setup", "deploy:setup_apps_dir"

  task :setup_backups do

    set :aws_access_key, Capistrano::CLI.ui.ask("AWS Key: ")
    set :aws_secret_key, Capistrano::CLI.ui.ask("AWS Secret: ")

    template "s3cfg.erb", "/tmp/s3cfg"
    run "#{sudo} mkdir -p #{backups_path}; #{sudo} mv /tmp/s3cfg /root/.s3cfg"
  end
  before "deploy:setup", "deploy:setup_backups"
end


end