Capistrano::Configuration.instance.load do


set_default( :firewal_ports ){ %w{ http https } }
set_default( :firewall ){ true }

namespace :firewall do

  namespace :install do
    desc "Install everything onto the server"
    task :default do
      disable_rvm_shell do
        install_ufw
        setup_defaults
        open_ports
        firewall.enable
      end
    end

    task :install_ufw do
      run "#{sudo} apt-get -y install ufw"
    end

    task :setup_defaults do
      run "echo 'y' | #{sudo} ufw reset && #{sudo} ufw default deny incoming && #{sudo} ufw allow ssh"
    end

    task :open_ports do
      firewal_ports.each do |port|
        run "#{sudo} ufw allow #{port}"
      end
    end


  end

  task :enable do
    run "echo 'y' | #{sudo} ufw enable && #{sudo} ufw status"
  end

  task :disable do
    run "echo 'y' | #{sudo} ufw disable && #{sudo} ufw status"
  end


end


end