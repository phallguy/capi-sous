capi-sous
=========

A collection of recipes for bootstrapping and managing a rails application hosted on EC2 supporting both
unibox (all services on a single server) and dedicate role servers.

https://github.com/phallguy/capi-sous

Usage
=====

Capi-sous is a recipe book for use with the [Capistrano Gem](https://github.com/capistrano/capistrano). Once Capistrano is configured for your project update the `deploy.rb` script to look like this

    # To setup new Ubuntu 13.04 server:
    # cap HOSTFILTER=server bootstrap
    # cap HOSTFILTER=server deploy:install
    # cap HOSTFILTER=server deploy:setup
    # cap HOSTFILTER=server deploy

    require 'capi_sous'

    sous_recipes %W{ monit dotfiles settings rvm nginx unicorn nodejs check mongodb mongoid memcached assets search }

    set :ec2_pem_file, "~/.ssh/acme.pem"
    set :application, "acme-com"
    set :domain_name, "acme.com"
    set :repository,  "git@github.org:acme/acme-com.git"



License
=======

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.