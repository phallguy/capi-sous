require 'capistrano/fanfare'


Capistrano::Configuration.instance.load do
  fanfare_recipe 'defaults'
  fanfare_recipe 'git_style'
  fanfare_recipe 'bundler'
  fanfare_recipe 'colors'
  fanfare_recipe 'log'
end
