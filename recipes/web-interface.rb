#
# Cookbook Name:: graylog2
# Recipe:: web-interface
#
# Copyright 2012, SourceIndex IT-Services
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

# VARIABLES LOCAL
ruby_version     = node['graylog2']['ruby_version']
web_path         = node['graylog2']['web_path']
web_user         = node['graylog2']['web_user']
web_group        = node['graylog2']['web_group']
web_download     = node['graylog2']['web_download']
web_version      = node['graylog2']['web_version']
web_file         = node['graylog2']['web_file']
web_checksum     = node['graylog2']['web_checksum']

# DEPENDENCIES COOKBOOKS
include_recipe "graylog2::apache2"
include_recipe "ruby_build"

# DEPENDENCIES PACKAGES
package "postfix"

# CREATE GROUPS
group web_group do
    system true
end

# CREATE USER
user web_user do
  home web_path
  comment "services user for thr graylog2-web-interface"
  gid web_group
  shell "/bin/bash"
end

# CREATE FOLDER
directory web_path do
    action :create
end

# SET FOLDER PERMISSIONS
directory web_path do
    owner web_user
    group web_group
    mode "0755"
end

node['rbenv']['user_installs'] = [
  { 'user'    => web_user,
    'rubies'  => [ruby_version],
      'global'  => ruby_version
   }
]

node['rbenv']['gems'] = {
  ruby_version => [
    { 'name'    => web_user },
      { 'name'    => 'bundler' }
  ]
}

include_recipe "rbenv::user"


#rbenv_script "migrate_rails_database" do
#  rbenv_version "1.8.7-p352"
#  user "deploy"
#  group "deploy"
#  cwd "/srv/webapp/current"
#  code %{rake RAILS_ENV=production db:migrate}
#end

unless FileTest.exists?("#{web_path}/graylog2-web-interface-#{web_version}")
    remote_file "#{Chef::Config[:file_cache_path]}/#{web_file}" do
        source web_download
        checksum web_checksum
        action :create_if_missing
    end

    bash "install graylog2 sources #{web_file}" do
        cwd Chef::Config[:file_cache_path]
        code <<-EOH
            tar -zxf #{web_file} -C #{web_path}
        EOH
    end

    link "#{web_path}/current" do
        to "#{web_path}/graylog2-web-interface-#{web_version}"
    end
    log "Downloaded, installed and configured the Graylog2 Web binary files in #{web_path}/#{web_version}." do
        action :nothing
    end
end

execute "graylog2-web-interface owner-change" do
    command "chown -Rf #{web_user}:#{web_group} #{web_path}"
end

template "#{web_path}/graylog2-web-interface-#{web_version}/config/general.yml" do
    owner "nobody"
    group "nogroup"
    mode 0644
end

cron "Graylog2 send stream alarms" do
    minute node['graylog2']['stream_alarms_cron_minute']
    action node['graylog2']['send_stream_alarms'] ? :create : :delete
    command "cd #{web_path}/current && RAILS_ENV=production bundle exec rake streamalarms:send"
end

cron "Graylog2 send stream subscriptions" do
    minute node['graylog2']['stream_subscriptions_cron_minute']
    action node['graylog2']['send_stream_subscriptions'] ? :create : :delete
    command "cd #{web_path}/current && RAILS_ENV=production bundle exec rake subscriptions:send"
end
