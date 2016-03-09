# Copyright 2014 N3TWORK, Inc.
#
# Licensed under Apache 2.0 - see the LICENSE file


include_recipe "apt"

# Install zookeeper
node.set[:exhibitor][:opts][:port] = 8000
include_recipe "zookeeper::default"

node.set['mysql']['server_root_password'] = ''
#include_recipe "mysql::server"

# Create the druid db
include_recipe "database::postgresql"

mysql_database 'druid' do
  connection(
      :host     => 'localhost',
      :username => 'root',
      :password => node['mysql']['server_root_password']
  )
  action :create
end

# Configure Druid
node.set[:druid][:properties]['druid.zk.service.host'] = 'localhost'
node.set[:druid][:properties]['druid.metadata.storage.type'] = 'mysql'
node.set[:druid][:properties]['druid.metadata.storage.connector.connectURI'] = 'jdbc:mysql://localhost/druid'
node.set[:druid][:properties]['druid.metadata.storage.connector.user'] = 'root'
node.set[:druid][:properties]['druid.metadata.storage.connector.password'] = node['mysql']['server_root_password']
node.set[:druid][:properties]['druid.computation.buffer.size'] = 10 * 1024 * 1024

# From Historical node quickstart http://druid.io/docs/latest/Historical-Config.html
node.set[:druid][:properties]['druid.server.maxSize'] = 10000000000
node.set[:druid][:properties]['druid.processing.buffer.sizeBytes'] = 100000000
node.set[:druid][:properties]['druid.processing.numThreads'] = 1
node.set[:druid][:properties]['druid.segmentCache.locations'] =
    '[{"path": "/tmp/druid/indexCache", "maxSize": 10000000000}]'

# Realtime wikipedia example
node.set[:druid][:realtime][:properties]['druid.realtime.specFile'] =
    "#{node[:druid][:install_dir]}/current/examples/wikipedia/wikipedia_realtime.spec"

# Install the Druid services
include_recipe "druid::historical"
include_recipe "druid::coordinator"
include_recipe "druid::broker"
include_recipe "druid::realtime"

package "curl" do
  action :install
end

# Fix up the example client to point to our broker
execute "fix example client URL" do
  command "sed -i 's|localhost:[0-9]*/druid/v2/?w|localhost:8080/druid/v2/?pretty|' #{node[:druid][:install_dir]}/current/run_example_client.sh"
end

execute "fix example client permissions" do
  command "chmod 755 #{node[:druid][:install_dir]}/current/run_example_client.sh"
end
