Capistrano::Configuration.instance.load do

namespace :nodejs do
  desc "Install Node.js"
  task :install, roles: :app do
    run "#{sudo} apt-get -y install python-software-properties python g++ make"
    run "#{sudo} add-apt-repository -y ppa:chris-lea/node.js"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install nodejs"
  end
  after "deploy:install", "nodejs:install"
end

end