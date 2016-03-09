name             'chef-druid-example'
maintainer       'N3TWORK'
maintainer_email 'yuval@n3twork.com'
license          'Apache 2.0'
description      'Installs an example druid single-node cluster'
long_description 'Installs/Configures chef-druid-example'
version          '0.0.1'

depends "apt"
depends "database"
depends "druid"
#depends "mysql"
depends "zookeeper"

