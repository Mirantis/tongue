#!/bin/bash
DOCUMENTPATH=/Users/pvieira/Downloads/tongue
GERRITUSER=pvieira

if ! command -v html2text 2>&1 >/dev/null; then
  echo "the command html2text could not be found. Installing"
  brew install html2text
  exit 1
fi
if ! command -v git 2>&1 >/dev/null; then
  echo "the command git could not be found. Installing"
  brew install git
  exit 1
fi

#Mirantis Documentation
git config --global init.defaultBranch master
rm -rf $DOCUMENTPATH/docs.mirantis.com
git init $DOCUMENTPATH/docs.mirantis.com/mcp/q4-18
git -C $DOCUMENTPATH/docs.mirantis.com/mcp/q4-18 clone "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/mcp/mcp-docs"
rm -rf $DOCUMENTPATH/docs.mirantis.com/mcp/q4-18/mcp-docs/doc/mcp-dev-specs
rm -rf $DOCUMENTPATH/docs.mirantis.com/mcp/q4-18/mcp-docs/doc/common

git init $DOCUMENTPATH/docs.mirantis.com/container-cloud/latest
git -C $DOCUMENTPATH/docs.mirantis.com/container-cloud/latest clone "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/kaas/kaas-docs"
find $DOCUMENTPATH/docs.mirantis.com/container-cloud/latest -type f -name "*.rst" -exec sed -i '' -e "s;{{ mos_name_abbr }};MOSK;g" -e "s;{{ mos_name_full }};Mirantis OpenStack for Kubernetes;g" {} \;

git init $DOCUMENTPATH/docs.mirantis.com/mosk/latest
git -C $DOCUMENTPATH/docs.mirantis.com/mosk/latest clone "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/openstack/openstack-docs"
find $DOCUMENTPATH/docs.mirantis.com/mosk/latest -type f -name "*.rst" -exec sed -i '' -e "s;{{ product_name_abbr }};MOSK;g" -e "s;{{ product_name_full }};Mirantis OpenStack for Kubernetes;g" {} \;

git init $DOCUMENTPATH/docs.mirantis.com/mke/3.8
git -C $DOCUMENTPATH/docs.mirantis.com/mke/3.8 clone "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/mke-docs"
git init $DOCUMENTPATH/docs.mirantis.com/mke/3.7
git -C $DOCUMENTPATH/docs.mirantis.com/mke/3.7 clone -b 3.7 "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/mke-docs"
git init $DOCUMENTPATH/docs.mirantis.com/mke/3.6
git -C $DOCUMENTPATH/docs.mirantis.com/mke/3.6 clone -b 3.6 "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/mke-docs"
git init $DOCUMENTPATH/docs.mirantis.com/mke/3.5
git -C $DOCUMENTPATH/docs.mirantis.com/mke/3.5 clone -b 3.6 "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/mke-docs"

git init $DOCUMENTPATH/docs.mirantis.com/msr/4.0
git -C $DOCUMENTPATH/docs.mirantis.com/msr/4.0 clone -b 4.0 "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/msr-docs"
git init $DOCUMENTPATH/docs.mirantis.com/msr/3.1
git -C $DOCUMENTPATH/docs.mirantis.com/msr/3.1 clone "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/msr-docs"
git init $DOCUMENTPATH/docs.mirantis.com/msr/3.0
git -C $DOCUMENTPATH/docs.mirantis.com/msr/3.0 clone -b 3.0 "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/msr-docs"
git init $DOCUMENTPATH/docs.mirantis.com/msr/2.9
git -C $DOCUMENTPATH/docs.mirantis.com/msr/2.9 clone -b 2.9 "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/msr-docs"
git init $DOCUMENTPATH/docs.mirantis.com/msr/2.8
git -C $DOCUMENTPATH/docs.mirantis.com/msr/2.8 clone -b 2.8 "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/msr-docs"

git init $DOCUMENTPATH/docs.mirantis.com/mcr/25.0
git -C $DOCUMENTPATH/docs.mirantis.com/mcr/25.0 clone "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/mcr-docs"
git init $DOCUMENTPATH/docs.mirantis.com/mcr/23.0
git -C $DOCUMENTPATH/docs.mirantis.com/mcr/23.0 clone -b 23.0 "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/mcr-docs"
git init $DOCUMENTPATH/docs.mirantis.com/mcr/20.10
git -C $DOCUMENTPATH/docs.mirantis.com/mcr/20.10 clone -b 20.10 "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/mcr-docs"
git init $DOCUMENTPATH/docs.mirantis.com/mcr/19.03
git -C $DOCUMENTPATH/docs.mirantis.com/mcr/19.03 clone -b 19.03 "ssh://$GERRITUSER@gerrit.mcp.mirantis.com:29418/docs/mcr-docs"

