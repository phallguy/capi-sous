Capistrano::Configuration.instance.load do
  namespace :assets do
    task :precompile, :roles => [:app] do
      if ! remote_file_exists?("#{current_path}/REVISION") || capture("cd #{latest_release} && #{source.local.log(source.next_revision(current_revision))} vendor/assets/ app/assets/ | wc -l").to_i > 0
        force_precompile
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end

    task :force_precompile, :roles => [:app] do
      run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
    end
  end
end