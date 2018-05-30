#!/bin/bash
#
# Build the simp ISO using [rpm_docker]

source /home/vagrant/.rvm/scripts/rvm

# http://simp.readthedocs.io/en/master/getting_started_guide/ISO_Build/Building_SIMP_From_Source.html
cd simp-core
bundle install

export SIMP_BUILD_docs=${SIMP_BUILD_docs:-no}
export SIMP_ENV_NO_SELINUX_DEPS=${SIMP_ENV_NO_SELINUX_DEPS:-no}
export BEAKER_destroy=${BEAKER_destroy:-onpass}

time bundle exec rake 'beaker:suites[rpm_docker]'
