Capistrano::Configuration.instance.load do

set_default( :elasticsearch_cluster_name ) { application_namespace.gsub /-\w{2,3}+$/, "" }
set_default( :elasticsearch_server ) { "elasticsearch.#{vpc_domain_name}:9200" }
set_default( :elasticsearch_url ) { "http://#{elasticsearch_server}" }
set_default( :elasticsearch_path ){ "#{deploy_root}/elasticsearch" }
set_default( :elasticsearch_heap_size ) { "256m" }

namespace :elasticsearch do

  desc "Install elasticsearch"
  task :install, roles: :elasticsearch do
    run "#{sudo} apt-get update"
    run "#{sudo} apt-get -y install openjdk-7-jre-headless"

    run "wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.5.deb; #{sudo} dpkg -i elasticsearch-0.90.5.deb;"
    head_plugin
  end
  after "deploy:install", "elasticsearch:install"

  task :head_plugin, roles: :elasticsearch do
    run "#{sudo} /usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head"
  end

  %w[start stop restart].each do |command|
    desc "#{command} mongodb"
    task command, roles: :elasticsearch do
      # run "#{sudo} service elasticsearch #{command}"
      run "#{sudo} monit #{command} elasticsearch"
    end
  end

  desc "Import "
  task :import, :roles => :app do
    host = find_servers_for_task(current_task).first.host
    run "cd #{current_path}; bundle exec rake RAILS_ENV=#{rails_env} rebuild_search_index", hosts: host
  end

end

end