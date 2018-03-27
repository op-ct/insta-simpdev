#!/bin/bash

custom_dir=${SIMP_BUILDER_custom_scripts_dir:-/vagrant/scripts/custom}

find_scripts_in()
{
    find $1/* \
       -type f -regextype posix-egrep -regex '^.*/[0-9][0-9]_[^/]*' \
       ! -regex '^.*/[^/]*\.disabled$' -print0
}


find_scripts_in $custom_dir/root.pre-build.d | while read -d $'\0' file; do
  printf "== executing '$file':\n\n"
done

find_scripts_in $custom_dir/vagrant.pre-build.d | while read -d $'\0' file; do
  printf "== executing '$file':\n\n"
done



find_scripts_in $custom_dir/root.post-build.d | while read -d $'\0' file; do
  printf "== executing '$file':\n\n"
done

find_scripts_in $custom_dir/vagrant.post-build.d | while read -d $'\0' file; do
  printf "== executing '$file':\n\n"
done

echo 'done'
