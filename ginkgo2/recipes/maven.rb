#
# Cookbook Name:: ginkgo2-build-env
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

remote_file  "wget #{node[:ginkgo2][:packages_url]}/tar/ginkgo2/apache-maven-3.0.4-bin.tar.gz"

bash "maven" do

  code <<-EOF
  mkdir -p /usr/local/apache-maven
  tar -C /usr/local/apache-maven -xf apache-maven-3.0.4-bin.tar.gz
  ln -s /usr/local/apache-maven/apache-maven-3.0.4/bin/mvn /usr/bin/mvn
  EOF

  not_if "test -s /usr/bin/mvn"

end

template "/usr/local/apache-maven/apache-maven-3.0.4/conf/settings.xml" do
  source "maven_settings.xml.erb"
  variables({
    :url => node[:ginkgo2][:mavenrepo_url]
  })
end
