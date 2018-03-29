## SIMP build environment

<!-- vim-markdown-toc GFM -->

* [Description](#description)
* [Setup](#setup)
  * [Requirements](#requirements)
* [Usage](#usage)
  * [Provisioning the VM](#provisioning-the-vm)
  * [Building the ISO](#building-the-iso)
    * [...using an alternate `simp-core`](#using-an-alternate-simp-core)
* [- A `simp-core` repository placed in the `/vagrant` directory before the **build.d** scripts run  will be used instead of cloning a fresh copy from git.](#--a-simp-core-repository-placed-in-the-vagrant-directory-before-the-buildd-scripts-run--will-be-used-instead-of-cloning-a-fresh-copy-from-git)
    * [...using alternate `Puppetfile.*` files](#using-alternate-puppetfile-files)
  * [Getting ISOs out of the VM](#getting-isos-out-of-the-vm)
    * [Using `scp`](#using-scp)
    * [Using `vagrant-rsync-back`](#using-vagrant-rsync-back)
* [Reference](#reference)
  * [How the build process works](#how-the-build-process-works)
    * [`vagrant up`](#vagrant-up)
    * [Build tasks](#build-tasks)
    * [Task stages](#task-stages)
  * [Customizing tasks with hooks](#customizing-tasks-with-hooks)
  * [ENV variables](#env-variables)
    * [Provisioning variables](#provisioning-variables)
    * [Build process variables](#build-process-variables)
    * [Pass-through variables](#pass-through-variables)
  * ["Kill switch" variables](#kill-switch-variables)

<!-- vim-markdown-toc -->


## Description

The Vagrantfile in this repository will provision a CentOS 7 Virtualbox VM that
can build SIMP ISOs using the `rpm_docker` beaker suite.

You can use it to:

- Build SIMP ISOs in environments where you don't have access to docker or
  Linux (useful for building from OSX or Windows).
- Provision a VM to template as a CI runner to build SIMP ISOs (useful for
  nightly builds and testing).
- Inject speculative/customized `Puppetfile.*` files into the SIMP ISO build
  (useful for regression-testing).


## Setup

### Requirements

- [Vagrant][vagrant]
- [VirtualBox][virtualbox]

## Usage

### Provisioning the VM

    vagrant up

### Building the ISO

By default, a `vagrant up` will provision a VM and run the **provision**,
**setup**, and **build** tasks.  This will install and configure up build tools
like RVM, download the ISOs for CentOS 6 and CentOS 7, `git clone` the
`simp-core` repository, and build SIMP ISOs using the **rpm_docker** Beaker
Suite.

* ISO files will remain on the VM until fetched


#### ...using an alternate `simp-core`

By default, the **build** task will clone a fresh copy of `simp-core` from git.

- The

- A `simp-core` repository placed in the `/vagrant` directory before the **build.d** scripts run  will be used instead of cloning a fresh copy from git.
-


#### ...using alternate `Puppetfile.*` files

- Any `Puppetfile.*` files that are present in the top level `/vagrant` directory by the **build.d** stage will be copied into `simp-core` (replacing any existing files with the same names), just prior to building the ISO.


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
  simp_builder:/vagrant/simp-core/build/distributions/*/*/*/{SIMP_ISO/*.iso,DVD_Overlay/*.tar.gz} ./
```


#### Using `vagrant-rsync-back`

```bash
# Ensure the plugin is installed:
vagrant plugin install vagrant-rsync-back

# Rsync ALL the contents of /vagrant back to the host machine (this may take a while):
vagrant rsync-back
```



## Reference

### How the build process works

The build process is basically a few simple shell scripts that prepare the
environment and build an ISO.  However, they have been structured to give CI
systems control to every aspect of the process by providing environment
variables, pre- and post-task hooks, and special marshalling locations for
staging specific builds.

#### `vagrant up`

By default, the Vagrantfile provisions the VM and runs the following scripts:

1. `scripts/root/provision.sh` as root
    - installs packages to support RVM and docker
    - installs, starts, and enables haveged
    - installs and configures docker
2. `SIMP_BUILDER_tasks=provision scripts/vagrant/run_tasks.sh` as vagrant
3. `scripts/vagrant/run_tasks.sh` as vagrant

The `scripts/root/provision.sh` script is run by the root user and installs
essential services and packages.  It should only need to be run once, during
`vagrant up`.

The `scripts/vagrant/run_tasks.sh` script is run by the vagrant user
controls the ISO build process.  It performs staging and build **tasks** by
running ordered collections of scripts.

#### Build tasks

  - **provision** ― prepares the vagrant user's environment to run the build tooling
    - installs RVM with bundler
    - installs aria2c
  - **setup** ― pre-seeds `/vagrant` environment with required assets
    - downloads ISOs (if necessary)
  - **build** ― prepares and executes a specific ISO build
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


### Customizing tasks with hooks

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


### ENV variables

Many environment variables have been exposed for the benefit of power-users and
CI tooling:

#### Provisioning variables

These variables customize affect the `vagrant up` and provisioning process:

- **`VAGRANT_VBOX_NAME`** An alternate name for the local vagrant VM (default: `simp_builder`)
- **`VAGRANT_VM_CPUS`** The number of CPUs available to the VM (default: 8)

#### Build process variables

These variables affect the build scripts under `scripts/vagrant/`.  They are
effective during provisioning and when the scripts are run within the guest OS:

- **`SIMP_BUILDER_install_rvm`** (default: `yes`) if default or set to `yes`, installs RVM for the
  `vagrant` user
- **`SIMP_BUILDER_download_iso`** Unless set to `no`, the VM will attempt to
  download simp ISOs to `downloads/isos/` after provisioning (default: `yes`).
- **`SIMP_BUILDER_build_iso`** Unless set to `no`, the VM will attempt to
  build the SIMP ISO using the isos in the directory `downloads/isos/`
  (default: `yes`)o
- **`SIMP_BUILDER_dry_run** When `yes`, scripts will not be executed

When **`SIMP_BUILDER_build_iso`** is `yes`:

- **`SIMP_BUILDER_core_repo`** (default: https://github.com/simp/simp-core.git)
- **`SIMP_BUILDER_core_ref`** (default: `master`)

- **`SIMP_BUILDER_puppetfile_repo`** (default: https://github.com/simp/simp-core.git)
- **`SIMP_BUILDER_puppetfile_ref`** (default: `master`)

#### Pass-through variables

Environment variables can be passed through `vagrant up` into the guest VM's OS
if they match any of these patterns:

- `SIMP_*`
- `BEAKER_*`
- `FACTER_*`
- `PUPPET_*`
- `*NO_SELINUX_DEPS*`
- `DEBUG`
- `VERBOSE`

This is useful to influence the rake tasks

### "Kill switch" variables

It is possible to disable any combination

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

[vagrant]: https://www.vagrantup.com/downloads.html
[virtualbox]: https://www.virtualbox.org/wiki/Downloads
[vagrant-rsync-back]: https://github.com/smerrill/vagrant-rsync-back