git init $DOCUMENTPATH/github.com/k0rdent/docs
git -C $DOCUMENTPATH/github.com/k0rdent/docs reset --hard
git -C $DOCUMENTPATH/github.com/k0rdent/docs pull https://github.com/k0rdent/docs.git

#UBUNTU DOCUMENTATION
git init $DOCUMENTPATH/documentation.ubuntu.com/server
#git -C $DOCUMENTPATH/documentation.ubuntu.com sparse-checkout set server/
#git -C $DOCUMENTPATH/documentation.ubuntu.com config core.sparseCheckout true
git -C $DOCUMENTPATH/documentation.ubuntu.com/server reset --hard
git -C $DOCUMENTPATH/documentation.ubuntu.com/server pull https://github.com/canonical/ubuntu-server-documentation.git

#CLOUD-INIT
wget -c -N -r --no-parent -A html -t 1 https://cloudinit.readthedocs.io/en/latest/ --directory-prefix $DOCUMENTPATH

#KUBERNETES DOCUMENTATION
git init $DOCUMENTPATH/kubernetes.io
git -C $DOCUMENTPATH/kubernetes.io sparse-checkout set content/en
git -C $DOCUMENTPATH/kubernetes.io config core.sparseCheckout true
git -C $DOCUMENTPATH/kubernetes.io reset --hard
git -C $DOCUMENTPATH/kubernetes.io pull https://github.com/kubernetes/website.git
rm -rf $DOCUMENTPATH/kubernetes.io/content/en/blog

#LINUX KERNEL DOCUMENTATION
#wget -c -N -r --no-parent -A html -t 1 https://www.kernel.org/doc/html/latest/ --directory-prefix $DOCUMENTPATH
git init $DOCUMENTPATH/docs.kernel.org
git -C $DOCUMENTPATH/docs.kernel.org sparse-checkout set Documentation
git -C $DOCUMENTPATH/docs.kernel.org config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.kernel.org reset --hard
git -C $DOCUMENTPATH/docs.kernel.org pull https://github.com/torvalds/linux.git
rm -rf $DOCUMENTPATH/docs.kernel.org/Documentation/translations

#SYSTEMD DOCUMENTATION
wget -c -N -r --no-parent -A html -t 1 https://systemd.io --directory-prefix $DOCUMENTPATH
#wget -c -N -r --no-parent -A html -t 1 https://www.freedesktop.org/software/systemd/man/ --directory-prefix $DOCUMENTPATH
#wget -c -N -r --no-parent -A html -t 1 https://www.freedesktop.org/wiki/Software/systemd/TipsAndTricks/ --directory-prefix $DOCUMENTPATH
#wget -c -N -r --no-parent -A html -t 1 https://www.freedesktop.org/wiki/Software/systemd/FrequentlyAskedQuestions/ --directory-prefix $DOCUMENTPATH
#wget -c -N -r --no-parent -A html -t 1 https://www.freedesktop.org/wiki/Software/systemd/Debugging/ --directory-prefix $DOCUMENTPATH
#wget -c -N -r --no-parent -A html -t 1 https://www.freedesktop.org/wiki/Software/systemd/Incompatibilities --directory-prefix $DOCUMENTPATH
#wget -c -N -r --no-parent -A html -t 1 https://www.freedesktop.org/wiki/Software/systemd/DaemonSocketActivation --directory-prefix $DOCUMENTPATH
#wget -c -N -r --no-parent -A html -t 1 https://www.freedesktop.org/wiki/Software/systemd/separate-usr-is-broken --directory-prefix $DOCUMENTPATH
#wget -c -N -r --no-parent -A html -t 1 https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames --directory-prefix $DOCUMENTPATH
#wget -c -N -r --no-parent -A html -t 1 https://www.freedesktop.org/wiki/Software/systemd/APIFileSystems --directory-prefix $DOCUMENTPATH
#wget -c -N -r --no-parent -A html -t 1 https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget --directory-prefix $DOCUMENTPATH

#CALICO
git init $DOCUMENTPATH/docs.tigera.io
git -C $DOCUMENTPATH/docs.tigera.io sparse-checkout set calico
git -C $DOCUMENTPATH/docs.tigera.io config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.tigera.io reset --hard
git -C $DOCUMENTPATH/docs.tigera.io pull https://github.com/tigera/docs.git

#CEPH DOCUMENTATION
git init $DOCUMENTPATH/docs.ceph.com
git -C $DOCUMENTPATH/docs.ceph.com sparse-checkout set doc/
git -C $DOCUMENTPATH/docs.ceph.com config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.ceph.com reset --hard
git -C $DOCUMENTPATH/docs.ceph.com pull https://github.com/ceph/ceph.git

