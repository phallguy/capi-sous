Capistrano::Configuration.instance.load do

namespace :sys do

  desc "Upgrades installed packages on the server."
	task :upgrade_packages do
    run "#{sudo} apt-get -y upgrade"			
	end

	desc "Restarts the server"
	task :restart do
		run "#{sudo} shutdown -r now"			
	end

end

end