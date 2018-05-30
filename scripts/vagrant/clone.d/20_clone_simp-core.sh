#!/bin/bash
#
# clone the simp-core repo
#
#

repo_url="${SIMP_BUILDER_core_repo:-https://github.com/simp/simp-core.git}"
repo_ref="${SIMP_BUILDER_core_ref:-master}"

me=$(basename "$0")

if [ -d ./simp-core ]; then
  echo "  [${me}]: ---------------------------------------------------------------------"
  echo "  [${me}]: -- WARNING: Skipping git clone; directory 'simp-core' already exists."
  echo "  [${me}]: ---------------------------------------------------------------------"
else
  # fetch `simp-core` repo @ ref
  echo "  [${me}]: -- cloning ${repo_url} -b ${repo_ref}"
  git clone --depth 1 "${repo_url}" -b "${repo_ref}" simp-core
fi
