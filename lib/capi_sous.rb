require 'capistrano'
require 'capistrano/cli'
require 'base'

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each { |f| load f }
