require 'capistrano/fanfare'


Capistrano::Configuration.instance.load do
  fanfare_recipe 'assets'
end
