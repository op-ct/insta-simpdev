## SIMP build environment

<!-- vim-markdown-toc GFM -->

* [Description](#description)
* [Setup](#setup)
  * [Requirements](#requirements)
* [Usage](#usage)
  * [Provisioning the VM](#provisioning-the-vm)
  * [Building the ISO](#building-the-iso)
  * [Getting ISOs out of the VM](#getting-isos-out-of-the-vm)
    * [Using `scp`](#using-scp)
    * [Using `vagrant-rsync-back`](#using-vagrant-rsync-back)
* [Reference](#reference)
  * [ENV variables](#env-variables)
    * [Provisioning variables](#provisioning-variables)
    * [Build process variables](#build-process-variables)

<!-- vim-markdown-toc -->


## Description

The Vagrantfile in this repository will provision a CentOS 7 Virtualbox VM that
can build SIMP ISOs using the `rpm_docker` beaker suite.

The are several use cases this project addresses.  You can use it to:

- build SIMP ISOs when you don't have access to a stable docker or Linux environment
- provision a SIMP ISO-building VM to template for CI runners
- inject speculative/customized `Puppetfile.*` files into the SIMP ISO build
  (useful for regression-testing)


## Setup

### Requirements

- [Vagrant][vagrant]
- [VirtualBox][virtualbox]

## Usage

### Provisioning the VM

    vagrant up

### Building the ISO

By default, `vagrant up` will attempt to download and build the SIMP ISO as
part of the provisioning process.


### Getting ISOs out of the VM

#### Using `scp`

```bash
vagrant ssh-config > .vagrant-ssh-config
scp -F .vagrant-ssh-config simp_builder:/vagrant/simp-core/build/distributions/*/*/*/SIMP_ISO/*.iso ./
```

#### Using `vagrant-rsync-back`

```bash
# Ensure the plugin is installed
vagrant plugin install vagrant-rsync-back

# Rsync ALL the contents of /vagrant back to the host machine (this may take a while)
vagrant rsync-back

```


## Reference

### ENV variables

Many environment variables have been exposed for the benefit of power-users and
CI tooling:

#### Provisioning variables

These variables customize affect the `vagrant up` and provisioning process:

- **`VAGRANT_VBOX_NAME`** An alternate name for the local vagrant VM (default: `simp_builder`)
- **`VAGRANT_VM_CPUS`** The number of CPUs available to the VM (default: 8)

#### Build process variables

These variables affect the build scripts under `scripts/vagrant/`.  They are
effective during provisioning and when the scripts are run within the guest OS.

- **`SIMP_BUILDER_install_rvm`** (default: `yes`) if default or set to `yes`, installs RVM for the
  `vagrant` user
- **`SIMP_BUILDER_download_iso`** Unless set to `no`, the VM will attempt to
  download simp ISOs to `downloads/isos/` after provisioning (default: `yes`).
- **`SIMP_BUILDER_build_iso`** Unless set to `no`, the VM will attempt to
  build the SIMP ISO using the isos in the directory `downloads/isos/`
  (default: `yes`)

When **`SIMP_BUILDER_build_iso`** is `yes`:

- **`SIMP_BUILDER_core_repo`** (default: https://github.com/simp/simp-core.git)
- **`SIMP_BUILDER_core_ref`** (default: `master`)

When **`SIMP_BUILDER_build_iso`** is `yes`:

- **`SIMP_BUILDER_core_repo`** (default: https://github.com/simp/simp-core.git)
- **`SIMP_BUILDER_core_ref`** (default: `master`)

Environment variables are passed through to the VM guest OS if they match
the following patterns:

- `SIMP_*`
- `BEAKER_*`
- `*NO_SELINUX_DEPS*`


[vagrant]: https://www.vagrantup.com/downloads.html
[virtualbox]: https://www.virtualbox.org/wiki/Downloads
[vagrant-rsync-back]: https://github.com/smerrill/vagrant-rsync-back
