#!/bin/bash -e

[ "${SIMP_BUILDER_install_rvm:-yes}" == yes ] || { echo "== skipping ${0}: SIMP_BUILDER_install_rvm='${SIMP_BUILDER_install_rvm}' (instead of 'yes')"; }

# Install RVM

gpg-agent --daemon; :
# Note: the RVM GPG servers have been having problems recently, so if one fails
# we'll try the other one.
gpg2 --verbose  --keyserver hkp://keys.gnupg.net --recv-keys \
  409B6B1796C275462A1703113804BB82D39DC0E3 \
  7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
|| gpg2 --verbose --keyserver hkp://pgp.mit.edu --recv-keys \
  409B6B1796C275462A1703113804BB82D39DC0E3 \
  7D2BAF1CF37B13E2069D6956105BD0E739499BDB

[ -f install_rvm.sh ] || curl -sSL https://get.rvm.io > install_rvm.sh
bash install_rvm.sh stable '--with-default-gems=gitlab rake'
source "${HOME:-/home/vagrant}/.rvm/scripts/rvm"
rvm install --disable-binary ruby-2.1.9
gem install bundler --no-document

# If there is a Gemfile already under /vagrant, we should bundle it immediately.
# This could save a lot of time building a gem cache later on.
cd /vagrant
[ -f Gemfile ] && bundle --verbose

# we need to kill the gpg-agent in order to stop tee from stalling
pkill gpg-agent

