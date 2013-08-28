#http://railscasts.com/episodes/337-capistrano-recipes
require 'capistrano'
require 'capistrano/cli'
require 'etc'

def template(from, to)

  rails_root = File.expand_path("..",ENV["BUNDLE_GEMFILE"])

  rails_path = File.join( rails_root, "config/recipes/templates", from )
  sous_path = File.expand_path("../templates/#{from}", __FILE__)

  path = File.exists?(rails_path) ? rails_path : sous_path

  erb = File.read( path )
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end


if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.load_paths << File.dirname(__FILE__)
end

module Capi::Sous
  module Configuration
    def sous_recipe(recipe)
      require "capi/sous/recipes/#{recipe}"
    end 

    def sous_recipes(recipes)
      [recipes].flatten.each do |recipe|
        sous_recipe(recipe)
      end
    end
  end
end

module Capistrano
  class Configuration
    # injects a fanfare_recipe helper method which can be used in the Capfile
    include Capi::Sous::Configuration
  end
end