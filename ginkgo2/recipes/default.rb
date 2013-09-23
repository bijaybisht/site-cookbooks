#
# Cookbook Name:: ginkgo2-build-env
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#
# build user
#

_user_ = node[:ginkgo2][:user][:account]

_home_ = "/home/#{_user_}"

user_account _user_ do
  home _home_
end

template "#{_home_}/.netrc" do
  source    "dot.netrc.erb"
  variables ({
    :entries => [ node[:ginkgo2][:machine], node[:ginkgo2][:fqdn] ]
  })
  owner	_user_
end

template "#{_home_}/.gitconfig" do
  source    "dot.gitconfig.erb"
  variables ({
    :name => node[:ginkgo2][:user][:name],    
    :email => node[:ginkgo2][:user][:email]    
  })
  owner	_user_
end

# 
# packages
# 

include_recipe "ginkgo2::rpms"

#
# misc steps
# 

include_recipe "ginkgo2::maven"

execute "ln -s /usr/lib/jvm/java-1.6.0-sun-1.6.0.25/bin/xjc /usr/bin/xjc" do
  creates '/usr/bin/xjc'
end

user_account "postgres"

service "rngd" do
  action [:enable]
end

template "/etc/sysconfig/rngd" do
  source "rngd.erb"
end

service "rngd" do
  action [:restart]
end

package "xsd"

# 
# tools - gps
#

group "gps" do
  members [_user_]
end


execute "cd /tmp; sudo -u #{_user_} git clone #{node[:ginkgo2][:git_url]}/tools.git /tmp/tools" do
  creates "/tmp/tools"
end

bash "gps" do

  code <<-EOC

  cp /tmp/tools/misc/{gps,gps.common,gps-cache} /usr/local/bin
  mkdir -p /var/cache/gps/.locks
  chgrp -R gps /var/cache/gps
  chmod -R g+w /var/cache/gps
  
  EOC

  not_if "test -d /var/cache/gps/.locks"
end

# 
# sudo 
#

sudo _user_ do
  user _user_
end

#
# other packages
#

package "vim"
package "screen"
