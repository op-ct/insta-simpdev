#!/bin/bash
#
# Build the simp ISO using [rpm_docker]


if [ "${SIMP_BUILDER_task}" == build ]; then
  TARGETS=( "${@}" )
elif [ $# -lt 1 ]; then
  printf "ERROR: no arguments\n\nUsage:\n\t$0 /path/to/CENTOS_ISO_FILE [...]  \n\n"
  exit 1
else
  TARGETS=( "${@}" )
fi

me=$(basename $0)
declare -a CENTOS_ISO_FILE=()

if [[ $? -eq 0 ]]; then
  while read -d $'\0' file; do
    declare -a -g CENTOS_ISO_FILE
     echo "Found ISO file: '${file}'"
     CENTOS_ISO_FILE+=( "${file}" )
  done < <( find ${SIMP_BUILDER_iso_dir:-/vagrant/downloads/isos} -type f \
            -iname \*.iso -print0 )
else
  for i in "${@}"; do
    [[ -d "${i}" ]]
    CENTOS_ISO_FILE+=( `realpath "${i}"` )
  done
fi

if [ -d ./simp-core ]; then
  echo "  [${me}]: ---------------------------------------------------------------------"
  echo "  [${me}]: -- WARNING: Skipping git clone; directory 'simp-core' already exists."
  echo "  [${me}]: ---------------------------------------------------------------------"
else
  # fetch `simp-core` repo @ ref
  repo_url="${SIMP_BUILDER_core_repo:-https://github.com/simp/simp-core.git}"
  repo_ref="${SIMP_BUILDER_core_ref:-master}"
  echo "  [${me}]: -- cloning ${repo_url} -b ${repo_ref}"
  git clone --depth 1 "${repo_url}" -b "${repo_ref}" simp-core
fi

# Naive Puppetfile munge
for f in Puppetfile.*; do
  [ -f "${f}" ] && cp "${f}" simp-core/ && echo "  [${me}]: -- copy in new '${f}' file"
done

source /home/vagrant/.rvm/scripts/rvm

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
