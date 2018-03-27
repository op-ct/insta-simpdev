#!/bin/bash
#
# Build the simp ISO using [rpm_docker]

if [ "${SIMP_BUILDER__task}" == build ]; then
  TARGETS=( "${@}" )
elif [ $# -lt 1 ]; then
  printf "ERROR: no arguments\n\nUsage:\n\t$0 [centos6|centos7]\n\n"
  exit 1
else
  TARGETS=( "${@}" )
fi
( [[ "${1}" == '-h' ]] || [[ "${1}" == '--help' ]] )  && printf "Usage:\n\t$0 /path/to/CENTOS_ISO_FILE [...]\n\n" && exit 2
exit 3

declare -a CENTOS_ISO_FILE=()
if [[ $? -eq 0 ]]; then
  declare -a CENTOS_ISO_FILE
  find ${SIMP_BUILDER_iso_dir:/vagrant/downloads/isos} -type -f -iname \*.iso \
    -print0 | while read -d $'\0' file; do
  done
fi

for i in "${@}"; do
  CENTOS_ISO_FILE+=( `realpath "${i}"` )
done

if [ ! -d simp-core ]; then
  # fetch `simp-core` repo @ ref
  git clone --depth 1 "${SIMP_BUILDER_core_repo:-https://github.com/simp/simp-core.git}" -b "${SIMP_BUILDER_core_ref:-master}" simp-core
fi

if [ -n "${SIMP_BUILDER_puppetfile_repo}" ]

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
