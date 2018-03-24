# !/bin/bash

# Configure aria2c for speedy ISO downloads

cd /vagrant
mkdir -p .aria2
cat <<ARIA > .aria2/aria2.conf
continue
dir=/vagrant
file-allocation=none
input-file=/vagrant/.aria2/input.conf
log-level=warn
max-connection-per-server=1
min-split-size=5M
server-stat-of=/vagrant/.aria2/server-stats
server-stat-if=/vagrant/.aria2/server-stats
uri-selector=feedback
max-concurrent-downloads=5
ARIA

