Capistrano::Configuration.instance.load do

namespace :log do

  desc "Setup local app configuration, like passwords and other dynamic info"
  task :setup, roles: :app do
    
    template "logrotate.erb", "/tmp/logrotate"
    file = "/tmp/logrotate /etc/logrotate.d/#{safe_application_path}"
    run "#{sudo} mv -f #{file} && #{sudo} chmod g-w #{file} && #{sudo} chmod g-w #{shared_path}/log"

  end
  after "deploy:setup", "log:setup"  

end

end