#!/bin/bash
#
# Download latest CentOS ISO (quick & dirty version)
#
# requires:
#  - aria2 (for speedy downloads)
#  - elinks (v2+ (epel), for grabbing iso mirror URLs
#
# This will need to be more robust for legacy CentOS images that have been
# retired to http://vault.centos.org, particularly since the vault mirrors
# don't always host them

[ $# -lt 1 ] && printf "ERROR: no arguments\n\nUsage:\n\t$0 [centos6|centos7]\n\n" && exit 2

[ "${SIMP_BUILDER_download_iso:-yes}" == yes ] || { echo "== skipping ${0}: SIMP_BUILDER_download_iso='${SIMP_BUILDER_download_iso}' (instead of 'yes')"; }

TARGETS=( "${@}" )
ARIA2_CONF="${PWD}/.aria2/aria2.conf"
DOWNLOADS_DIR=downloads

# vault
CENTOS_7_ISO_URL=${CENTOS_7_ISO_URL:-http://isoredirect.centos.org/centos/7/isos/x86_64/}
CENTOS_6_ISO_URL=${CENTOS_6_ISO_URL:-http://isoredirect.centos.org/centos/6/isos/x86_64/}

CENTOS_7_DVD="${CENTOS_7_DVD:-CentOS-7-x86_64-DVD-1708.iso}"
CENTOS_6_DVD_1="${CENTOS_6_DVD_1:-CentOS-6.9-x86_64-bin-DVD1.iso}"
CENTOS_6_DVD_2="${CENTOS_6_DVD_2:-CentOS-6.9-x86_64-bin-DVD2.iso}"

declare -A ISO_URLS=( [centos7]="${CENTOS_7_ISO_URL}" [centos6]="${CENTOS_6_ISO_URL}" )
declare -A ISO_DVDS=( [centos7]="${CENTOS_7_DVD}" [centos6]="${CENTOS_6_DVD_1}:${CENTOS_6_DVD_2}" )

mkdir -p ${DOWNLOADS_DIR}/isos

for os in "${TARGETS[@]}"; do

  url="${ISO_URLS[$os]}"
  IFS=: read -r -a isos <<< "${ISO_DVDS[$os]}"

  echo =======================================================================
  echo == Processing: $os
  echo ==
  echo == url: "${url}"
  echo == isos: "${isos[@]}"
  echo =======================================================================

  for iso in "${isos[@]}"; do
    date
    echo "== Processing ISO '${iso}':"
    links "${url}" -dump | grep x86_64 | awk '{print $2}' > ${DOWNLOADS_DIR}/servers.${os}
    sed -e "s@/\$@/${iso}@" ${DOWNLOADS_DIR}/servers.${os}  > ${DOWNLOADS_DIR}/servers.${os}.${iso}.urls
    tr "\n" "\t" < ${DOWNLOADS_DIR}/servers.${os}.${iso}.urls > x.$$
    cat x.$$ > ${DOWNLOADS_DIR}/servers.${os}.${iso}.urls

    aria2c --conf-path=${ARIA2_CONF} \
           --input-file ${DOWNLOADS_DIR}/servers.${os}.${iso}.urls \
           --dir=${DOWNLOADS_DIR}/isos
    date
    echo
    echo
  done

done
