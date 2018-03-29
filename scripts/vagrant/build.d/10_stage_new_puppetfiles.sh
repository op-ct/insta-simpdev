#!/bin/bash
#
# Acquire new Puppetfile.* files before the iso build
me=$(basename $0)

# fetch Puppetfile.* repo @ ref
if [ -n "${SIMP_BUILDER_puppetfile_repo}" ]; then
  tmp_dir=$(mktemp -d -t build_iso.sh.XXXXXXXXXX)
  pushd "${tmp_dir}" &> /dev/null

  repo_url="${SIMP_BUILDER_puppetfile_repo}"
  repo_ref="${SIMP_BUILDER_puppetfile_ref:-master}"
  echo "  [${me}]: -- cloning repo with new Puppetfile.*: ${repo_url} -b ${repo_ref}"
  git clone --depth 1 "${repo_url}" -b "${repo_ref}" "${tmp_dir}"

  popd &> /dev/null
  mv "${tmp_dir}"/Puppetfile.* ./
  [[ -d "${tmp_dir}" ]] && rm -rf "${tmp_dir}"
fi
