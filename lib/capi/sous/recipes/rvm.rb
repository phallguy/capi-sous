require 'rvm/capistrano'

Capistrano::Configuration.instance.load do

after 'deploy:install:update_system', 'rvm:install_ruby'
before 'rvm:install_ruby', 'rvm:install_rvm'

def disable_rvm_shell(&block)
  old_shell = self[:default_shell]
  self[:default_shell] = nil
  yield
  self[:default_shell] = old_shell
end

set_default :rvm_required_pkgs,  %W{ build-essential gcc gawk make libc6-dev libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev autoconf libc6-dev libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev }

namespace :rvm do

	task :install_required_pkgs do
		disable_rvm_shell do
			run "#{sudo} apt-get -y install #{rvm_required_pkgs.join ' '}"
		end
	end
	before "rvm:install_ruby", "rvm:install_required_pkgs"

	task :enable_autolibs do
		disable_rvm_shell do
			run "~/.rvm/bin/rvm autolibs enable"
		end
	end
	before "rvm:install_ruby", "rvm:enable_autolibs"

	task :trust_rvmrc do
		run "rvm rvmrc warning ignore #{current_path}/.rvmrc"
		run "rvm rvmrc trust #{current_path}/.rvmrc"
	end
	after "deploy:finalize_update", "rvm:trust_rvmrc"
end

end