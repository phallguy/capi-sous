Capistrano::Configuration.instance.load do

namespace :bootstrap do
	desc "Bootstraps a server."
	task :default do
		copy_ssh_keys
		dotfiles.install
		update_system
		install_rsub
		hostname
		swapfile
		create_deploy_keys
		copy_deploy_keys
		show_deploy_keys
	end

	set_default :ec2_root_user, "ubuntu"
	set_default :digitalocean_root_user, "root"

	set_default :vps_provider, :digitalocean
	set_default :swap_file_size, 4096
	set_default( :deploy_keys ){ "~/.ssh/#{safe_application}_rsa" }
	set( :expanded_deploy_keys ){ deploy_keys && File.expand_path( deploy_keys ) }

	set_default( :root_user ) {
		vps_provider == :ec2 ? ec2_root_user : digitalocean_root_user
	}


	task :copy_ssh_keys do
		ssh_path = "/home/#{user}/.ssh"
		key_file = "#{ssh_path}/authorized_keys"
		find_servers_for_task(current_task).each do |server|
			`cat ~/.ssh/id_rsa.pub | ssh -i #{ssh_pem_file} #{root_user}@#{server} 'cat - > /tmp/authorized_keys; sudo useradd -m -s /bin/bash #{user} || true; sudo mkdir -p #{ssh_path}; sudo mv -f /tmp/authorized_keys #{key_file}; sudo chown #{user}:#{user} -R #{ssh_path}; sudo chmod 0600 #{key_file}; sudo sh -c "echo 127.0.0.1 $(hostname) >> /etc/hosts" '`
		end
		tmp = "/tmp/sudoer_for_user"
		sudoers = "/etc/sudoers.d/#{user}"
		disable_rvm_shell do
			template "deploy_sudoer.erb", tmp
			run "touch .ssh/known_hosts"
		end
		pwd = Capistrano::CLI.ui.ask "Password for deploy user: "
		find_servers_for_task(current_task).each do |server|
			`ssh -i #{ssh_pem_file} #{root_user}@#{server} 'sudo mv #{tmp} #{sudoers}; sudo chmod 0440 #{sudoers}; sudo chown root:root #{sudoers}; sudo passwd #{user} <<EOF
#{pwd}
#{pwd}
EOF'`
		end
	end

	task :copy_deploy_keys do
		if deploy_keys = fetch(:expanded_deploy_keys,nil)
			disable_rvm_shell do
				upload deploy_keys, "/tmp/id_rsa"
				run "mv /tmp/id_rsa ~/.ssh/id_rsa; chmod 0600 ~/.ssh/id_rsa"
				pub_keys = "#{deploy_keys}.pub"
				upload pub_keys, "/tmp/id_rsa.pub"
				run "mv /tmp/id_rsa.pub ~/.ssh/id_rsa.pub; chmod 0600 ~/.ssh/id_rsa.pub"
			end
		end
	end

	task :create_deploy_keys do		
		unless File.exist?(expanded_deploy_keys)
			`ssh-keygen -C "Deploy keys for #{application}." -q -N "" -f #{expanded_deploy_keys} -t rsa`
		end
	end

	task :show_deploy_keys do
		puts "\n\nYOUR SSH PUBLIC DEPLOY KEYS\n\nRemember to add these to github or bitbucket for read-only access.\n\n"
		keys = `cat #{expanded_deploy_keys}.pub`
		puts keys
		puts "\n\n"

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

	# enable swap file
	# https://www.digitalocean.com/community/articles/how-to-add-swap-on-ubuntu-12-04

	task :swapfile do
		disable_rvm_shell do
			if swap_file_size && swap_file_size > 0
				run "#{sudo} dd if=/dev/zero of=/swapfile bs=1024 count=#{swap_file_size}k && #{sudo} mkswap /swapfile && #{sudo} swapon /swapfile && cp -f /etc/fstab /tmp/fstap && echo /swapfile none swap sw 0 0 >> /tmp/fstab && #{sudo} mv -f /tmp/fstab /etc/fstab"
				run "echo 10 | #{sudo} tee /proc/sys/vm/swappiness && echo vm.swappiness = 10 | #{sudo} tee -a /etc/sysctl.conf"
				run "#{sudo} chown root:root /swapfile && #{sudo} chmod 0600 /swapfile"
			end
		end
	end

end

end