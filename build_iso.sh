#!/bin/bash


[ "${CENTOS_ISO_FILE:-x}" == 'x' ] && echo "Error: need to set \$CENTOS_ISO_FILE" && exit 2


# fetch `simp-core` repo @ ref
git clone --depth 1 "${SIMP_CORE_REPO:-https://github.com/simp/simp-core.git}" -b "${SIMP_CORE_REF:-master}" simp-core

# skip Puppetfile munge for now

# http://simp.readthedocs.io/en/master/getting_started_guide/ISO_Build/Building_SIMP_From_Source.html
cd simp-core
bundle install
mkdir -p ISO

rsync -avz --progress ${CENTOS_ISO_FILE} ISO/


export SIMP_BUILD_docs=${SIMP_BUILD_docs:-no}
export SIMP_ENV_NO_SELINUX_DEPS=${SIMP_ENV_NO_SELINUX_DEPS:-no}
export BEAKER_destroy=${BEAKER_destroy:-onpass}

rake beaker:suites[rpm_docker]
