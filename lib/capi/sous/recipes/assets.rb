require 'capistrano/fanfare'


Capistrano::Configuration.instance.load do
  fanfare_recipe 'assets'
end

namespace :deploy do
  namespace :assets do
    task :force_asset_symlink, roles: :app, except: { no_release: true } do
      if repository
        # deploy.assets.symlink
      end
    end
    # Force a symlink of the assets immediately after updating the code cause git deletes everything on update code
    before "deploy:finalize_update", "deploy:assets:force_asset_symlink"
  end  
end
