Capistrano::Configuration.instance.load do


namespace :deploy do
  namespace :release do

    desc "Creatse a REVISION file for the current git hash for use as a 'release version' in the app."
    task :mark, roles: :app, except:  { no_release: true } do 
      run "cd #{current_path} && git rev-parse --short HEAD > REVISION"
    end
    after "deploy:finalize_update", "deploy:release:mark"
    

  end
end

end