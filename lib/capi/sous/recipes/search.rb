Capistrano::Configuration.instance.load do

set_default :search_indices do
  ENV["CLASS"] || "Item"
end

namespace :search do

  def indices
    search_indices.split(",").map(&:strip).compact
  end

  desc "tail production log files" 
  task :reindex, :roles => :app do
    
  end

  task :import, :roles => :app do
    host = find_servers_for_task(current_task).first.host
    indices.each do |index|
      run "cd #{current_path}; bundle exec rake RAILS_ENV=production CLASS=#{index} FORCE=1 environment tire:import", hosts: host
    end
  end

  task :delete_index, :roles => :app do
    host = find_servers_for_task(current_task).first.host
    indices.each do |index|
      run "cd #{current_path}; bundle exec rake RAILS_ENV=production CLASS=#{index} FORCE=1 environment tire:index:drop", hosts: host
    end
  end
  
end

end