## SIMP build environment

<!-- vim-markdown-toc GFM -->

* [Description](#description)
* [Usage](#usage)
  * [Requirements](#requirements)
  * [Building an ISO](#building-an-iso)
    * [..staging an alternate `simp-core`](#staging-an-alternate-simp-core)
    * [...staging alternate `Puppetfile.*` files](#staging-alternate-puppetfile-files)
  * [Getting ISOs out of the VM](#getting-isos-out-of-the-vm)
    * [Using `scp`](#using-scp)
    * [Using `vagrant-rsync-back`](#using-vagrant-rsync-back)
* [Environment variables](#environment-variables)
  * [Vagrantfile variables](#vagrantfile-variables)
    * [Pass-through variables](#pass-through-variables)
  * [Task loop variables](#task-loop-variables)
    * [`provision` variables](#provision-variables)
    * [`setup` variables](#setup-variables)
    * [`clone` variables](#clone-variables)
    * [`build` variables](#build-variables)
  * ["Kill switch" variables](#kill-switch-variables)
* [Reference](#reference)
  * [How the build process works](#how-the-build-process-works)
    * [`vagrant up`](#vagrant-up)
    * [Build tasks](#build-tasks)
    * [Task stages](#task-stages)
  * [Customizing tasks with `*.d/` scripts](#customizing-tasks-with-d-scripts)

<!-- vim-markdown-toc -->


## Description

The Vagrantfile in this repository will provision a CentOS 7 Virtualbox VM that
can build SIMP ISOs using the `rpm_docker` beaker suite.

You can use it to:

- Build SIMP ISOs when you don't have access to docker/Linux (useful for
  building from OSX or Windows).
- Provision a VM to template as a CI runner to build SIMP ISOs (useful for
  nightly builds and testing).
- Inject speculative/customized `Puppetfile.*` files into the SIMP ISO build
  (useful for regression-testing).


## Usage

      [environment variables*] vagrant up

`*` = See the [Environment variables](#environment-variables) section for details.

There are plenty of ways to stage files before and after you run `vagrant up`

### Requirements

- [Vagrant][vagrant]
- [VirtualBox][virtualbox]


### Building an ISO

By default, a `vagrant up` will provision a VM and run the tasks
**provision**, **setup**, **`clone`**, and **build**.

This will install and configure build tools like RVM, download the ISOs for
CentOS 6 and CentOS 7, `git clone` the `simp-core` repository, and build SIMP
ISOs using the **rpm_docker** Beaker Suite.

* ISO files will remain on the VM until fetched


#### ..staging an alternate `simp-core`

By default, the **build** task will clone a fresh copy of `simp-core` from git.

- If `/vagrant/simp-core/` is already present before the **build.d** scripts
  run, it will be used instead of cloning a fresh copy from git.

#### ...staging alternate `Puppetfile.*` files

- Any `Puppetfile.*` files that are present in the top level `/vagrant`
  directory by the **build.d** stage will be copied into `simp-core` (replacing
  any existing files with the same names), just prior to building the ISO.


### Getting ISOs out of the VM

#### Using `scp`

```bash
# Dump ssh-config for VM:
vagrant ssh-config > .vagrant-ssh-config

# To retrieve *.iso files:
scp -F .vagrant-ssh-config
  simp_builder:/vagrant/simp-core/build/distributions/*/*/*/SIMP_ISO/*.iso ./

# To retrieve the *.iso and *.tar.gz files:
scp -F .vagrant-ssh-config \
  simp_builder:/vagrant/simp-core/build/distributions/*/*/*/{SIMP_ISO/*.{iso,json},DVD_Overlay/*.tar.gz} ./
```


#### Using `vagrant-rsync-back`

```bash
# Ensure the `vagrant-rsync-back` plugin is installed:
vagrant plugin install vagrant-rsync-back

# Rsync ALL the contents of /vagrant back to the host machine:
# (NOTE: this may take a while!)
vagrant rsync-back
```


## Environment variables

Many environment (ENV) variables have been exposed for the benefit of power-users and
CI:

### Vagrantfile variables

 These variables customize affect the `vagrant up` and provisioning process:

| Variable | Purpose |
| -------- | ------- |
| **`VAGRANT_VBOX_NAME`** |An alternate name for the local vagrant VM (default: `simp_builder`) |
| **`VAGRANT_VM_CPUS`**   |The number of CPUs available to the VM (default: `8`) |


#### Pass-through variables

The Vagrantfile  will pass environment variables through to the guest VM's OS
during `vagrant up` if they match any of these patterns:

- `SIMP_*`
- `BEAKER_*`
- `FACTER_*`
- `PUPPET_*`
- `*NO_SELINUX_DEPS*`
- `DEBUG`
- `VERBOSE`

This is useful to influence the `SIMP_BUILDER_` and rake tasks within the VM.

### Task loop variables


| Variable                              | Purpose                              |
| ------------------------------------- | ------------------------------------ |
| **`SIMP_BUILDER_tasks`**              |(default: `$scripts_dir/../logs/session_$$`) |
| **`SIMP_BUILDER_users`**              |(default: `$scripts_dir/../logs/session_$$`) |
| **`SIMP_BUILDER_dry_run`**            |(default: `no`)                              |
| **`SIMP_BUILDER_custom_scripts_dir`** |(default: `${scripts_dir}/custom`)           |
| **`SIMP_BUILDER_log_dir`**            |(default: `$scripts_dir/../logs/session_$$`) |
| **`DEBUG`**                           | Loop debug message verbosity (e.g., `1`, `2`) |


#### `provision` variables

| Variable                | Purpose                                            |
| ----------------------- | -------------------------------------------------- |
| **`SIMP_BUILDER_install_rvm`** | Whether or not to install RVM (default: `yes`) |


#### `setup` variables

| Variable                | Purpose                                            |
| ----------------------- | -------------------------------------------------- |
| **`SIMP_BUILDER_download_iso`** | Unless set to `no`, the VM will attempt to download simp ISOs to `downloads/isos/` after provisioning (default: `yes`).
| **`CENTOS_7_ISO_URL`** | (default: `http://isoredirect.centos.org/centos/7/isos/x86_64/`) |
| **`CENTOS_7_DVD`** | (default: `CentOS-7-x86_64-DVD-1708.iso`) |
| **`CENTOS_6_ISO_URL`** | (default: `http://isoredirect.centos.org/centos/6/isos/x86_64/`) |
| **`CENTOS_6_DVD_1`** | (default: `CentOS-6.9-x86_64-bin-DVD1.iso`) |
| **`CENTOS_6_DVD_2`** | (default: `CentOS-6.9-x86_64-bin-DVD2.iso`) |


#### `clone` variables

| Variable                        | Purpose                                    |
| --------------------------------| ------------------------------------------ |
| **`SIMP_BUILDER_iso_dir`**      | Directory containing OS `*.iso` files (default: `/vagrant/downloads/isos`)
| **`SIMP_BUILDER_core_repo`** | simp-core repo to fetch (default: https://github.com/simp/simp-core.git)
| **`SIMP_BUILDER_core_ref`** | simp-core ref to fetch (default: `master`)
| **`SIMP_BUILDER_puppetfile_repo`** | Puppetfile repo to fetch (default: https://github.com/simp/simp-core.git)
| **`SIMP_BUILDER_puppetfile_ref`** | Puppetfile ref to fetch (default: `master`)


#### `build` variables

These variables affect the build scripts under `scripts/vagrant/`.  They are
effective during provisioning and when the scripts are run within the guest OS:

| Variable | Purpose |
| -------- | ------- |
| **`SIMP_BUILDER_download_iso`** | Unless set to `no`, the VM will attempt to download simp ISOs to `downloads/isos/` after provisioning (default: `yes`).
| **`SIMP_BUILDER_build_iso`**    | Unless set to `no`, the VM will attempt to build the SIMP ISO using the isos in the directory `downloads/isos/` (default: `yes`)


### "Kill switch" variables

You can stop any combination of stage, task, and user scripts from running by
setting specially-named environment variables:

```bash

# Skip the entire 'build' task
SIMP_BUILDER__task_build=no

# Skip the actual build stage (but let pre-build and post-build run)
SIMP_BUILDER__stage_build=no

# Disable all (task) scripts run as root (note: by default, there aren't any)
SIMP_BUILDER__user_root=no

# Don't run any of the vagrant user's post-setup scripts
SIMP_BUILDER__stage_post_setup__user_vagrant=no

# Don't run the custom script root/post-build.d/00_root.sh
# (All special characters will be underscores)
SIMP_BUILDER__stage_post_build__user_root__script_00_root_sh=no

```


## Reference

### How the build process works

The build process runs some shell scripts that prepare the environment and
build an ISO.  These scripts are designed to give CI systems control of every
aspect of the process by providing:

* **Environment variables** to customize any task, stage, or script
* Pre- and post-task **`*.d/` directory hooks** to place your own customization
  scripts
* Special marshalling locations to staging specific builds

#### `vagrant up`

By default, the Vagrantfile provisions the VM and runs the following scripts:

1. root runs `scripts/root/provision.sh`
    - installs packages to support RVM and docker
    - installs, starts, and enables haveged
    - installs and configures docker
2. vagrant runs `SIMP_BUILDER_tasks=provision scripts/vagrant/run_tasks.sh`
3. vagrant runs `scripts/vagrant/run_tasks.sh`

The VM's root user runs  `scripts/root/provision.sh` to install essential
services and packages.  It should only need to be run once, during the first
`vagrant up`.

The `scripts/vagrant/run_tasks.sh` script is run by the vagrant user
controls the ISO build process.  It performs staging and build **tasks** by
running ordered collections of scripts.

#### Build tasks

1. **`provision`** ― prepares the vagrant user's environment to run the build tooling
   - installs RVM with bundler
   - installs aria2c
2. **`setup`** ― pre-seeds `/vagrant` environment with required assets
   - downloads ISOs (if necessary)
3. **`clone`** ― pre-seeds `/vagrant` environment with build-specific/custom assets
   - Fetch new `Puppetfile.* `files before the iso build
   - Clone the simp-core repo
   - Move any fetched Puppetfiles into the `simp-core/` top-level directory
   - Create the 'simp-core/ISO' directory
   - Link or copy \*.iso files under `$SIMP_BUILDER_iso_dir` into 'simp-core/ISO'
4. **`build`** ― prepares and executes a specific ISO build
   - stages any alternate `Puppetfile.*` files (if provided)
   - checks out `simp-core` (if necessary)
   - builds the SIMP ISO by running the **rpm_docker** Beaker Suite


#### Task stages

- Each task has three **stages**, which are separated by directory:
   - **`pre-<task_name>`** ― A hook provided for users to run custom actions before the task runs
   - **`<task_name>`** ― The stage run by the vagrant user to perform the task
   - **`post-<task_name>`** ― A hook provided for user to run custom actions after the task finishes
- All tasks, stages, and scripts can be disabled by environment variable
- All stages are defined under `scripts/vagrant/<task_name>.d`


### Customizing tasks with `*.d/` scripts

You can run additional scripts before or after a build stage/task by placing
them under the appropriate `scripts/custom/<user>/(pre|post)-<task_name>.d/`
directory:

```
scripts/
└── scripts/
   └── custom/
       ├── root/
       │   ├── pre-build.d/
       │   └── post-build.d/        # place custom scripts in *.d/
       └── vagrant/
           ├── post-build.d/
           │   │── 10_validate.sh*  # these are just example names, but
           │   └── 20_publish.sh*   # note the numeric ("10_") prefix
           └── pre-build.d/
               └── 10_publish.sh*   # (they must start with ##_)
```

Any file in these `*.d` directories will be run in alphabetical order, providing:
- the filename is prefixed with a double-digit number + underscore (`10_`,`99_`)
- it is executable by the vagrant user



[vagrant]: https://www.vagrantup.com/downloads.html
[virtualbox]: https://www.virtualbox.org/wiki/Downloads
[vagrant-rsync-back]: https://github.com/smerrill/vagrant-rsync-back
