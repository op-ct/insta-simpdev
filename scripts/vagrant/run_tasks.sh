#!/bin/bash

scripts_dir=${SIMP_BUILDER_scripts_dir:-/vagrant/scripts}
custom_scripts_dir=${SIMP_BUILDER_custom_scripts_dir:-$scripts_dir/custom}
script_log_dir=${SIMP_BUILDER_log_dir:-$scripts_dir/../logs/session_$$}
dry_run_mode=${SIMP_BUILDER_dry_run:-no}

# ordered list of tasks to run
IFS=',' read -r -a tasks <<< "${SIMP_BUILDER_tasks:-setup,clone,build}"

# ordered list of users to run scripts in each stage
stage_users=(vagrant)

# ordered list of users that can provide pre-stage or post-stage custom scripts
IFS=',' read -r -a custom_users <<< "${SIMP_BUILDER_users:-root,vagrant}"

# Return the names of all *executable* file that match \d\d_.*
#
# Criteria:
#
# * executable files MUST be marked as executable (obviously)
# * executable filenames MUST start with a double-digit number
# * executable filenames that end in `.disabled` will be skipped
#
# Examples:
#
#   -rwx------. 00_do_a_thing.sh      # will execute first
#   -rwx------. 01_do_next_thing.sh   # will execute second
#   -rw-------. 03_not_executable.sh  # won't execute (not executable)
#   -rwxrwxr--. 02_dont.sh.disabled   # won't execute (disabled)
#   -rwx------. no_number.sh          # won't execute (missing number)
#
# $1 = directory to search for scripts ${_scripts_dir}/${user}/${stage}.d
find_scripts_in()
{
    find $1/ -executable  -type f  -regextype posix-egrep \
       -regex '^.*/[0-9][0-9]_[^/]*'  ! -regex '^.*/[^/]*\.disabled$'  -print0
}

# Convert a string into an acceptable environment variable name
#
# $1 = string to sanitize
sanitize_to_env_var_name()
{
  local _env_var=$(echo "${1}" | sed -e 's/[^A-Za-z0-9_]/_/g' )
  [[ "${DEBUG}" -gt 2 ]] && echo "    |++  ${_env_var}  == '${!_env_var}' (env var)" 1>&2
  echo "${_env_var}"
}

# `continue` (skip) the current loop iteration if a specified env var is 'no'
#
# NOTE: Any invalid characters (for var names) will be santized into '_'
#
# $1 = string, name of the environment variable to test
# $2 = [optional] label for this loop iteration (used in the skip message)
skip_if_env_var_is_no()
{
  local section=${2:-section}
  local env_var; { read env_var; } < <(sanitize_to_env_var_name "${1}")
  if [ "${!env_var}" == 'no' ]; then
    echo "    |!!  WARNING: SKIPPING ${section} because ${env_var}=no"
    continue
  else
    [[ ${DEBUG} -gt 1 ]] && echo "    |--  skip_if_env_var_is_no():  ${section}: $env_var='${!env_var}' (proceeding)" 1>&2
  fi
}


# $1 = full path to executable
run_script()
{
  [ $# -lt 1 ] && { printf "ERROR: '$0':\n\nusage:\n\t$0 FILE\n\n" && exit 3; }

  local script_dir=$(basename $(dirname $1))
  local script_parent_dir=$(basename $(dirname $(dirname $1)))

  [[ "${script_dir}" =~ ^root ]] && sudo="sudo -E " || sudo=
  if [[ "${dry_run_mode}" == 'yes' ]]; then
    echo "==  SIMP_BUILDER: [dry-run] would have executed ${sudo}${script_parent_dir}/${script_dir}/$(basename ${1})"
    continue
  fi
  printf "\n==  SIMP_BUILDER: executing '$1':\n\n"

  local _log_dir="${script_log_dir}/${script_dir}"
  mkdir -p ${_log_dir} || echo "WARNING: could not create log dir at ${_log_dir}"

  [[ ${DEBUG} -gt 0 ]] &&  echo "    |-   run_script():  ${sudo} $1 |& tee '${_log_dir}/$(basename $1).log'"
  [[ ${DEBUG} -gt 1 ]] &&  echo "    |--  run_script():  _log_dir=${_log_dir}"
  ${sudo} $1 |& tee "${_log_dir}/$(basename $1).log"
}


# $1 = name of stage
# $2 = array of users
# $3 = [optional] directory containing scripts, default: $custom_scripts_dir
run_stage()
{
  stage=$1
  declare -a users=("${!2}")
  _scripts_dir=${3:-${custom_scripts_dir}}
  skip_if_env_var_is_no "SIMP_BUILDER__stage_${stage}" stage

  [[ "${DEBUG}" -gt 0 ]] && echo "    |--  run_stage(): stage: ${stage}, users ("${#users[@]}"): ${users[@]}"

  for user in ${users[@]}; do
    skip_if_env_var_is_no "SIMP_BUILDER__stage_${stage}__user_${user}" stage
    skip_if_env_var_is_no "SIMP_BUILDER__user_${user}" user

    export SIMP_BUILDER_user="${user}"
    local stage_user_scripts_dir="${_scripts_dir}/${user}/${stage}.d"
    local n=0

    if [ -d "${stage_user_scripts_dir}" ]; then
      [[ "${DEBUG}" -gt 0 ]] && echo "  --+--  STAGE $stage   USER $user"
    else
      [[ "${DEBUG}" -gt 0 ]] && echo "    |!!  run_stage(): skipping non-existent directory '${stage_user_scripts_dir}'"
      continue
    fi

    # Execute each script in order
    find_scripts_in "${stage_user_scripts_dir}" | sort -z | while read -d $'\0' file; do
      file_name=$(basename "${file}")
      skip_if_env_var_is_no "SIMP_BUILDER__script_${file_name}" script
      skip_if_env_var_is_no "SIMP_BUILDER__stage_${stage}__user_${user}__script_${file_name}"
      run_script "${file}"
      (( ++n ))
    done
    unset SIMP_BUILDER_user

    if [[ "${DEBUG}" -gt 1 ]] && [[ "${n}" -gt 0 ]]; then
      echo "    |--  Stage '$stage' user '$user': executed $n scripts"
    fi
  done
}


options=("${@}")
while getopts ":hn" opt; do
  case ${opt} in
    h )
      echo "Usage:"
      echo "    $0 [options]"
      echo
      echo "Options:"
      echo "    -h    Display this help message."
      echo "    -n    Dry run mode (don't execute scripts)"
      exit 0
      ;;
    n )
      dry_run_mode=yes
      ;;
    \? )
      echo "Invalid Option: -$OPTARG" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))


for task in "${tasks[@]}"; do
  printf "\n\n    ==+======================================\n"
  printf     "               TASK: ${task}\n"
  printf     "    ==+======================================\n\n"
  skip_if_env_var_is_no "SIMP_BUILDER__task_${task}" task

  export SIMP_BUILDER_task="${task}"
  run_stage "pre-${task}"  custom_users[@]
  run_stage "${task}"      stage_users[@] "${scripts_dir}"
  run_stage "post-${task}" custom_users[@]
  unset SIMP_BUILDER_task
done

echo 'done'
