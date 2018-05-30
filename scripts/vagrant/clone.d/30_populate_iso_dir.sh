#!/bin/bash
#
# 1. Create the 'simp-core/ISO' directory
# 2. Link or copy *.iso files under `$SIMP_BUILDER_iso_dir` into 'simp-core/ISO'
#
# Notes:
#
#   * files on the same mount as 'simp-core/ISO' will be hard-linked
#   * files that are (somehow) on different mounts will be rsynced
#

declare -a ISO_FILES=()

if [[ $? -eq 0 ]]; then
  while read -d $'\0' file; do
    declare -a -g ISO_FILES
    echo "Found ISO file: '${file}'"
    ISO_FILES+=( "${file}" )
  done < <( find "${SIMP_BUILDER_iso_dir:-/vagrant/downloads/isos}" -type f \
            -iname \*.iso -print0 )
else
  for i in "${@}"; do
    [[ -d "${i}" ]]
    ISO_FILES+=( $(realpath "${i}") )
  done
fi

cd simp-core

simp_core_mount=$(findmnt -T . -P)
mkdir -p ISO
for src_file in "${ISO_FILES[@]}"; do
  file_name="$(basename "${src_file}")"
  file_mount=$(findmnt -T "${src_file}" -P)

  if [ "${simp_core_mount}" = "${file_mount}" ]; then
    ln -f "${src_file}" ISO/"${file_name}"
  else
    rsync -avz --progress "${src_file}" ISO/"${file_name}"
  fi
done