#RABBITMQ DOCUMENTATION
git init $DOCUMENTPATH/www.rabbitmq.com
git -C $DOCUMENTPATH/www.rabbitmq.com sparse-checkout set docs/
git -C $DOCUMENTPATH/www.rabbitmq.com config core.sparseCheckout true
git -C $DOCUMENTPATH/www.rabbitmq.com reset --hard
git -C $DOCUMENTPATH/www.rabbitmq.com pull https://github.com/rabbitmq/rabbitmq-website.git

#OPENSTACK
#glance
git init $DOCUMENTPATH/docs.openstack.org/glance
git -C $DOCUMENTPATH/docs.openstack.org/glance sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/glance config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/glance reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/glance pull https://opendev.org/openstack/glance.git
#nova
git init $DOCUMENTPATH/docs.openstack.org/nova
git -C $DOCUMENTPATH/docs.openstack.org/nova sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/nova config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/nova reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/nova pull https://opendev.org/openstack/nova.git
#cinder
git init $DOCUMENTPATH/docs.openstack.org/cinder
git -C $DOCUMENTPATH/docs.openstack.org/cinder sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/cinder config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/cinder reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/cinder pull https://opendev.org/openstack/cinder.git
#ironic
git init $DOCUMENTPATH/docs.openstack.org/ironic
git -C $DOCUMENTPATH/docs.openstack.org/ironic sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/ironic config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/ironic reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/ironic pull https://opendev.org/openstack/ironic.git
#horizon
git init $DOCUMENTPATH/docs.openstack.org/horizon
git -C $DOCUMENTPATH/docs.openstack.org/horizon sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/horizon config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/horizon reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/horizon pull https://opendev.org/openstack/horizon.git
#keystone
git init $DOCUMENTPATH/docs.openstack.org/keystone
git -C $DOCUMENTPATH/docs.openstack.org/keystone sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/keystone config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/keystone reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/keystone pull https://opendev.org/openstack/keystone.git
#neutron
git init $DOCUMENTPATH/docs.openstack.org/neutron
git -C $DOCUMENTPATH/docs.openstack.org/neutron sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/neutron config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/neutron reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/neutron pull https://opendev.org/openstack/neutron.git
#swift
git init $DOCUMENTPATH/docs.openstack.org/swift
git -C $DOCUMENTPATH/docs.openstack.org/swift sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/swift config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/swift reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/swift pull https://opendev.org/openstack/swift.git
#heat
git init $DOCUMENTPATH/docs.openstack.org/heat
git -C $DOCUMENTPATH/docs.openstack.org/heat sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/heat config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/heat reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/heat pull https://opendev.org/openstack/heat.git
#octavia
git init $DOCUMENTPATH/docs.openstack.org/octavia
git -C $DOCUMENTPATH/docs.openstack.org/octavia sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/octavia config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/octavia reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/octavia pull https://opendev.org/openstack/octavia.git
#contributors
git init $DOCUMENTPATH/docs.openstack.org/contributors
git -C $DOCUMENTPATH/docs.openstack.org/contributors sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/contributors config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/contributors reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/contributors pull https://opendev.org/openstack/contributor-guide.git
#arch-design
git init $DOCUMENTPATH/docs.openstack.org/arch-design
git -C $DOCUMENTPATH/docs.openstack.org/arch-design sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/arch-design config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/arch-design reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/arch-design pull https://opendev.org/openstack/arch-design.git
#operations-guide
git init $DOCUMENTPATH/docs.openstack.org/operations-guide
git -C $DOCUMENTPATH/docs.openstack.org/operations-guide sparse-checkout set doc/source releasenotes/source
git -C $DOCUMENTPATH/docs.openstack.org/operations-guide config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.openstack.org/operations-guide reset --hard
git -C $DOCUMENTPATH/docs.openstack.org/operations-guide pull https://opendev.org/openstack/operations-guide.git
find $DOCUMENTPATH/docs.openstack.org/ -type d -name locale -exec rm -rf {} \;
#find $DOCUMENTPATH/docs.openstack.org/ -type d -name releasenotes -exec rm -rf {} \;

#DOCKER
git init $DOCUMENTPATH/docs.docker.com
git -C $DOCUMENTPATH/docs.docker.com sparse-checkout set content/
git -C $DOCUMENTPATH/docs.docker.com config core.sparseCheckout true
git -C $DOCUMENTPATH/docs.docker.com reset --hard master
git -C $DOCUMENTPATH/docs.docker.com pull https://github.com/docker/docs.git

