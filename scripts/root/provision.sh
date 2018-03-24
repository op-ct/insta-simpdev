#!/bin/bash

yum install --enablerepo=extras -y docker vim-enhanced git libicu-devel \
                                   rpm-build rpmdevtools epel-release
yum install --enablerepo=epel -y aria2 elinks haveged

# enable HAVEGED
# --------------------
# This gives the VM's /dev/*random sufficient entropy for all the crypto
# in the build
systemctl start haveged
systemctl enable haveged

# Install docker
# --------------------
# You can also append `-G vagrant` to `OPTIONS=` in /etc/sysconfig/docker
cat <<DOCKAH > /etc/docker/daemon.json
{
"live-restore": true,
"group": "vagrant"
}
DOCKAH

# man docker-storage-setup
# https://bugzilla.redhat.com/show_bug.cgi?id=1316210
echo 'EXTRA_STORAGE_OPTIONS="--storage-opt overlay2.override_kernel_check=true"' >> /etc/sysconfig/docker-storage-setup
container-storage-setup
systemctl start docker
systemctl enable docker

chown -R vagrant /vagrant # TODO: why is this needed?
ls -lartZ /var/run/docker.sock
