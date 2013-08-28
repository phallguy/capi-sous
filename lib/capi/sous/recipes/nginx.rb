Capistrano::Configuration.instance.load do

namespace :nginx do

  # Use SSL by default for all NGINX connectiosn.
  set_default :use_ssl, true

  desc "Install nginx"
  task :install, roles: :web do
    run "#{sudo} add-apt-repository -y ppa:nginx/stable && #{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install nginx"
  end
  after "deploy:install", "nginx:install"

  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    template "nginx_unicorn.erb", "/tmp/nginx_conf"
    run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{safe_application_path}"
    run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
    restart    
  end
  after "deploy:setup", "nginx:setup"
  after "monit:services", "monit:nginx"

  desc "Setup root nginx configuration for ALL applications"
  task :setup_root, roles: :web do
    template "nginx_root.erb", "/tmp/nginx_conf"
    run "#{sudo} mv /tmp/nginx_conf /etc/nginx/nginx.conf"
    restart
  end

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end

  namespace :ssl do
    task :generate_csr, roles: :web do
      run %|cd /tmp && openssl req -nodes -newkey rsa:2048 -nodes -keyout server.key -out server.csr -subj "/C=US/ST=California/L=Murietta/O=RESC/OU=IT/CN=#{domain_name}"|
      csr = "/tmp/#{safe_application_path}.csr"
      download "/tmp/server.csr", csr
      run "#{sudo} mkdir -p /etc/nginx/certificates/#{safe_application_path} && #{sudo} mv -f /tmp/server.key /etc/nginx/certificates/#{safe_application_path}/server.key && #{sudo} mv -f /tmp/server.csr /etc/nginx/certificates/#{safe_application_path}/server.csr"
      `cat #{csr}`
    end
  end
end

end