require 'capistrano/ext/multistage'

module Capi
  module Sous
  end
end

require 'capi/sous/shared'
require 'capi/sous/fanfare'

require 'capi/sous/recipes/base'
require 'capi/sous/recipes/sys'
require 'capi/sous/recipes/bootstrap'
require 'capi/sous/recipes/check'
require 'capi/sous/recipes/log'

Capistrano::Configuration.instance.load do
  set_default :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
end