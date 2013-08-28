Capistrano::Configuration.instance.load do

# Rake::Task['assets:precompile:all'].clear
namespace :assets do
  namespace :precompile do
    task :all do
      Rake::Task['assets:precompile:primary'].invoke
      # ruby_rake_task("assets:precompile:nondigest", false) if Rails.application.config.assets.digest
    end
  end
end

end