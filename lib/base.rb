#http://railscasts.com/episodes/337-capistrano-recipes
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

  # alias_method :original_sudo, :sudo
  def sudo
    logger.info "Using sudo did you include with_sudo task?" unless exists?(:sudo_user)
    super
  end

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