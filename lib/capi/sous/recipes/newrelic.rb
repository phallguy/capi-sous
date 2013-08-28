Capistrano::Configuration.instance.load do

namespace :newrelic do

  namespace :server do

    task :install do
      run "#{sudo} wget -O /etc/apt/sources.list.d/newrelic.list http://download.newrelic.com/debian/newrelic.list && #{sudo} apt-key adv --keyserver hkp://subkeys.pgp.net --recv-keys 548C16BF && #{sudo} apt-get update && #{sudo} apt-get install newrelic-sysmond"
    end
    after "deploy:install", "newrelic:server:install"

    task :setup do
      run "#{sudo} nrsysmond-config --set license_key=52a44d3aee39a26d0f656c736a19a94b72a2b8e3"
      start
    end
    after "deploy:install", "newrelic:server:install"

    %w[start stop restart].each do |command|
      desc "#{command} newrelic server monitoring"
      task command do
        run "#{sudo} service newrelic-sysmond #{command}"
      end
    end

  end
end

end