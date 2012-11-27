#http://railscasts.com/episodes/337-capistrano-recipes
require 'capistrano'
require 'capistrano/cli'
require 'etc'

def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  logger.info user
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

Capistrano::Configuration.instance.load do

  namespace :deploy do
    desc "Install everything onto the server"
    task :install, depends: ["with_sudo"] do
      run "#{sudo} apt-get -y update"
    end
  end

  task :with_sudo do
    set :sudo_user, fetch(:sudo_user,Etc.getlogin)
    set :user, sudo_user
  end
end

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each { |f| load f }
