## SIMP build environment


<!-- vim-markdown-toc GFM -->

* [Description](#description)
* [Usage](#usage)
  * [Provisioning the VM](#provisioning-the-vm)
  * [Customizing the provisioning process](#customizing-the-provisioning-process)
    * [ENV variables](#env-variables)
  * [Getting the ISOs once they're built](#getting-the-isos-once-theyre-built)

<!-- vim-markdown-toc -->


## Description

The Vagrantfile in this repository will provision a CentoS 7 Virtualbox VM that can build SIMP ISOs using the rpm_docker suite. 


## Usage

Use cases this project was created for:

- A template for CI runners
- A simple provision-and-build `vagrant up` 
- A single-build for users who don't have access to a stable docker or Linux environment

### Provisioning the VM

    vagrant up

### Customizing the provisioning process

#### ENV variables

Environment variables can be used to customize the provisioning process:

- **`VAGRANT_VM_CPUS`** The number of CPUs available to the VM (default: 8)
- **`VAGRANT_VBOX_NAME`** An alternate name for the local vagrant VM (default: `simp_builder`)

Some environment variables are passed through to the VM guest OS, if they match the following patterns:

- `SIMP_*`
- `BEAKER_*`
- `*NO_SELINUX_DEPS*`


### Getting the ISOs once they're built


