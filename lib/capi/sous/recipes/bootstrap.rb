Capistrano::Configuration.instance.load do

namespace :bootstrap do
	desc "Bootstraps a server."
	task :default do
		copy_ssh_keys
		dotfiles.install
		update_system
		install_rsub
		hostname
	end

	set_default :ec2_root_user, "ubuntu"


	task :copy_ssh_keys do
		ssh_path = "/home/#{user}/.ssh"
		key_file = "#{ssh_path}/authorized_keys"
		find_servers_for_task(current_task).each do |server|
			`cat ~/.ssh/id_rsa.pub | ssh -i #{ec2_pem_file} #{ec2_root_user}@#{server} 'cat - > /tmp/authorized_keys; sudo useradd -m -s /bin/bash #{user} || true; sudo mkdir -p #{ssh_path}; sudo mv -f /tmp/authorized_keys #{key_file}; sudo chown #{user}:#{user} -R #{ssh_path}; sudo chmod 0600 #{key_file}; sudo sh -c "echo 127.0.0.1 $(hostname) >> /etc/hosts" '`
		end
		tmp = "/tmp/sudoer_for_user"
		sudoers = "/etc/sudoers.d/#{user}"
		disable_rvm_shell do
			template "deploy_sudoer.erb", tmp
			run "touch .ssh/known_hosts"
		end
		pwd = Capistrano::CLI.ui.ask "Password for deploy user: "
		find_servers_for_task(current_task).each do |server|
			`ssh -i #{ec2_pem_file} #{ec2_root_user}@#{server} 'sudo mv #{tmp} #{sudoers}; sudo chmod 0440 #{sudoers}; sudo chown root:root #{sudoers}; sudo passwd #{user} <<EOF
#{pwd}
#{pwd}
EOF'`
		end
	end

	task :update_system do
		disable_rvm_shell do
			run "#{sudo} apt-get -y update && #{sudo} apt-get -y upgrade"
		end
	end

	task :install_rsub do
		disable_rvm_shell do
			template "rsub", "/tmp/rsub"
			run "chmod +x /tmp/rsub && #{sudo} mv -f /tmp/rsub /usr/local/bin"
		end
	end

	task :hostname do
		disable_rvm_shell do
			find_servers_for_task(current_task).each do |server|
				host = server.to_s.gsub(/\.[^.]*\.[^.]*$/, '').gsub(/\./,'-')
				run "#{sudo} hostname #{host} && echo #{host} >> /tmp/hostname && #{sudo} mv -f /tmp/hostname /etc/hostname && cp -f /etc/hosts /tmp/hosts && echo 127.0.0.1 #{host} >> /tmp/hosts && #{sudo} mv -f /tmp/hosts /etc/hosts", hosts: server
			end
		end
	end

end

end