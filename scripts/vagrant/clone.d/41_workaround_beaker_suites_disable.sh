#!/bin/bash
#
# FIXME: Works around https://github.com/simp/simp-core/pull/522, which
#        inadvertently and *completely* disables rpm_docker
if [ -f simp-core/spec/acceptance/suites/rpm_docker/metadata.yml ]; then
  rm -f simp-core/spec/acceptance/suites/rpm_docker/metadata.yml
fi

