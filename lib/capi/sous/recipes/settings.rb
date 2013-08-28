Capistrano::Configuration.instance.load do

load "config/recipes/settings"

set_default :vpc_domain_name do
  "vpc.#{domain_name}"
end

set_default :elasticsearch_prefix do
  "#{deploy_env}_"
end



setting_prompts.each do |k,v|
  set_default k do
    current = get_current_setting(k)
    Capistrano::CLI.ui.ask "#{v} " do |question|
      question.default = current.to_s
    end
  end
end

def get_current_setting(name)
  root,key = name.to_s.split("_", 2)
  if current_server_settings.has_key?(root)
    current_server_settings[root][key]
  end
end


namespace :settings do

  set :local_settings_file do
    "#{shared_path}/config/settings.local.yml"
  end

  desc "Setup local app configuration, like passwords and other dynamic info"
  task :setup, roles: :app do
    generate
  end
  after "deploy:setup", "settings:setup"  

  desc "Re-generate the local settings file prompting for all secure info"
  task :generate, roles: :app do
    run "mkdir -p #{shared_path}/config"
    get_current_settings
    template "settings.yml.erb", local_settings_file
  end

  task :get_current_settings, roles: :app do
    local = "/tmp/#{safe_application_path}.settings.yml"
    if remote_file_exists?(local_settings_file)
      download local_settings_file, local
      yml = YAML::load(File.open(local))
      set :current_server_settings, yml
    else
      set :current_server_settings, {}
    end
  end

  desc "Symlink local config files to the current release."
  task :symlink, roles: :app , except: { no_release: true } do
    run "ln -fsn #{shared_path}/config/* #{current_path}/config/"
  end
  before "deploy:finalize_update", "settings:symlink"
end

end