#!/bin/bash 
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
for file in "${ISO_FILES[@]}"; do
  filename="$(basename "${file}")"
  file_mount=$(findmnt -T "${file}" -P)

  if [ "${simp_core_mount}" = "${file_mount}" ]; then
    ln -f "${f}" ISO/"${filename}"
  else
    rsync -avz --progress "${file}" ISO/"${filename}"
  fi
done
