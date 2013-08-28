namespace :deploy do
  namespace :release do

    desc "Creatse a REVISION file for the current git hash for use as a 'release version' in the app."
    task :mark, roles: :app, except:  { no_release: true } do 
      run "cd #{current_path} && git rev-parse --short HEAD > REVISION"
    end
    after "deploy:finalize_update", "deploy:release:mark"

    task :force_asset_symlink, roles: :app, except: { no_release: true } do
      if repository
        deploy.assets.symlink
      end
    end
    # Force a symlink of the assets immediately after updating the code cause git deletes everything on update code
    before "deploy:finalize_update", "deploy:release:force_asset_symlink"

  end
end