#!/bin/bash

custom_scripts_dir=${SIMP_BUILDER_custom_scripts_dir:-/vagrant/scripts/custom}
vagrant_scripts_dir=${SIMP_BUILDER_vagrant_scripts_dir:-/vagrant/scripts/vagrant}
script_log_dir=${SIMP_BUILDER_log_dir:-/vagrant/logs/session_$$}
tasks=(setup build)
custom_users=(root vagrant)


# Return all files that match
#
# Examples:
#
#   00_do_a_thing.sh    # will execute first
#   01_do_next_thing.sh # will execute second
#   02_dont.sh.disables # will not execute
#
find_scripts_in()
{
    find $1/* -executable  -type f  -regextype posix-egrep \
       -regex '^.*/[0-9][0-9]_[^/]*'  ! -regex '^.*/[^/]*\.disabled$'  -print0
}

sanitize_to_env_var_name()
{
  local _env_var=$(echo "${1}" | sed -e 's/[^A-Za-z0-9_]/_/g' )
  [[ "${DEBUG}" -gt 0 ]] && echo "    ++ ${_env_var}  == '${!_env_var}' (env var)" 1>&2
  echo "${_env_var}"
}

# `continue` (skip) to the next iteration if a given env var's value is 'no'
#
# $1 = name of environment variable
# $2 = (optional) name of section
skip_if_env_var_is_no()
{
  local section=${2:-section}
  local env_var; { read env_var; } < <(sanitize_to_env_var_name "${1}")
  if [ "${!env_var}" == 'no' ]; then
    echo "!!!! WARNING: SKIPPING ${section} because ${env_var}=no"; continue
    continue
  else
    [[ ${DEBUG} -gt 1 ]] && echo "    --  OK  ${section}: $env_var='${!env_var}' (proceeding)" 1>&2
  fi
}


# $1 = full path to executable
run_script()
{
  [ $# -lt 1 ] && { printf "ERROR: '$0':\n\nusage:\n\t$0 FILE\n\n" && exit 3; }
  printf "\n== SIMP_BUILDER: executing '$1':\n\n"
  local script_dir=$(basename $(dirname $1))
  [[ "${script_dir}" =~ ^root. ]] && sudo="sudo -E" || sudo=
  mkdir -p "${script_log_dir}/${script_dir}"
  ${sudo} $1 |& tee "${script_log_dir}/${script_dir}/$(basename $1)"
}


# $1 = name of stage
# $2 = array of users
# $3 = (optional) directory containing scripts
run_stage()
{
  stage=$1
  declare -a users=("${!2}")
  _scripts_dir=${3:-${custom_scripts_dir}}
  skip_if_env_var_is_no "SIMP_BUILDER__stage_${stage}" stage

  for user in root vagrant; do
    skip_if_env_var_is_no "SIMP_BUILDER__user_${user}" user
    skip_if_env_var_is_no "SIMP_BUILDER__stage_${stage}__user_${user}"
    export SIMP_BUILDER_user="${user}"
    stage_user_scripts_dir="${_scripts_dir}/${user}.${stage}.d"
    n=0

    if [ ! -d "${stage_user_scripts_dir}" ]; then
      [[ "${DEBUG}" -gt 0 ]] && echo "WARNING: skipping non-existent directory '${stage_user_scripts_dir}'"
      continue
    fi

    find_scripts_in "${_scripts_dir}/${user}.${stage}.d" | while read -d $'\0' file; do
      file_name=$(basename "${file}")
      skip_if_env_var_is_no "SIMP_BUILDER__script_${file_name}" script
      skip_if_env_var_is_no "SIMP_BUILDER__stage_${stage}__user_${user}__script_${file_name}"
      run_script "${file}"
      (( ++n ))
    done
    echo "---- INFO: stage '$stage' user '$user': executed $n scripts"
  done
}

for task in "${tasks[@]}"; do
  printf "\n\n========================================\n"
  printf     "             TASK: ${task}\n"
  printf     "========================================\n\n"
  skip_if_env_var_is_no "SIMP_BUILDER__task_${task}" task

  export SIMP_BUILDER_task="${task}"
  run_stage "pre-${task}"  custom_users[@]
  run_stage "${task}"      vagrant "${vagrant_scripts_dir}"
  run_stage "post-${task}" custom_users[@]
  unset SIMP_BUILDER_task
done

echo 'done'
