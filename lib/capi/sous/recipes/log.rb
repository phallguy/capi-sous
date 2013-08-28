Capistrano::Configuration.instance.load do

namespace :log do

  desc "Setup local app configuration, like passwords and other dynamic info"
  task :setup, roles: :app do
    
    template "logrotate.erb", "/tmp/logrotate"
    run "#{sudo} mv -f /tmp/logrotate /etc/logrotate.d/#{safe_application_path}"

  end
  after "deploy:setup", "log:setup"  

  # desc "tail production log files" 
  # task :tail, :roles => :app do
  #   trap("INT") { puts; puts 'Interupted'; exit 0; }
  #   run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
  #     # puts  # for an extra line break before the host name
  #     puts "#{channel[:host]}: #{data}" 
  #     break if stream == :err
  #   end
  # end
end

end