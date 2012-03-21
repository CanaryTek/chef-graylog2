#
# Cookbook Name:: graylog2
# Recipe:: server
#
# Copyright 2012, SourceIndex IT-Serives
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "java"

server_storage      = node['graylog2']['server_storage']
server_user         = node['graylog2']['server_user']
server_group        = node['graylog2']['server_group']
server_path         = node['graylog2']['server_path']
server_download     = node['graylog2']['server_download']
server_version      = node['graylog2']['server_version']
server_file         = node['graylog2']['server_file']
server_checksum     = node['graylog2']['server_checksum']
syslog4j_version    = node['graylog2']['syslog4j_version']
syslog4j_file       = node['graylog2']['syslog4j_file']
syslog4j_download   = node['graylog2']['syslog4j_download']
syslog4j_checksum   = node['graylog2']['syslog4j_checksum']
syslog4j_path       = node['graylog2']['syslog4j_path']

if (server_storage == "elasticsearch")
    include_recipe "elasticsearch"
    template "/etc/graylog2.conf" do
        source "graylog2_elasticsearch.conf.erb"
        mode 0644
    end
elsif (server_storage == "mongodb")
    include_recipe "mongodb"
    template "/etc/graylog2.conf" do
        source "graylog2_mongodb.conf.erb"
        mode 0644
    end
end

group server_group do
    system true
end

user server_user do
    home server_path
    comment "services user for graylog2-server"
    gid server_group
    shell "/bin/false"
    system true
end

log "Created service user #{server_user} and group #{server_group} to run graylog2." do
    action :nothing
end

unless FileTest.exists?("#{server_path}/#{server_version}")
    directory server_path do
        mode 0755
        owner server_user
        group server_group
    end

    remote_file "#{Chef::Config[:file_cache_path]}/#{server_download}" do
        source server_download
        checksum server_checksum
        action :create_if_missing
    end

    bash "install_server" do
        cwd Chef::Config[:file_cache_path]
        creates server_path
        code "tar -zxvf #{server_file} -C #{server_path}"
    end

    link "#{server_path}/current" do
        to "#{server_path}/#{server_version}"
    end
end

log "Downloaded, installed and configured the Graylog2 binary files in #{server_path}/#{server_version}." do
    action :nothing
end

unless FileTest.exists?("#{syslog4j_path}/#{syslog4j_version}")
    directory syslog4j_path do
        mode 0755
    end

    remote_file "#{syslog4j_path}/#{syslog4j_file}" do
        source syslog4j_download
        checksum syslog4j_checksum
        action :create_if_missing
    end

    link "#{syslog4j_path}/syslog4j-current-bin.jar" do
        to "#{syslog4j_path}/#{syslog4j_file}"
    end
end

log "Downloaded, installed and configured the syslog4j binary files for graylog2 logging in #{syslog4j_path}/#{syslog4j_version}." do
    action :nothing
end

template "/etc/init.d/graylog2" do
    source "graylog2.init.erb"
    owner "root"
    group "root"
    mode "0755"
end

execute "update-rc.d graylog2 defaults" do
    creates "/etc/rc0.d/K20graylog2"
    action :nothing
    subscribes :run, resources(:template => "/etc/init.d/graylog2"), :immediately
end

service "graylog2" do
  supports :restart => true
  action [:enable, :start]
end

log "Installed the Graylog2 init file /etc/init.d/graylog2, change the runlevel and startet the service." do
    action :nothing
end
