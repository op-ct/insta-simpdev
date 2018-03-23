#!/bin/bash
#
# Usage
#
# environment variables:
#
#   $SIMP_CORE_REPO   https://github.com/simp/simp-core.git
#   $SIMP_CORE_REF    master

[ $# -lt 1 ] && printf "ERROR: no arguments\n\nUsage:\n\t$0 /path/to/CENTOS_ISO_FILE [...]\n\n" && exit 2

declare -a CENTOS_ISO_FILE=()
for i in "${@}"; do
  CENTOS_ISO_FILE+=( `realpath "${i}"` )
done

if [ ! -d simp-core ]; then
  # fetch `simp-core` repo @ ref
  git clone --depth 1 "${SIMP_CORE_REPO:-https://github.com/simp/simp-core.git}" -b "${SIMP_CORE_REF:-master}" simp-core
fi

# Naive Puppetfile munge
for f in Puppetfile.*; do
  [ -f "${f}" ] && cp "${f}" simp-core/ && echo "== copy in new '${f}' file"
done

# http://simp.readthedocs.io/en/master/getting_started_guide/ISO_Build/Building_SIMP_From_Source.html
cd simp-core
bundle install

mkdir -p ISO
for f in "${CENTOS_ISO_FILE[@]}"; do
  ln "${f}" ISO/$(basename "${f}")
done

export SIMP_BUILD_docs=${SIMP_BUILD_docs:-no}
export SIMP_ENV_NO_SELINUX_DEPS=${SIMP_ENV_NO_SELINUX_DEPS:-no}
export BEAKER_destroy=${BEAKER_destroy:-onpass}

time bundle exec rake beaker:suites[rpm_docker]
