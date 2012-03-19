#
# Author:: Sebastian Wendel
# Cookbook Name:: graylog2
# Attribute:: default
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

# graylog2 binary versions 
default['graylog2']['server_version'] = "0.9.6"
default['graylog2']['web_interface.version'] = "0.9.6"
default['graylog2']['download_url'] = "https://github.com/downloads/Graylog2"
default['graylog2']['download_server'] = "#{node['graylog2']['download_url']}/graylog2-server/graylog2-server-#{node['graylog2']['server_version']}.tar.gz"
default['graylog2']['download_web'] = "#{node['graylog2']['download_url']}/Graylog2/graylog2-web/graylog2-server-#{node['graylog2']['web_version']}.tar.gz"

# syslog4j binary versions
default['graylog2']['syslog4j_version'] = "0.9.46"
default['graylog2']['syslog4j_download'] = "http://syslog4j.org/downloads/syslog4j-#{node['graylog2']['syslog4j_version']}-bin.jar"

# server config
default['graylog2']['java_home'] = ENV['JAVA_HOME']
default['graylog2']['basedir'] = "/usr/share/graylog2"
default['graylog2']['server_user'] = "graylog2"
default['graylog2']['server_group'] = "graylog2"
default['graylog2']['storage_backend'] = "elasticsearch"
default['graylog2']['port'] = 514

# webfrontend config
default['graylog2']['www_user'] = "www-data"
default['graylog2']['www_group'] = "www-data"

# mongodb config
default['graylog2']['collection_size'] = 50000000

# notification config
default['graylog2']['send_stream_alarms'] = true
default['graylog2']['send_stream_subscriptions'] = true
default['graylog2']['stream_alarms_cron_minute'] = "*/15"
default['graylog2']['stream_subscriptions_cron_minute'] = "*/15"
