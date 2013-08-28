Capistrano::Configuration.instance.load do

namespace :dotfiles do
	desc "Installs common dotfiles to the deploy user to make it easier to work with when sshing to server."
	task :install do
		%W{bashrc profile bash_profile}.each do |file|
			template "dotfiles/#{file}", ".#{file}"
		end
	end
end

end