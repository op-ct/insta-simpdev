#!/bin/bash
#
# clone the simp-core repo
#

# Naive Puppetfile munge
for f in Puppetfile.*; do
  [ -f "${f}" ] && cp "${f}" simp-core/ && echo "  [${me}]: -- copy in new '${f}' file"
done