#PROMETHEUS
git init $DOCUMENTPATH/prometheus.io
git -C $DOCUMENTPATH/prometheus.io sparse-checkout set content/docs
git -C $DOCUMENTPATH/prometheus.io config core.sparseCheckout true
git -C $DOCUMENTPATH/prometheus.io reset --hard
git -C $DOCUMENTPATH/prometheus.io pull https://github.com/prometheus/docs.git
git init $DOCUMENTPATH/prometheus.io/alertmanager
git -C $DOCUMENTPATH/prometheus.io/alertmanager sparse-checkout set docs
git -C $DOCUMENTPATH/prometheus.io/alertmanager config core.sparseCheckout true
git -C $DOCUMENTPATH/prometheus.io/alertmanager reset --hard
git -C $DOCUMENTPATH/prometheus.io/alertmanager pull https://github.com/prometheus/alertmanager.git
mv $DOCUMENTPATH/prometheus.io/alertmanager/docs/* $DOCUMENTPATH/prometheus.io/content/docs/alerting/

#TUNGSTENFABRIC
git init $DOCUMENTPATH/github.com/OpenSDN-io/docs
git -C $DOCUMENTPATH/github.com/OpenSDN-io/docs reset --hard
git -C $DOCUMENTPATH/github.com/OpenSDN-io/docs pull https://github.com/OpenSDN-io/docs.git
rm -rf $DOCUMENTPATH/github.com/OpenSDN-io/docs/docsTools

#MARIADB
mkdir $DOCUMENTPATH/mariadb
rm -rf $DOCUMENTPATH/mariadb/*
wget https://mariadb.org/wp-content/uploads/2025/01/MariaDBServerKnowledgeBase.pdf --directory-prefix $DOCUMENTPATH/mariadb

echo "Converting html files to text format..."
#find $DOCUMENTPATH/* -type f -name "*.html" -exec sed -i -e "s/<[^>]*>//g" -e "/^$/d" -e "s:%25:%:g" -e "s|\&nbsp\;| |g" -e "s:%20: :g" -e "s:%3C:<:g" -e "s:%3E:>:g" -e "s:%23:#:g" -e "s:%7B:{:g" -e "s:%7D:}:g" -e "s:%40:@:g" -e "s:%7C:|:g" -e "s:%7E:~:g" -e "s:%5B:\[:g" -e "s:%5D:\]:g" -e "s:%3B:\;:g" -e "s:%2F:/:g" -e "s:%3F:?:g" -e "s^%3A^:^g" -e "s:%3D:=:g" -e "s:%26:&:g" -e "s:%24:\$:g" -e "s:%21:\!:g" -e "s:%2A:\*:g" -e "s:%22:\":g" -e "s:\&quot;:\":g" -e "s:\&#246;:ö:g" -e "s:\&\#252\;:ü:g" -e "s:\&\#196\;:Ä:g" -e "s:\&\#64\;:@:g" -e "s:\&amp;:\&:g" -e "s:\&gt\;:>:g" -e "s:\&lt\;:<:g" -e "s:\&\#160\;: :g" -e "s:\&\#39\;:\':g" -e "s:\&\#34\;:\":g" -e "s:\&lsquo\;:\‘:g" -e "s:\&rsquo\;:\’:g" -e "s:\&copy\;:©:g" {} \;

# Find all .html files in the current directory and below
#find $DOCUMENTPATH/* -type f -name "*.html" | while read file; do
grep -rl --include="*.html" "<head>" $DOCUMENTPATH/* | while read file; do
  # Extract the filename without extension (to use as output filename)
  name="${file%.*}"
  # Convert HTML to text using html2text
  echo "Converting $file to text..."
  output=$(echo "$name" | sed 's/\.html//')".txt"
  if html2text -utf8 -width 999999 "$file" >"$output"; then
    # Overwrite the original .html file with its text version
    echo "Overwriting $file with text version..."
    mv "$output" "$name.html"
  else
    echo "Error converting $file to text. Skipping."
  fi
done
echo "Removing html tags from files. This operation may take several minutes. Please wait"
find $DOCUMENTPATH/* -type f -name "*.md" -exec sed -i \0 -e "s/<[^>]*>//g" -e "/^$/d" {} \;
find $DOCUMENTPATH/* -type f -name "*.mdx" -exec sed -i \0 -e "s/<[^>]*>//g" -e "/^$/d" {} \;
find $DOCUMENTPATH/* -type f -name "*.rst" -exec sed -i \0 -e "s/<[^>]*>//g" -e "/^$/d" {} \;
find $DOCUMENTPATH/* -type f -name "*.md0" -exec rm {} \;
echo "Update completed."

